//
//  KeyboardLcdManager.h
//  KeyboardTools
//
//  Created by Phillip Hutchings on 4/01/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class KeyboardLcd;
@protocol KeyboardLcdManager
- (KeyboardLcd *)lcdConnectionForApplicationName:(NSString *)application;

@end
