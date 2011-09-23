//
//  KeypressActionProvider.m
//  G15 Tools
//
//  Created by Phillip Hutchings on 3/11/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "KeypressActionProvider.h"
#import "KeypressAction.h"


@implementation KeypressActionProvider

+ (NSObject<KeyboardActionProvider> *)sharedInstance {
	static KeypressActionProvider *shared;
	if (!shared) {
		shared = [[KeypressActionProvider alloc] init];
	}
	return shared;
}

- (NSString *)title {
	return @"Keypress";
}

- (NSString *)description {
	return @"Press a key";
}

- (NSImage *)image {
	return nil;
}

- (NSObject<KeyboardAction> *)newAction {
	return [[[KeypressAction alloc] init] autorelease];
}

// These two are hacks for the NSCollectionView bindings - they copy.
- (void)encodeWithCoder:(NSCoder *)coder {
}

- (id)initWithCoder:(NSCoder *)coder {
	return [KeypressActionProvider sharedInstance];
}
@end
