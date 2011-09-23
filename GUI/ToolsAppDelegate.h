//
//  ToolsAppDelegate.h
//  G15 Tools
//
//  Created by Phillip Hutchings on 29/10/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "KeyboardHelperProtocol.h"
#import "KeyboardClientProtocol.h"
#import "ToolsKeyCombo.h"
#import "KeyboardToolsDefines.h"
#import "KeyboardAction.h"
#import "KeyboardActionProvider.h"
#import "NullActionProvider.h"
#import "G15Key.h"
#import "Macro.h"
#import "MacroGroup.h"
#import "MacroSet.h"
#import "MacroApplication.h"
#import "IdentifierToIconValueTransformer.h"

#define keysDefaultKey @"keysDefaultKey"
#define kKeyDragType @"MacroKeyDragType"

@interface ToolsAppDelegate : NSObject<KeyboardClientProtocol> {
    IBOutlet NSWindow *window;
	IBOutlet NSImageView *lcdPreview;
	int pressedKeys;
	NSMutableDictionary *keyActions;
	NSDistantObject<KeyboardHelperProtocol> *serverObject;
	NSImage *displayImage;
	NSFont *font;
	G15Screen g15lcd;
	
	NSArray *currentMacroSet;
	MacroGroup *currentMacroGroup;
	
	NSMutableArray *plugins;
	NSMutableArray *macroGroups;
	NSMutableArray *macroKeys;
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
    NSManagedObjectModel *managedObjectModel;
    IBOutlet NSManagedObjectContext *managedObjectContext;
}
- (void)connect:(NSTimer *)t;
- (void)setupDefaults;
- (void)applicationDidChange:(NSNotification *)notification;
- (void)switchToMacroSet:(int)macroSet;
- (void)loadPlugins;
- (void)setAction:(NSObject<KeyboardAction> *)action forKey:(int)key;
- (NSObject<KeyboardAction> *)actionForKey:(NSNumber *)key;
- (void)handleKeypress:(int)keys;
- (void)sendKeys:(int)keys toSelector:(SEL)selector;
- (void)keyUp:(NSNumber *)key;
- (void)keyDown:(NSNumber *)key;
- (void)sendKeys:(int)keys toSelector:(SEL)selector;
- (void)updateDisplay;
- (BOOL)loadLocalFonts:(NSError **)err requiredFonts:(NSArray *)fontnames;
- (void)setCurrentMacros:(NSArray *)newMacros forMacroIndex:(NSNumber *)macroIndex;
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator;
- (NSManagedObjectModel *)managedObjectModel;
- (NSManagedObjectContext *)managedObjectContext;
- (IBAction)saveAction:sender;
@property(readonly) NSArray *macroKeys;
@property(assign) NSArray *currentMacroSet;
@end
