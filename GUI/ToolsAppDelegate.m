//
//  ToolsAppDelegate.m
//  G15 Tools
//
//  Created by Phillip Hutchings on 29/10/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "ToolsAppDelegate.h"


@implementation ToolsAppDelegate
@synthesize macroKeys, currentMacroSet;
- (void)awakeFromNib {
	[NSValueTransformer setValueTransformer:[[IdentifierToIconValueTransformer alloc] init] forName:@"IdentifierToIcon"];
	plugins = [[NSMutableArray alloc] init];
	macroGroups = [[NSMutableArray alloc] init];
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults registerDefaults:[NSDictionary dictionaryWithObjectsAndKeys:[NSData data], keysDefaultKey, nil]];
	[[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self 
														   selector:@selector(applicationDidChange:) 
															   name:@"NSWorkspaceDidActivateApplicationNotification" 
															 object:nil];
	
	id combosData = [defaults objectForKey:keysDefaultKey];
	@try {
		NSDictionary *immutableCombos = [NSKeyedUnarchiver unarchiveObjectWithData:combosData];
		keyActions = [immutableCombos mutableCopy];
	}
	@catch (NSException *e) {
		NSLog(@"Failed to unserialize key codes :(");
	}
	if (keyActions == nil) {
		keyActions = [[NSMutableDictionary alloc] initWithCapacity:15];
	}
	[self performSelector:@selector(setupDefaults) withObject:nil afterDelay:0.5];
	
	[self willChangeValueForKey:@"macroKeys"];
	macroKeys = [NSMutableArray arrayWithCapacity:20];
	for (int i = 1; i <= 18; i++) {
		[macroKeys addObject:[[G15Key alloc] initWithCode:1 << (i-1) label:[NSString stringWithFormat:@"G%i", i]]];
	}
	[self didChangeValueForKey:@"macroKeys"];
}

- (void)setupDefaults {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults registerDefaults:[NSDictionary dictionaryWithObjectsAndKeys:[NSData data], keysDefaultKey, nil]];
	
	NSError *err = nil;
	[self loadLocalFonts:&err requiredFonts:[NSArray arrayWithObject:@"VisitorTT1BRK"]];
	
	font = [NSFont fontWithName:@"VisitorTT1BRK" size:10.0];
	[font retain];
	
	displayImage = [[NSImage alloc] initWithSize: NSMakeSize(160, 43)];
	[displayImage setFlipped: YES];
	[displayImage lockFocus];
	[[NSColor whiteColor] set];
	NSRectFill(NSMakeRect(0, 0, 160, 43));
	[displayImage unlockFocus];
	[self updateDisplay];
	[self loadPlugins];
	[self connect:nil];
}

- (void)connect:(NSTimer *)t {
	serverObject = (NSDistantObject<KeyboardHelperProtocol>*)[NSConnection rootProxyForConnectionWithRegisteredName:@"com.sitharus.keyboardHelper" host:nil];
	if (serverObject == nil) {
		[NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(connect:) userInfo:nil repeats:NO];
	} else {
		[serverObject setProtocolForProxy:@protocol(KeyboardHelperProtocol)];
		[serverObject setDelegate:self];
		[serverObject retain];		
	}
}


- (void)applicationDidChange:(NSNotification *)notification {
	NSDictionary *appDetails = [[NSWorkspace sharedWorkspace] activeApplication];
	NSString *appBundleIdentifier = [appDetails objectForKey:@"NSApplicationBundleIdentifier"];
	NSPredicate *p = [NSPredicate predicateWithFormat:@"identifier=%@" argumentArray:[NSArray arrayWithObject:appBundleIdentifier]];
	NSFetchRequest *fr = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"MacroApplication"
											  inManagedObjectContext:managedObjectContext];
	[fr setEntity:entity];
	[fr setPredicate:p];
	NSError *err = nil;
	NSArray *results = [managedObjectContext executeFetchRequest:fr error:&err];
	if (err != nil) {
		NSLog(@"Error! %@", err);
		[serverObject setLEDs:0];
		return;
	}
	if ([results count] == 0) {
		[serverObject setLEDs:0];
		return;
	}
	MacroApplication *ma = (MacroApplication *)[results objectAtIndex:0];
	currentMacroGroup = ma.macroGroup;
	[self switchToMacroSet:1];
}

- (void)switchToMacroSet:(int)macroSet {
	currentMacroSet = nil;
	[serverObject setLEDs:0];
	if ([currentMacroGroup.macroSets count] == 0) {
		return;
	}
	NSPredicate *p = [NSPredicate predicateWithFormat:@"macroIndex=%@" argumentArray:[NSArray arrayWithObject:[NSNumber numberWithInt:macroSet]]];
	NSArray *macroSets = [[[currentMacroGroup macroSets] allObjects] filteredArrayUsingPredicate:p];
	if ([macroSets count] == 0) {
		return;
	}
	MacroSet *ms = [macroSets objectAtIndex:0];
	currentMacroSet = [ms.macros allObjects];
	int macroIndex = [ms.macroIndex intValue];
	switch (macroIndex) {
		case 1:
			[serverObject setLEDs:G15_LED_M1];
			break;
		case 2:
			[serverObject setLEDs:G15_LED_M2];
			break;
		case 3:
			[serverObject setLEDs:G15_LED_M3];
			break;
		default:
			[serverObject setLEDs:0];
	}
}

- (void)loadPlugins {
	NSString *pluginsPath = [[NSBundle mainBundle] builtInPlugInsPath];
	NSError *err = NULL;
	NSArray *pluginsToLoad = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:pluginsPath error:&err];
	[plugins addObject:[NullActionProvider sharedInstance]];
	if (pluginsToLoad) {
		for (NSString *bundlePath in pluginsToLoad) {
			NSString *fullPath = [pluginsPath stringByAppendingPathComponent:bundlePath];
			NSBundle *plugin = [NSBundle bundleWithPath:fullPath];
			BOOL loaded = [plugin loadAndReturnError:&err];
			if (loaded) {
				NSObject<KeyboardActionProvider> *pluginMain = [[plugin principalClass] sharedInstance];
				[self willChangeValueForKey:@"plugins"];
				[plugins addObject:pluginMain];
				[self didChangeValueForKey:@"plugins"];
				NSLog(@"Loaded %@", bundlePath);
			} else {
				NSAlert *alert = [NSAlert alertWithError:err];
				[alert runModal];
			}
		}
	}
	
}

- (void)updateDisplay {
	memset(g15lcd.buffer, 0x00, sizeof(g15lcd.buffer));
	memset(g15lcd.control, 0x00, sizeof(g15lcd.control));
	// Blitty blitty
	[lcdPreview setImage:displayImage];
	[displayImage lockFocus];
	NSBitmapImageRep *imageRep = [[NSBitmapImageRep alloc] initWithFocusedViewRect:NSMakeRect(0, 0, 160, 43)];
	[displayImage unlockFocus];
	for (int x=0; x<160; x++) {
		for (int y=0; y<43; y++) {
			NSColor *c = [imageRep colorAtX:x y:y];
			CGFloat brightness = [c brightnessComponent];
			if (brightness < 0.6) {
				g15lcd.buffer[((y / 0x08) * 0xa0) + x] |= 1 << (y % 8);
			}	
		}
	}
	[imageRep release];
	
	g15lcd.control[0] = 0x03;
	[serverObject setLCD:g15lcd];
}

- (void)setAction:(NSObject<KeyboardAction> *)action forKey:(int)key {
	[keyActions setObject:action forKey:[NSNumber numberWithInt:key]];
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSData *d = [NSKeyedArchiver archivedDataWithRootObject:keyActions];
	[defaults setObject:d forKey:keysDefaultKey];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSObject<KeyboardAction> *)actionForKey:(NSNumber *)key  {
	if (currentMacroSet) {
		int keyCode = [key intValue];
		for (Macro *m in currentMacroSet) {
			if (m.keyDetails.keyCode == keyCode) {
				return m.keyAction;
			}
		}
	}
	return nil;
}

- (void)handleKeypress:(int)keys {
	int keysUp = pressedKeys & (~keys);
	int keysDown = keys & (~pressedKeys);
	if (keysUp) {
		[self sendKeys:keysUp toSelector:@selector(keyUp:)];
	}
	if (keysDown) {
		[self sendKeys:keysDown toSelector:@selector(keyDown:)];
	}
	pressedKeys = keys;
}

- (void)keyUp:(NSNumber *)key {
	NSObject<KeyboardAction> *action = [self actionForKey:key];
	if (action != nil) {
		[action keyUp];
	} else {
		switch ([key intValue]) {
			case G15_KEY_L1:
				[self updateDisplay];
				break;
			case G15_KEY_M1:
				[self switchToMacroSet:1];
				break;
			case G15_KEY_M2:
				[self switchToMacroSet:2];
				break;
			case G15_KEY_M3:
				[self switchToMacroSet:3];
				break;
		}
	}
}

- (void)keyDown:(NSNumber *)key {
	NSObject<KeyboardAction> *action = [self actionForKey:key];
	if (action != nil) {
		[action keyDown];

	}
}

- (void)sendKeys:(int)keys toSelector:(SEL)selector {
	if (keys & G15_KEY_G1) {
		[self performSelector:selector withObject:[NSNumber numberWithInt:G15_KEY_G1]];
	}
	
	if (keys & G15_KEY_G2) {
		[self performSelector:selector withObject:[NSNumber numberWithInt:G15_KEY_G2]];
	}
	
	if (keys & G15_KEY_G3) {
		[self performSelector:selector withObject:[NSNumber numberWithInt:G15_KEY_G3]];
	}
	
	if (keys & G15_KEY_G4) {
		[self performSelector:selector withObject:[NSNumber numberWithInt:G15_KEY_G4]];
	}
	
	if (keys & G15_KEY_G5) {
		[self performSelector:selector withObject:[NSNumber numberWithInt:G15_KEY_G5]];
	}
	
	if (keys & G15_KEY_G6) {
		[self performSelector:selector withObject:[NSNumber numberWithInt:G15_KEY_G6]];
	}
	
	if (keys & G15_KEY_G7) {
		[self performSelector:selector withObject:[NSNumber numberWithInt:G15_KEY_G7]];
	}
	
	if (keys & G15_KEY_G8) {
		[self performSelector:selector withObject:[NSNumber numberWithInt:G15_KEY_G8]];
	}
	
	if (keys & G15_KEY_G9) {
		[self performSelector:selector withObject:[NSNumber numberWithInt:G15_KEY_G9]];
	}
	
	if (keys & G15_KEY_G10) {
		[self performSelector:selector withObject:[NSNumber numberWithInt:G15_KEY_G10]];
	}
	
	if (keys & G15_KEY_G11) {
		[self performSelector:selector withObject:[NSNumber numberWithInt:G15_KEY_G11]];
	}
	
	if (keys & G15_KEY_G12) {
		[self performSelector:selector withObject:[NSNumber numberWithInt:G15_KEY_G12]];
	}
	
	if (keys & G15_KEY_G13) {
		[self performSelector:selector withObject:[NSNumber numberWithInt:G15_KEY_G13]];
	}
	
	if (keys & G15_KEY_G14) {
		[self performSelector:selector withObject:[NSNumber numberWithInt:G15_KEY_G14]];
	}
	
	if (keys & G15_KEY_G15) {
		[self performSelector:selector withObject:[NSNumber numberWithInt:G15_KEY_G15]];
	}
	
	if (keys & G15_KEY_G16) {
		[self performSelector:selector withObject:[NSNumber numberWithInt:G15_KEY_G16]];
	}
	
	if (keys & G15_KEY_G17) {
		[self performSelector:selector withObject:[NSNumber numberWithInt:G15_KEY_G17]];
	}
	
	if (keys & G15_KEY_G18) {
		[self performSelector:selector withObject:[NSNumber numberWithInt:G15_KEY_G18]];
	}
	
	if (keys & G15_KEY_M1) {
		[self performSelector:selector withObject:[NSNumber numberWithInt:G15_KEY_M1]];
	}
	
	if (keys & G15_KEY_M2) {
		[self performSelector:selector withObject:[NSNumber numberWithInt:G15_KEY_M2]];
	}
	
	if (keys & G15_KEY_M3) {
		[self performSelector:selector withObject:[NSNumber numberWithInt:G15_KEY_M3]];
	}
	
	if (keys & G15_KEY_MR) {
		[self performSelector:selector withObject:[NSNumber numberWithInt:G15_KEY_MR]];
	}
	
	if (keys & G15_KEY_L1) {
		[self performSelector:selector withObject:[NSNumber numberWithInt:G15_KEY_L1]];
	}
	
	if (keys & G15_KEY_L2) {
		[self performSelector:selector withObject:[NSNumber numberWithInt:G15_KEY_L2]];
	}
	
	if (keys & G15_KEY_L3) {
		[self performSelector:selector withObject:[NSNumber numberWithInt:G15_KEY_L3]];
	}
	
	if (keys & G15_KEY_L4) {
		[self performSelector:selector withObject:[NSNumber numberWithInt:G15_KEY_L4]];
	}
	
	if (keys & G15_KEY_L5) {
		[self performSelector:selector withObject:[NSNumber numberWithInt:G15_KEY_L5]];
	}
	
	if (keys & G15_KEY_LIGHT) {
		[self performSelector:selector withObject:[NSNumber numberWithInt:G15_KEY_LIGHT]];
	}
	
}

- (BOOL)loadLocalFonts:(NSError **)err requiredFonts:(NSArray *)fontnames
{
	NSString *resourcePath, *fontsFolder,*errorMessage;    
	NSURL *fontsURL;
	resourcePath = [[NSBundle mainBundle] resourcePath];
	if (!resourcePath) 
	{
		errorMessage = @"Failed to load fonts! no resource path...";
		goto error;
	}
	fontsFolder = [[NSBundle mainBundle] resourcePath];
	
	NSFileManager *fm = [NSFileManager defaultManager];
	
	if (![fm fileExistsAtPath:fontsFolder])
	{
		errorMessage = @"Failed to load fonts! Font folder not found...";
		goto error;
	}
	if((fontsURL = [NSURL fileURLWithPath:fontsFolder]))
	{
		OSStatus status;
		FSRef fsRef;
		CFURLGetFSRef((CFURLRef)fontsURL, &fsRef);
		status = ATSFontActivateFromFileReference(&fsRef, kATSFontContextLocal, kATSFontFormatUnspecified, 
												  NULL, kATSOptionFlagsDefault, NULL);
		if (status != noErr)
		{
			errorMessage = @"Failed to acivate fonts!";
			goto error;
		}
	}
	if (fontnames != nil)
	{
		NSFontManager *fontManager = [NSFontManager sharedFontManager];
		//NSLog(@"%@", [fontManager availableFontFamilies]);
		for (NSString *fontname in fontnames)
		{
			BOOL fontFound = [[fontManager availableFonts] containsObject:fontname]; 
			if (!fontFound)
			{
				errorMessage = [NSString stringWithFormat:@"Required font not found:%@",fontname];
				goto error;
			}
		}
	}
	return YES;
error:
	
	if (err != NULL) {
		NSString *localizedMessage = NSLocalizedString(errorMessage, @"");
		NSDictionary *userInfo = [NSDictionary dictionaryWithObject:localizedMessage forKey:NSLocalizedDescriptionKey];
		*err = [[NSError alloc] initWithDomain:NSCocoaErrorDomain code:0 userInfo:userInfo];
	}
	
	return NO;
	
}

- (void)setCurrentMacros:(NSArray *)newMacros forMacroIndex:(NSNumber *)macroIndex {
	self.currentMacroSet = newMacros;
	int index = [macroIndex intValue];
	int ledsToShow = 0;
	switch (index) {
		case 1:
			ledsToShow = G15_LED_M1;
			break;
		case 2:
			ledsToShow = G15_LED_M2;
			break;
		case 3:
			ledsToShow = G15_LED_M3;
			break;
	}
	[serverObject setLEDs:ledsToShow];
}


/**
 Returns the support folder for the application, used to store the Core Data
 store file.  This code uses a folder named "test" for
 the content, either in the NSApplicationSupportDirectory location or (if the
 former cannot be found), the system's temporary directory.
 */

- (NSString *)applicationSupportFolder {
	
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : NSTemporaryDirectory();
    return [basePath stringByAppendingPathComponent:@"G15Tools"];
}


/**
 Creates, retains, and returns the managed object model for the application 
 by merging all of the models found in the application bundle.
 */

- (NSManagedObjectModel *)managedObjectModel {
	
    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
	
    managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];    
    return managedObjectModel;
}


/**
 Returns the persistent store coordinator for the application.  This 
 implementation will create and return a coordinator, having added the 
 store for the application to it.  (The folder for the store is created, 
 if necessary.)
 */

- (NSPersistentStoreCoordinator *) persistentStoreCoordinator {
	
    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }
	
    NSFileManager *fileManager;
    NSString *applicationSupportFolder = nil;
    NSURL *url;
    NSError *error = nil;
    
    fileManager = [NSFileManager defaultManager];
    applicationSupportFolder = [self applicationSupportFolder];
    if ( ![fileManager fileExistsAtPath:applicationSupportFolder isDirectory:NULL] ) {
		if (![fileManager createDirectoryAtPath:applicationSupportFolder withIntermediateDirectories:NO attributes:nil error:&error]) {
            NSLog(@"Error creating application support directory at %@ : %@",applicationSupportFolder,error);
		}
    }
    
    url = [NSURL fileURLWithPath: [applicationSupportFolder stringByAppendingPathComponent: @"g15.xml"]];
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSXMLStoreType configuration:nil URL:url options:nil error:&error]){
        [[NSApplication sharedApplication] presentError:error];
    }    
	
    return persistentStoreCoordinator;
}


/**
 Returns the managed object context for the application (which is already
 bound to the persistent store coordinator for the application.) 
 */

- (NSManagedObjectContext *) managedObjectContext {
	
    if (managedObjectContext != nil) {
        return managedObjectContext;
    }
	
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    
    return managedObjectContext;
}


/**
 Returns the NSUndoManager for the application.  In this case, the manager
 returned is that of the managed object context for the application.
 */

- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window {
    return [[self managedObjectContext] undoManager];
}


/**
 Performs the save action for the application, which is to send the save:
 message to the application's managed object context.  Any encountered errors
 are presented to the user.
 */

- (IBAction) saveAction:(id)sender {
	
    NSError *error = nil;
    if (![[self managedObjectContext] save:&error]) {
        [[NSApplication sharedApplication] presentError:error];
    }
}


/**
 Implementation of the applicationShouldTerminate: method, used here to
 handle the saving of changes in the application managed object context
 before the application terminates.
 */

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {
	
    NSError *error;
    int reply = NSTerminateNow;
    
    if (managedObjectContext != nil) {
        if ([managedObjectContext commitEditing]) {
            if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
				
                // This error handling simply presents error information in a panel with an 
                // "Ok" button, which does not include any attempt at error recovery (meaning, 
                // attempting to fix the error.)  As a result, this implementation will 
                // present the information to the user and then follow up with a panel asking 
                // if the user wishes to "Quit Anyway", without saving the changes.
				
                // Typically, this process should be altered to include application-specific 
                // recovery steps.  
				
                BOOL errorResult = [[NSApplication sharedApplication] presentError:error];
				
                if (errorResult == YES) {
                    reply = NSTerminateCancel;
                } 
				
                else {
					
                    int alertReturn = NSRunAlertPanel(nil, @"Could not save changes while quitting. Quit anyway?" , @"Quit anyway", @"Cancel", nil);
                    if (alertReturn == NSAlertAlternateReturn) {
                        reply = NSTerminateCancel;	
                    }
                }
            }
        } 
        
        else {
            reply = NSTerminateCancel;
        }
    }
    
    return reply;
}

@end
