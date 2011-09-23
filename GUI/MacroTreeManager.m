//
//  MacroTreeDataSource.m
//  G15 Tools
//
//  Created by Phillip Hutchings on 4/11/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "MacroTreeManager.h"


@implementation MacroTreeManager
@synthesize currentMacros, currentGroup;

- (void)awakeFromNib {
	objectContext = [appDelegate managedObjectContext];
	currentMacroControllers = [NSMutableArray array];
	[self refetchData];
}

- (void)refetchData {
	
	NSError *fetchError = nil;
	NSArray *fetchResults;
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	@try  {
		NSEntityDescription *entity = [NSEntityDescription entityForName:@"MacroGroup"
												  inManagedObjectContext:objectContext];
		[fetchRequest setEntity:entity];
		fetchResults = [objectContext executeFetchRequest:fetchRequest error:&fetchError];
		
		if ((fetchResults != nil) && (fetchError == nil))
		{
			rootObjects = fetchResults;
		}
		if (fetchError != nil)
		{
			[[NSApplication sharedApplication] presentError:fetchError];
		}
		else
		{
			// should present custom error message...
		}
	}
	@catch (NSException *e) {
		NSLog(@"Exception: %@, %@", [e name], [e description]);
		rootObjects = [[NSArray alloc] init];
	}
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item {
	if (item == nil) {
		return [rootObjects objectAtIndex:index];
	}
	return [[[[(MacroGroup *)item macroSets] allObjects] sortedArrayUsingSelector:@selector(name)] objectAtIndex:index];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
	if ([item class] == [MacroGroup class]) {
		return YES;
	}
	return NO;
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item {
	if (item) {
		return [[[(MacroGroup *)item macroSets] allObjects] count];
	}
	return [rootObjects count];
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item {
	if ([item class] == [MacroGroup class]) {
		return ((MacroGroup *)item).name;
	}
	return ((MacroSet *)item).name;
}

- (void)outlineView:(NSOutlineView *)outlineView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn byItem:(id)item {
	if ([object isKindOfClass:[NSString class]]) {
		NSString *newName = (NSString *)object;
		
		if ([item class] == [MacroGroup class]) {
			((MacroGroup *)item).name = newName;
		} else {
			((MacroSet *)item).name = newName;
		}
	}
}

- (IBAction)addGroup:(id)sender {
	[NSEntityDescription insertNewObjectForEntityForName:@"MacroGroup"
								  inManagedObjectContext:objectContext];
	[self refetchData];
	[managedView reloadData];
	[appDelegate saveAction:self];
}

- (IBAction)addSet:(id)sender {
	NSIndexSet *indexes = [managedView selectedRowIndexes];
	if ([indexes count] > 0 ) {
		NSManagedObject *selectedItem = [managedView itemAtRow:[indexes firstIndex]];
		if ([[[selectedItem entity] name] isEqual:@"MacroGroup"]) {
			
			MacroSet *newSet = (MacroSet *)[NSEntityDescription insertNewObjectForEntityForName:@"MacroSet"
																		 inManagedObjectContext:objectContext];
			MacroGroup *macroItem = (MacroGroup *)selectedItem;
			[macroItem addMacroSetsObject:newSet];
		} else {
			
		}
	}
	[self refetchData];
	[managedView reloadData];
	[appDelegate saveAction:self];
}

- (Macro *)addMacro:(G15Key *)k {
	if (self.currentMacros) {
		Macro *newMacro = (Macro *)[NSEntityDescription insertNewObjectForEntityForName:@"Macro"
																 inManagedObjectContext:objectContext];
		newMacro.triggerKey = [NSNumber numberWithInt:[k keyCode]];
		newMacro.action = [NSData data];
		newMacro.keyDetails = k;
		NSIndexSet *indexes = [managedView selectedRowIndexes];
		
		MacroSet *currentSet = (MacroSet *)[managedView itemAtRow:[indexes firstIndex]];
		[currentSet addMacrosObject:newMacro];
		[appDelegate saveAction:self];
		
		self.currentMacros = [[currentSet.macros allObjects] sortedArrayUsingSelector:@selector(triggerKey)];
		return newMacro;
	}
	return nil;
}

- (void)outlineViewSelectionDidChange:(NSNotification *)notification {
	
	[self willChangeValueForKey:@"macro1Selected"];
	[self willChangeValueForKey:@"macro2Selected"];
	[self willChangeValueForKey:@"macro3Selected"];
	
	[self didChangeValueForKey:@"macro1Selected"];
	[self didChangeValueForKey:@"macro2Selected"];
	[self didChangeValueForKey:@"macro3Selected"];
	
	NSIndexSet *indexes = [managedView selectedRowIndexes];
	NSManagedObject *selectedItem = [managedView itemAtRow:[indexes firstIndex]];
	if ([[[selectedItem entity] name] isEqual:@"MacroGroup"]) {
		[managedTabs selectTabViewItemAtIndex:0];
		self.currentMacros = nil;
		self.currentGroup = (MacroGroup *)selectedItem;
	} else {
		[managedTabs selectTabViewItemAtIndex:1];
		MacroSet *currentSet = (MacroSet *)selectedItem;
		self.currentMacros = [[currentSet.macros allObjects] sortedArrayUsingSelector:@selector(triggerKey)];
		self.currentGroup = (MacroGroup *)[currentSet macroGroup];
		[self repopulateMacroList];
	}
}

- (void)repopulateMacroList {
	NSArray *subViews = [[macroListView subviews] copy];
	for (NSView *view in subViews) {
		[view removeFromSuperview];
	}
	[currentMacroControllers removeAllObjects];
	
	NSSortDescriptor * s = [[NSSortDescriptor alloc] initWithKey:@"keyOrder" ascending:YES];
	NSArray *descriptors = [NSArray arrayWithObject:s];
	[s autorelease];
	
	double offset = 0;
	for (G15Key *k in [[appDelegate macroKeys] sortedArrayUsingDescriptors:descriptors]) {
		NSPredicate *p = [NSPredicate predicateWithFormat:@"keyDetails.keyCode=%i" argumentArray:[NSArray arrayWithObject:[NSNumber numberWithInt:[k keyCode]]]];
		NSArray *a = [self.currentMacros filteredArrayUsingPredicate:p];
		MacroController *c = [[MacroController alloc] init];
		
		if ([a count] > 0) {
			c.macro = [a objectAtIndex:0];
		} else {
			c.macro = [self addMacro:k];
		}
		c.key = k;
		c.appDelegate = appDelegate;
		[c loadNib];
		NSView *macroView = c.macroView;
		[macroView setAutoresizingMask:NSViewNotSizable|NSViewWidthSizable];
		NSRect r = [macroView frame];
		r.origin.y += offset;
		offset += r.size.height;
		
		r.size.width = [macroListView frame].size.width;
		[macroView setFrame:r];
		
		NSRect mainRect = [macroListView frame];
		[macroListView setFrameSize:NSMakeSize(mainRect.size.width, offset)];
		[macroListView addSubview:macroView];
	}

}

#pragma mark -
#pragma mark Application selection


- (IBAction)addApplication:(id)sender {
	NSOpenPanel *panel = [NSOpenPanel openPanel];
	NSArray *types = [NSArray arrayWithObjects:@"app", nil];
	[panel beginSheetForDirectory:nil file:nil types:types modalForWindow:mainWindow modalDelegate:self 
				   didEndSelector:@selector(openPanelDidEnd:returnCode:contextInfo:) contextInfo:nil];
}
	 
- (void)openPanelDidEnd:(NSOpenPanel *)panel returnCode:(int)returnCode  contextInfo:(void *)contextInfo {
	if (returnCode == NSOKButton && [[panel filenames] count] > 0) {
		NSString *appBundle = [[panel filenames] objectAtIndex:0];
		NSBundle *bundle = [NSBundle bundleWithPath:appBundle];
		NSString *identifier = [bundle bundleIdentifier];
		NSString *appName = [appBundle lastPathComponent];
		
		NSLog(@"Got identifier %@ for bundle %@", identifier, appBundle);
		
		MacroApplication *newapp = (MacroApplication *)[NSEntityDescription insertNewObjectForEntityForName:@"MacroApplication"
																					 inManagedObjectContext:objectContext];
		newapp.name = appName;
		newapp.identifier = identifier;
		[currentGroup addApplicationsObject:newapp];
	}
}

#pragma mark -
#pragma mark Macro buttons

- (NSInteger)macroSelected:(NSInteger)macroIndex {
	NSIndexSet *indexes = [managedView selectedRowIndexes];
	if ([indexes count]) {
		NSManagedObject *selectedItem = [managedView itemAtRow:[indexes firstIndex]];
		if ([[[selectedItem entity] name] isEqual:@"MacroSet"]) {
			MacroSet *currentSet = (MacroSet *)selectedItem;
			if ([currentSet.macroIndex isEqualToNumber:[NSNumber numberWithInt:macroIndex]]) {
				return NSOnState;
			}
		}		
	}
	return NSOffState;
}

- (void)setMacroSelected:(NSInteger)state forIndex:(NSInteger)macroIndex {
	NSIndexSet *indexes = [managedView selectedRowIndexes];
	if ([indexes count]) {
		[self willChangeValueForKey:@"macro1Selected"];
		[self willChangeValueForKey:@"macro2Selected"];
		[self willChangeValueForKey:@"macro3Selected"];
		NSManagedObject *selectedItem = [managedView itemAtRow:[indexes firstIndex]];
		if ([[[selectedItem entity] name] isEqual:@"MacroSet"]) {
			MacroSet *currentSet = (MacroSet *)selectedItem;
			if (state == NSOnState) {
				currentSet.macroIndex = [NSNumber numberWithInt:macroIndex];
			} else if ([currentSet.macroIndex isEqualToNumber:[NSNumber numberWithInt:macroIndex]]) {
				currentSet.macroIndex = nil;
			}
		}
		
		[self didChangeValueForKey:@"macro1Selected"];
		[self didChangeValueForKey:@"macro2Selected"];
		[self didChangeValueForKey:@"macro3Selected"];
	}
	
	[self refetchData];
	[managedView reloadData];
	[appDelegate saveAction:self];
}

- (NSInteger)macro1Selected {
	return [self macroSelected:1];
}

- (void)setMacro1Selected:(NSInteger)state {
	[self setMacroSelected:state forIndex:1];
}

- (NSInteger)macro2Selected {
	return [self macroSelected:2];
}

- (void)setMacro2Selected:(NSInteger)state {
	[self setMacroSelected:state forIndex:2];
}

- (NSInteger)macro3Selected {
	return [self macroSelected:3];
}

- (void)setMacro3Selected:(NSInteger)state {
	[self setMacroSelected:state forIndex:3];
}
@end
