//
//  MacroSelectorBackgroundView.m
//
//  Created by Phillip Hutchings on 18/12/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "MacroSelectorBackgroundView.h"

@implementation MacroSelectorBackgroundView
- (void)drawRect:(NSRect)rect {
	NSGradient *g = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:0.5 alpha:1]
												  endingColor:[NSColor colorWithCalibratedWhite:0.8 alpha:1]];
	[g drawInRect:[self bounds] angle:90];
}
@end
