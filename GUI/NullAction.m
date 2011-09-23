//
//  NullAction.m
//  G15 Tools
//
//  Created by Phillip Hutchings on 10/11/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "NullAction.h"


@implementation NullAction

- (NSObject *)provider {
	return [NullActionProvider sharedInstance];
}

- (void)keyUp {
	
}

- (void)keyDown {
	
}

- (NSString *)description {
	return @"";
}

- (NSView *)view {
	return nil;
}

- (void)setMacro:(Macro *)m {
	
}

- (void)encodeWithCoder:(NSCoder *)coder {
	
}

- (id)initWithCoder:(NSCoder *)coder {
	if ((self = [super init]) != nil) {
		
	}
	return self;
}

@end
