//
//  KeypressAction.h
//  G15 Tools
//
//  Created by Phillip Hutchings on 3/11/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "KeyboardAction.h"
#import "KeypressActionProvider.h"
#import "Macro.h"

@interface KeypressAction : NSObject<KeyboardAction, NSCoding> {
	IBOutlet NSView *keypressView;
	id combo;
	BOOL keyComboSet;
	Macro *currentMacro;
}
@end
