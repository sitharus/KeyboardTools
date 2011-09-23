//
//  KeyboardLcd.h
//  KeyboardTools
//
//  Created by Phillip Hutchings on 22/12/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "KeyboardLcdDelegate.h"

@interface KeyboardLcd : NSObject {
	NSObject<KeyboardLcdDelegate> *delegate;
}
@property(assign) NSObject<KeyboardLcdDelegate> *delegate;
- (void)willBecomeActive;
- (void)didBecomeActive;
- (void)keyDown:(int)keyCode;
- (void)keyUp:(int)keyCode;
- (void)ping;
@end
