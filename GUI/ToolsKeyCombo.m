//
//  ToolsKeyCombo.m
//  G15 Tools
//
//  Created by Phillip Hutchings on 31/10/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "ToolsKeyCombo.h"


@implementation ToolsKeyCombo
@synthesize keyCode, flags;

- (void)encodeWithCoder:(NSCoder *)encoder {
	[encoder encodeInt:keyCode forKey:@"keycode"];
	[encoder encodeInt:flags forKey:@"flags"];
	NSLog(@"EncodeWithCoder!");
	NSLog(@"keyCode: %i %i", keyCode, flags);
}

- (id)initWithCoder:(NSCoder *)encoder {
	NSLog(@"InitWithCoder!");
	if ((self = [super init]) != nil) {
		keyCode = [encoder decodeIntForKey:@"keycode"];
		flags = [encoder decodeIntForKey:@"flags"];	
		NSLog(@"keyCode: %i %i", keyCode, flags);
	}
	return self;
}

- (id)initWithShortcutCombo:(id)combo {
	if ((self = [super init]) != nil) {
	}
	return self;
}
@end
