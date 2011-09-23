//
//  KeyboardHelperProtocol.h
//  G15 Tools
//
//  Created by Phillip Hutchings on 30/10/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "KeyboardClientProtocol.h"
#import "KeyboardToolsDefines.h"


@protocol KeyboardHelperProtocol
- (void)setDelegate:(NSObject<KeyboardClientProtocol> *)delegate;
- (void)setLCD:(G15Screen)lcd;
- (IOReturn)setLEDs:(int)ledSettings;
@end
