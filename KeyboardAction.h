//
//  KeyboardAction.h
//  G15 Tools
//
//  Created by Phillip Hutchings on 3/11/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class Macro;
@protocol KeyboardAction
- (NSObject *)provider;
- (void)keyUp;
- (void)keyDown;
- (NSString *)description;
- (NSView *)view;
- (void)setMacro:(Macro *)m;
@end
