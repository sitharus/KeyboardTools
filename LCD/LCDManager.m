//
//  LCDVendor.m
//  G15 Tools
//
//  Created by Phillip Hutchings on 8/12/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "LCDManager.h"


@implementation LCDManager
- (id)init {
	if ((self = [super init]) != nil) {
		applicationLcds = [[NSMutableDictionary alloc] initWithCapacity:10];
		sortedApplicationList = [[NSMutableArray alloc] initWithCapacity:10];
	}
	return self;
}

- (void)pingConnections {
	NSMutableArray *keysToRemove = [NSMutableArray arrayWithCapacity:10];
	for (NSString *key in applicationLcds) {
		@try {
			[[applicationLcds objectForKey:key] ping];
		} @catch (NSException *e) {
			if ([[e name] isEqual:NSPortTimeoutException]) {
				[keysToRemove addObject:key];
 			}
		}
	}
	if ([keysToRemove containsObject:currentApplication]) {
		currentApplication = nil; // TODO: Handle gracefully
	}
	[applicationLcds removeObjectsForKeys:keysToRemove];
	[sortedApplicationList removeObjectsInArray:keysToRemove];
}

- (KeyboardLcd *)lcdConnectionForApplicationName:(NSString *)application {
	return nil;
}

- (void)applicationChangePressed {
	[(KeyboardLcd *)[applicationLcds objectForKey:currentApplication] willBecomeActive];
	int currentIndex = [sortedApplicationList indexOfObject:currentApplication];
	currentIndex++;
	if (currentIndex > [sortedApplicationList count]) {
		currentIndex = 0;
	}
	currentApplication = [sortedApplicationList objectAtIndex:currentIndex];
	[(KeyboardLcd *)[applicationLcds objectForKey:currentApplication] didBecomeActive];
}

- (void)keyDown:(int)keyCode {
	if (currentApplication) {
		[(KeyboardLcd *)[applicationLcds objectForKey:currentApplication] keyDown:keyCode];
	}
}

- (void)keyUp:(int)keyCode {
	if (currentApplication) {
		[(KeyboardLcd *)[applicationLcds objectForKey:currentApplication] keyUp:keyCode];
	}
}
@end
