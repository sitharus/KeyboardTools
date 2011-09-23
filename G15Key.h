//
//  G15Key.h
//  G15 Tools
//
//  Created by Phillip Hutchings on 14/11/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface G15Key : NSObject<NSCoding> {
	int keyCode;
	NSString *keyLabel;
}
@property(readonly) int keyCode;
@property(readonly) NSString *keyLabel;
@property(readonly) int keyOrder;
- (id)initWithCode:(int)code label:(NSString *)label;
@end
