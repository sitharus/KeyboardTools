//
//  KeyCollectionView.h
//  G15 Tools
//
//  Created by Phillip Hutchings on 14/11/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#include "ToolsAppDelegate.h"

@interface KeyCollectionView : NSCollectionView {
	IBOutlet NSArrayController *contentArrayController;
	BOOL dragInProgress;
	NSString *dragTypeString;
	NSPoint startLocation;
}
- (id)viewAtPoint:(NSPoint)pt excludingView:(id)eView;
- (id)selectedObject;
- (NSArray *)selectedObjects;
- (NSView *)selectedView;
- (NSArray *)selectedViews;
- (NSArray *)reversedSubviews;
- (NSArray *)reversedContent;
@end
