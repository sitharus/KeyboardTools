//
//  Macro.h
//  G15 Tools
//
//  Created by Phillip Hutchings on 4/11/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "KeyboardAction.h"
#import "KeyboardActionProvider.h"
#import "NullAction.h"
#import "ToolsAppDelegate.h"
#import "G15Key.h"
@class MacroSet;

@interface Macro : NSManagedObject {
	NSObject<KeyboardAction> *_keyAction;
	G15Key *keyDetails;
}
- (void)actionUpdated;
@property(retain) NSData *action;
@property(retain) NSNumber *triggerKey;
@property(retain) MacroSet *macroSet;
@property(retain) NSData *key;
@property(readonly) NSObject<KeyboardAction> *keyAction;
@property(assign) G15Key *keyDetails;
@end



