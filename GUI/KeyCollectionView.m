//
//  KeyCollectionView.m
//  G15 Tools
//
//  Created by Phillip Hutchings on 14/11/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "KeyCollectionView.h"


@implementation KeyCollectionView
- (id)viewAtPoint:(NSPoint)pt excludingView:(id)eView {
	for( NSView * view in [self subviews] ) {
		if( view != eView && [self mouse:pt inRect:[view frame]] ) {
			return (view);
		}
	}
	
	return nil;
}

- (void)simulateSingleClickWithEvent:(NSEvent *)aEvent {
	NSView *target = [self viewAtPoint:[self convertPoint:[aEvent locationInWindow] fromView:nil] excludingView:nil];
	
	NSIndexSet *indexSet = nil;
	if (target) {
		indexSet = [NSIndexSet indexSetWithIndex:[[self subviews] count]-([[self subviews] indexOfObject:target]+1)];
	} else {
		[[self window] makeFirstResponder:self];
	}
	[self setSelectionIndexes:indexSet];
}

- (void)mouseDown:(NSEvent *)aEvent {
	[self simulateSingleClickWithEvent:aEvent];
	startLocation = [aEvent locationInWindow];
}

- (void)mouseDragged:(NSEvent *)aEvent {
	NSAssert(contentArrayController != nil, @"no contentArrayController was assigned to ImagesCollectionView!");
	
	id selectedObject = [self selectedObject];
	
	NSPasteboard *pboard = [NSPasteboard pasteboardWithName:NSDragPboard];
	[pboard declareTypes:[NSArray arrayWithObject:kKeyDragType] owner:nil];
	[pboard setPropertyList:[NSKeyedArchiver archivedDataWithRootObject:selectedObject] forType:kKeyDragType];
		
		// lock focus on the image and draw into it
	NSPoint position = [self convertPoint:startLocation fromView:nil];
	
	NSView *selectedView = [self selectedView];	
	NSImage *image = [[NSImage alloc] initWithSize:[selectedView frame].size];
	
	[selectedView lockFocus];
	NSBitmapImageRep *r = [[NSBitmapImageRep alloc] initWithFocusedViewRect:[selectedView bounds]];
	[selectedView unlockFocus];
	[image addRepresentation:r];
		
		// activate the drag image
	[self dragImage: image
				 at: position
			 offset: NSZeroSize
			  event: aEvent
		 pasteboard: pboard
			 source: self
		  slideBack: YES]; // use 'snap back' animation if drop doesn't complete
	
}

- (void)mouseUp:(NSEvent *)aEvent {
	dragInProgress = NO;
	
    [self setNeedsDisplay:YES];
}

- (id)selectedObject {
	NSArray *selectedObjects = [self selectedObjects];
	
	if( [selectedObjects count] < 1 ) {
		return nil;
	}
	
	return [selectedObjects objectAtIndex:0];
}

- (NSArray *)selectedObjects {
	return [[self reversedContent] objectsAtIndexes:[self selectionIndexes]];
}

- (NSView *)selectedView {
	if( [[self selectedViews] count] < 1 ) {
		return nil;
	}
	
	return [[self selectedViews] objectAtIndex:0];
}

- (NSArray *)selectedViews {
	return [[self reversedSubviews] objectsAtIndexes:[self selectionIndexes]];
}

- (NSArray *)reversedSubviews {
	NSArray *currentSubviews = [self subviews];
	NSMutableArray *reversedSubviews = [NSMutableArray arrayWithCapacity:[currentSubviews count]];
	for (id obj in currentSubviews) {
		[reversedSubviews insertObject:obj atIndex:0];
	}
	return reversedSubviews;
}

- (NSArray *)reversedContent {
	NSArray *currentContent = [self content];
	NSMutableArray *reversedContent = [NSMutableArray arrayWithCapacity:[currentContent count]];
	for (id obj in currentContent) {
		[reversedContent insertObject:obj atIndex:0];
	}
	return reversedContent;
}


- (NSDragOperation)draggingSourceOperationMaskForLocal:(BOOL)isLocal {
	if (isLocal) {
		return NSDragOperationGeneric;
	}
	return NSDragOperationGeneric;
}


- (void)setDragTypeString:(NSString *)aString {
	[aString retain];
	[dragTypeString release];
	dragTypeString = aString;
	[self registerForDraggedTypes:[NSArray arrayWithObject:dragTypeString]];
}
@end
