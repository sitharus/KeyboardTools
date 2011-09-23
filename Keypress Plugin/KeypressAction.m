//
//  KeypressAction.m
//  G15 Tools
//
//  Created by Phillip Hutchings on 3/11/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "KeypressAction.h"


@implementation KeypressAction
- (NSObject *)provider {
	return [KeypressActionProvider sharedInstance];
}

- (void)keyUp {
//	int flags = combo.flags;
//	
//	if (flags & NSShiftKeyMask) {
//		CGEventRef shiftEvent = CGEventCreateKeyboardEvent(nil, (CGKeyCode)56, false);
//		CGEventPost(kCGSessionEventTap, shiftEvent);
//		CFRelease(shiftEvent);
//	}
//	if (flags & NSAlternateKeyMask) {
//		CGEventRef shiftEvent = CGEventCreateKeyboardEvent(nil, (CGKeyCode)58, false);
//		CGEventPost(kCGSessionEventTap, shiftEvent);
//		CFRelease(shiftEvent);
//	}
//	if (flags & NSControlKeyMask) {
//		CGEventRef shiftEvent = CGEventCreateKeyboardEvent(nil, (CGKeyCode)59, false);
//		CGEventPost(kCGSessionEventTap, shiftEvent);
//		CFRelease(shiftEvent);
//	}
//	if (flags & NSCommandKeyMask) {
//		CGEventRef shiftEvent = CGEventCreateKeyboardEvent(nil, (CGKeyCode)55, false);
//		CGEventPost(kCGSessionEventTap, shiftEvent);
//		CFRelease(shiftEvent);
//	}
//	
//	CGEventRef event = CGEventCreateKeyboardEvent(nil, (CGKeyCode)combo.code, false);
//	CGEventPost(kCGSessionEventTap, event);
//	CFRelease(event);
	
}

- (void)keyDown {
//	int flags = combo.flags;
//	CGEventRef event = CGEventCreateKeyboardEvent(nil, (CGKeyCode)combo.code, true);
//	CGEventSetType(event, kCGEventKeyDown);
//
//	CGEventFlags eventFlags = 0;
//	if (flags & NSCommandKeyMask) {
//		CGEventRef shiftEvent = CGEventCreateKeyboardEvent(nil, (CGKeyCode)55, true);
//		CGEventPost(kCGSessionEventTap, shiftEvent);
//		CFRelease(shiftEvent);
//		eventFlags |= kCGEventFlagMaskCommand;
//	} 
//	if (flags & NSAlternateKeyMask) {
//		CGEventRef shiftEvent = CGEventCreateKeyboardEvent(nil, (CGKeyCode)58, true);
//		CGEventPost(kCGSessionEventTap, shiftEvent);
//		CFRelease(shiftEvent);
//		eventFlags |= kCGEventFlagMaskAlternate;
//	}
//	if (flags & NSShiftKeyMask) {
//		CGEventRef shiftEvent = CGEventCreateKeyboardEvent(nil, (CGKeyCode)56, true);
//		CGEventPost(kCGSessionEventTap, shiftEvent);
//		CFRelease(shiftEvent);
//		eventFlags |= kCGEventFlagMaskShift;
//	}
//	if (flags & NSControlKeyMask) {
//		CGEventRef shiftEvent = CGEventCreateKeyboardEvent(nil, (CGKeyCode)59, true);
//		CGEventPost(kCGSessionEventTap, shiftEvent);
//		CFRelease(shiftEvent);
//		eventFlags |= kCGEventFlagMaskControl;
//	}
//	CGEventSetFlags(event, eventFlags);
//
//	CGEventPost(kCGSessionEventTap, event);	
//	CFRelease(event);
}

- (NSString *)description {
	return @"Simple Keypress";
}

- (NSView *)view {
	if (!keypressView) {
		[NSBundle loadNibNamed:@"KeypressSettings" owner:self];
		if (keyComboSet) {
		} else {
		}
		
	}
	return keypressView;
}

- (void)shortcutRecorder:(id)recorder keyComboDidChange:(id)newKeyCombo {
	combo = newKeyCombo;
	[currentMacro actionUpdated];
}

- (void)setMacro:(Macro *)m {
	currentMacro = m;
}

- (void)encodeWithCoder:(NSCoder *)coder {
	[coder encodeBool:keyComboSet forKey:@"comboSet"];
	[coder encodeBytes:(uint8_t*)&combo length:sizeof(combo) forKey:@"combo"];
}

- (id)initWithCoder:(NSCoder *)coder {
	if ((self = [super init]) != nil) {
		keyComboSet = [coder decodeBoolForKey:@"comboSet"];
		//NSUInteger length;
		if (keyComboSet) {
		}
	}
	return self;
}
@end
