// 
//  MacroSet.m
//  G15 Tools
//
//  Created by Phillip Hutchings on 4/11/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "MacroSet.h"


@implementation MacroSet 

@dynamic macroGroup;
@dynamic macroSets;
@dynamic macroSet;
@dynamic macros;
@dynamic name;
@dynamic macroIndex;

- (NSComparisonResult)compareSetToSet:(MacroSet *)other {
	if (self.macroIndex == nil || [self.macroIndex intValue] == 0) {
		return NSOrderedDescending;
	} else if (other.macroIndex == nil || [other.macroIndex intValue] == 0) {
		return NSOrderedAscending;
	} else {
		int selfValue = [self.macroIndex intValue];
		int otherValue = [other.macroIndex intValue];
		if (selfValue == otherValue) {
			return NSOrderedSame;
		} else if (selfValue > otherValue) {
			return NSOrderedDescending;
		} else {
			return NSOrderedAscending;
		}
	}
	return NSOrderedDescending;
	
}

@end
