//
//  NullActionProvider.m
//  G15 Tools
//
//  Created by Phillip Hutchings on 10/11/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "NullActionProvider.h"


@implementation NullActionProvider

+ (NSObject<KeyboardActionProvider> *)sharedInstance {
	static NullActionProvider *shared;
	if (!shared) {
		shared = [[NullActionProvider alloc] init];
	}
	return shared;
}

- (NSString *)title {
	return @"None";
}

- (NSString *)description {
	return @"Do nothing";
}

- (NSImage *)image {
	return nil;
}

- (NSObject<KeyboardAction> *)newAction {
	return [[[NullAction alloc] init] autorelease];
}

// These two are hacks for the NSCollectionView bindings - they copy.
- (void)encodeWithCoder:(NSCoder *)coder {
}

- (id)initWithCoder:(NSCoder *)coder {
	return [NullActionProvider sharedInstance];
}
@end
