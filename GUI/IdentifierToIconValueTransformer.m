//
//  IdentifierToIconValueTransformer.m
//  KeyboardTools
//
//  Created by Phillip Hutchings on 20/12/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "IdentifierToIconValueTransformer.h"


@implementation IdentifierToIconValueTransformer
+ (Class)transformedValueClass {
	return [NSImage class];
}

+ (BOOL)allowsReverseTransformation {
	return NO;
}

- (id)transformedValue:(id)value {
	if (value == nil) {
		return nil;
	}
	if ([value isKindOfClass:[NSString class]]) {
		NSString *identifier = (NSString *)value;
		NSString *appPath = [[NSWorkspace sharedWorkspace] absolutePathForAppBundleWithIdentifier:identifier];
		return [[NSWorkspace sharedWorkspace] iconForFile:appPath];
	}
    return nil;
}
@end
