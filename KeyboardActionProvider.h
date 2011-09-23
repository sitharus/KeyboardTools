//
//  KeyboardActionProvider.h
//  G15 Tools
//
//  Created by Phillip Hutchings on 3/11/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "KeyboardAction.h"

@protocol KeyboardActionProvider
+ (NSObject<KeyboardActionProvider> *)sharedInstance;
- (NSString *)title;
- (NSString *)description;
- (NSImage *)image;
- (NSObject<KeyboardAction> *)newAction;
@end
