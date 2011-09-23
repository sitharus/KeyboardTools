// 
//  Macro.m
//  G15 Tools
//
//  Created by Phillip Hutchings on 4/11/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "Macro.h"

#import "MacroSet.h"

@implementation Macro 

@dynamic action;
@dynamic key;
@dynamic triggerKey;
@dynamic macroSet;
@dynamic keyAction;
@dynamic keyDetails;

- (NSObject<KeyboardAction> *)keyAction {
	if (_keyAction) {
		return _keyAction;
	}
	if (self.action == nil || [self.action length] == 0) {
		_keyAction = [[NullAction alloc] init];
	} else {
		_keyAction = [NSKeyedUnarchiver unarchiveObjectWithData:self.action];
		
	}
	[_keyAction setMacro:self];
	
	return _keyAction;
}

- (NSObject<KeyboardActionProvider> *)keyActionProvider {
	NSObject<KeyboardAction> *action = self.keyAction;
	return (NSObject<KeyboardActionProvider> *)[action provider];
}

- (void)setKeyActionProvider:(NSObject<KeyboardActionProvider> *)newProvider {
	[self willChangeValueForKey:@"keyAction"];
	[self willChangeValueForKey:@"keyActionProvider"];
	_keyAction = nil;
	NSObject<KeyboardAction> *newAction = [newProvider newAction];
	[newAction setMacro:self];
	self.action = [NSKeyedArchiver archivedDataWithRootObject:newAction];
	[(ToolsAppDelegate *)[[NSApplication sharedApplication] delegate] saveAction:self];
	
	[self didChangeValueForKey:@"keyAction"];
	[self didChangeValueForKey:@"keyActionProvider"];
}

- (void)actionUpdated {
	self.action = [NSKeyedArchiver archivedDataWithRootObject:_keyAction];
	[(ToolsAppDelegate *)[[NSApplication sharedApplication] delegate] saveAction:self];
}

- (G15Key *)keyDetails {
	if (!keyDetails) {
		if (self.key == nil || [self.key length] == 0) {
			return nil;
		} else {
			keyDetails = [NSKeyedUnarchiver unarchiveObjectWithData:self.key];
		}
	}
	return keyDetails;
}

- (void)setKeyDetails:(G15Key *)k {
	[self willChangeValueForKey:@"keyDetails"];
	keyDetails = k;
	NSData *d = [NSKeyedArchiver archivedDataWithRootObject:k];
	self.key = d;
	[self didChangeValueForKey:@"keyDetails"];
}

@end
