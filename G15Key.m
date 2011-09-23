//
//  G15Key.m
//  G15 Tools
//
//  Created by Phillip Hutchings on 14/11/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "G15Key.h"


@implementation G15Key
@synthesize keyLabel, keyCode;
@dynamic keyOrder;
- (id)initWithCode:(int)code label:(NSString *)label {
	if ((self = [super init]) != nil) {
		keyCode = code;
		keyLabel = [label copy];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)c {
	[c encodeInt:keyCode forKey:@"code"];
	[c encodeObject:keyLabel forKey:@"label"];
}

- (int)keyOrder {
	return keyCode;
}

- (id)initWithCoder:(NSCoder *)c {
	if ((self = [super init]) != nil) {
		keyLabel = [c decodeObjectForKey:@"label"];
		keyCode = [c decodeIntForKey:@"code"];
	}
	return self;
}
@end
