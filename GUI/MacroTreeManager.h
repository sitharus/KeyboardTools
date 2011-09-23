//
//  MacroTreeDataSource.h
//  G15 Tools
//
//  Created by Phillip Hutchings on 4/11/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ToolsAppDelegate.h"
#import "MacroGroup.h"
#import "MacroSet.h"
#import "Macro.h"
#import "MacroController.h"
#import "MacroApplication.h"

@interface MacroTreeManager : NSObject {
	IBOutlet ToolsAppDelegate *appDelegate;
	IBOutlet NSOutlineView *managedView;
	IBOutlet NSTabView *managedTabs;
	IBOutlet NSScrollView *macroList;
	IBOutlet NSView *macroListView;
	IBOutlet NSWindow *mainWindow;
	NSManagedObjectContext *objectContext;
	NSArray *rootObjects;
	NSArray *currentMacros;
	NSMutableArray *currentMacroControllers;
	MacroGroup *currentGroup;
}
@property(assign) NSArray *currentMacros;
@property(assign) MacroGroup *currentGroup;
- (IBAction)addGroup:(id)sender;
- (IBAction)addSet:(id)sender;
- (Macro *)addMacro:(G15Key *)k;
- (void)refetchData;
- (void)repopulateMacroList;

- (IBAction)addApplication:(id)sender;

- (NSInteger)macroSelected:(NSInteger)macroIndex;
- (void)setMacroSelected:(NSInteger)state forIndex:(NSInteger)macroIndex;

- (NSInteger)macro1Selected;
- (void)setMacro1Selected:(NSInteger)state;
- (NSInteger)macro2Selected;
- (void)setMacro2Selected:(NSInteger)state;
- (NSInteger)macro3Selected;
- (void)setMacro3Selected:(NSInteger)state;
@end
