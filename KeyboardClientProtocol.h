//
//  G15ClientProtocol.h
//  G15 Tools
//
//  Created by Phillip Hutchings on 30/10/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@protocol KeyboardClientProtocol

- (void)handleKeypress:(int)keys;
@end
