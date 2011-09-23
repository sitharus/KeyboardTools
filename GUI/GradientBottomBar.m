//
//  GradientBottomBar.m
//  G15 Tools
//
//  Created by Phillip Hutchings on 4/11/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "GradientBottomBar.h"


@implementation GradientBottomBar
//http://bluerope.org/?p=5
- (void)drawRect:(NSRect)rect
{
	// fill with gradient
	NSRect bounds = self.bounds;
	NSColor* color1 = [NSColor colorWithCalibratedWhite:0.992 alpha:1];
	NSColor* color2 = [NSColor colorWithCalibratedWhite:0.953 alpha:1];
	NSColor* color3 = [NSColor colorWithCalibratedWhite:0.902 alpha:1];
	NSColor* color4 = [NSColor colorWithCalibratedWhite:0.902 alpha:1];
	
	NSGradient* gradient = [[[NSGradient alloc] initWithColorsAndLocations:
							 color4, 0.0,
							 color3, 0.5,
							 color2, 0.51,
							 color1, 1.0,
							 nil]
							autorelease];
	[gradient drawInRect:bounds angle:90.0];
	
	// draw the top border
	NSColor* borderColor = [NSColor colorWithCalibratedWhite:(131.0/255.0) alpha:1];;
	[borderColor setStroke];
	CGFloat y = bounds.size.height;
	CGFloat x = bounds.size.width;
	[NSBezierPath strokeLineFromPoint:NSMakePoint(0.0, y-0.5)
							  toPoint:NSMakePoint(x, y-0.5)];
	
	// draw the grip lines
	NSColor* gripColor = [NSColor colorWithCalibratedWhite:0.361 alpha:1];
	NSColor* gripHighlightColor = [NSColor colorWithCalibratedWhite:0.953 alpha:1];
	NSInteger lineIndex;
	CGFloat lineXPos = x - 4.5;
	for (lineIndex = 0; lineIndex < 3; ++lineIndex)
	{
		[gripColor setStroke];
		[NSBezierPath strokeLineFromPoint:NSMakePoint(lineXPos, 6.5)
								  toPoint:NSMakePoint(lineXPos, y-6.5)];
		[gripHighlightColor setStroke];
		
		[NSBezierPath strokeLineFromPoint:NSMakePoint(lineXPos+1, 7.5)
								  toPoint:NSMakePoint(lineXPos+1, y-5.5)];
		lineXPos -= 3.0;
	}
}
@end
