//
//  MacroListStripeView.m
//  G15 Tools
//
//  Created by Phillip Hutchings on 12/11/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "MacroListStripeView.h"


@implementation MacroListStripeView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)drawRect:(NSRect)rect {
	NSArray *colours = [NSColor controlAlternatingRowBackgroundColors];
	int stripe = [[[self superview] subviews] indexOfObject:self] % [colours count];
	NSColor *background = [colours objectAtIndex:stripe];
	[background set];
	NSRectFill(rect);
    [super drawRect:rect];
}

@end
