//
//  KeyboardLcdDelegate.h
//  KeyboardTools
//
//  Created by Phillip Hutchings on 22/12/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@protocol KeyboardLcdDelegate
- (void)ping;
@optional
- (void)willBecomeActive;
- (void)didBecomeActive;
- (void)keyDown:(int)keyCode;
- (void)keyUp:(int)keyCode;
@end
