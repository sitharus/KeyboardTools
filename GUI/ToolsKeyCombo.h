//
//  ToolsKeyCombo.h
//  G15 Tools
//
//  Created by Phillip Hutchings on 31/10/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ToolsKeyCombo : NSObject <NSCoding> {
	int keyCode;
	int flags;
}
@property(assign) int keyCode;
@property(assign) int flags;
- (id)initWithShortcutCombo:(id)combo;
@end
