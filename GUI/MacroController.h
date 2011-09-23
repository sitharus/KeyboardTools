//
//  MacroController.h
//  G15 Tools
//
//  Created by Phillip Hutchings on 10/11/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Macro.h"
#import "ToolsAppDelegate.h"
#import "KeyCapView.h"
#import "MacroListStripeView.h"
#import "G15Key.h"


@interface MacroController : NSObject {
	IBOutlet MacroListStripeView *macroView;
	IBOutlet NSBox *macroCustomArea;
	IBOutlet KeyCapView *keyName;
	Macro *macro;
	ToolsAppDelegate *appDelegate;
	NSView *keypressView;
	G15Key *key;
}
@property(assign) Macro *macro;
@property(assign) ToolsAppDelegate *appDelegate;
@property(assign) G15Key *key;
@property(readonly) MacroListStripeView *macroView;
- (void)loadNib;
- (void)setupMacroCustomArea;
- (void)setKey:(G15Key *)k;
@end
