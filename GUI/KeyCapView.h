//
//  KeyCapView.h
//  G15 Tools
//
//  Created by Phillip Hutchings on 12/11/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#include "ToolsAppDelegate.h"
#include "G15Key.h"

@class MacroController;

@interface KeyCapView : NSView{
	NSString *keyName;
	NSDictionary *fontSettings;
	NSImage *keyCap;
	IBOutlet MacroController *controller;
	BOOL drawFocusRing;
}
@property(assign) NSString *keyName;
@end
