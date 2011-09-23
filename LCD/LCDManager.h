//
//  LCDVendor.h
//  G15 Tools
//
//  Created by Phillip Hutchings on 8/12/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "KeyboardLcd.h"
#import "KeyboardLcdManager.h"

@interface LCDManager : NSObject <KeyboardLcdManager> {
	NSMutableDictionary *applicationLcds;
	NSString *currentApplication;
	NSMutableArray *sortedApplicationList; // So we rotate apps in a predictable manner
}

@end
