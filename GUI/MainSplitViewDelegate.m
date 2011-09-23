//
//  MainSplitViewDelegate.m
//  G15 Tools
//
//  Created by Phillip Hutchings on 4/11/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "MainSplitViewDelegate.h"


@implementation MainSplitViewDelegate
// http://bluerope.org/?p=5
-(NSRect)splitView:(NSSplitView *)splitView additionalEffectiveRectOfDividerAtIndex:(NSInteger)dividerIndex
{
	NSRect resizeBounds = [splitViewResizer bounds];
	resizeBounds.origin.x = resizeBounds.size.width - 15.0;
	resizeBounds.size.width = 15.0;
	return [splitViewResizer convertRect:resizeBounds toView:splitView];
}
@end
