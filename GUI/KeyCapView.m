//
//  KeyCapView.m
//  G15 Tools
//
//  Created by Phillip Hutchings on 12/11/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "KeyCapView.h"
#import "MacroController.h"

@implementation KeyCapView
@synthesize keyName;
+ (void)initialize
{
	[KeyCapView exposeBinding:@"keyName"];
}

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		keyCap = [NSImage imageNamed:@"key"];
		[self registerForDraggedTypes:[NSArray arrayWithObject:kKeyDragType]];
    }
    return self;
}

- (void)awakeFromNib {
	fontSettings = [NSDictionary dictionaryWithObjectsAndKeys:[NSFont fontWithName:@"Lucida Grande" size:17.0], NSFontAttributeName, 
					[NSColor colorWithCalibratedRed:0.6 green:0.69 blue:0.88 alpha:1.0], NSForegroundColorAttributeName, nil];
}

- (void)drawRect:(NSRect)rect {
	NSRect keyCapRect = NSMakeRect(0, 0, 0, 0);
	NSRect bounds = [self bounds];
	keyCapRect.size = [keyCap size];
	[keyCap drawInRect:bounds fromRect:keyCapRect operation:NSCompositeSourceOver fraction:1.0];
	if (keyName) {
		NSSize s = [keyName sizeWithAttributes:fontSettings];
		float x = (bounds.size.width/2) - (s.width/2);
		float y = (bounds.size.height/2) - (s.height/2);
		[keyName drawAtPoint:NSMakePoint(x, y) withAttributes:fontSettings];
	}
	

	if (drawFocusRing) {
		[NSGraphicsContext saveGraphicsState];		
		NSSetFocusRingStyle(NSFocusRingOnly);
		NSRectFill(rect);
		[NSGraphicsContext restoreGraphicsState];	
	}
}

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender {
    if ((NSDragOperationGeneric & [sender draggingSourceOperationMask]) == NSDragOperationGeneric) {
		drawFocusRing = YES;
		[self setNeedsDisplay:YES];
		[[self superview] setNeedsDisplay:YES];
        return NSDragOperationGeneric;
    } else {
        return NSDragOperationNone;
    }
}

- (void)draggingExited:(id <NSDraggingInfo>)sender {
	drawFocusRing = NO;
	[self setNeedsDisplay:YES];
	[[self superview] setNeedsDisplay:YES];
}

- (NSDragOperation)draggingUpdated:(id <NSDraggingInfo>)sender {
    if ((NSDragOperationGeneric & [sender draggingSourceOperationMask]) == NSDragOperationGeneric) {
        return NSDragOperationGeneric;
    } else {
        return NSDragOperationNone;
    }
}

- (void)draggingEnded:(id <NSDraggingInfo>)sender {
	drawFocusRing = NO;
	[self setNeedsDisplay:YES];
	[[self superview] setNeedsDisplay:YES];
}

- (BOOL)prepareForDragOperation:(id <NSDraggingInfo>)sender {
    return YES;
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender {
	[self performSelector:@selector(showFocusRing) withObject:nil afterDelay:0.1];
	[self performSelector:@selector(hideFocusRing) withObject:nil afterDelay:0.2];
	[self performSelector:@selector(showFocusRing) withObject:nil afterDelay:0.3];
	[self performSelector:@selector(hideFocusRing) withObject:nil afterDelay:0.4];
	NSData *d = [[sender draggingPasteboard] propertyListForType:kKeyDragType];
	G15Key *k = [NSKeyedUnarchiver unarchiveObjectWithData:d];
	[controller setKey:k];
    return YES;
}

- (void)showFocusRing {
	drawFocusRing = YES;
	[self setNeedsDisplay:YES];
	[[self superview] setNeedsDisplay:YES];
}

- (void)hideFocusRing {
	drawFocusRing = NO;
	[self setNeedsDisplay:YES];
	[[self superview] setNeedsDisplay:YES];
}

@end
