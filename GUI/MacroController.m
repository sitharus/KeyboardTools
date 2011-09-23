//
//  MacroController.m
//  G15 Tools
//
//  Created by Phillip Hutchings on 10/11/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "MacroController.h"


@implementation MacroController
@synthesize macro, macroView, appDelegate, key;

- (void)loadNib {
	[NSBundle loadNibNamed:@"MacroView" owner:self];
	if (macro) {
		[macro addObserver:self forKeyPath:@"keyAction" options:NSKeyValueObservingOptionNew context:nil];
		[macro addObserver:self forKeyPath:@"keyDetails" options:NSKeyValueObservingOptionNew context:nil];
		
	}

	[self setupMacroCustomArea];
	
	if (key) {
		keyName.keyName = key.keyLabel;
	} else {
		keyName.keyName = @"??";
	}
	
}

- (void)setupMacroCustomArea {
	if (macro) {
		NSView *macroCustomView = [macro.keyAction view];
		NSRect macroSourceRect = [macroCustomView frame];
		NSRect macroDestRect = [macroCustomArea frame];
		if (macroSourceRect.size.height > macroDestRect.size.height) {
			float difference = macroSourceRect.size.height - macroDestRect.size.height;
			macroDestRect.size.height = macroSourceRect.size.height;
			NSRect viewRect = [macroView frame];
			viewRect.size.height += difference;
			[macroView setFrameSize:viewRect.size];
			[macroCustomArea setFrameSize:macroDestRect.size];
			
		}
		[macroCustomArea setContentView:macroCustomView];	
	}
}

- (void)setKey:(G15Key *)k {
	[self willChangeValueForKey:@"key"];
	if (macro) {
		macro.triggerKey = [NSNumber numberWithInt:k.keyCode];
		macro.keyDetails = k;	
	}
	key = k;
	[self didChangeValueForKey:@"key"];
}

- (void)finalize {
	if (macro) {
		[macro removeObserver:self forKeyPath:@"keyAction"];
		[macro removeObserver:self forKeyPath:@"keyDetails"];		
	}
	[super finalize];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if (object == macro && [keyPath isEqualToString:@"keyAction"]) {
		[self setupMacroCustomArea];
	} else if (object == macro && [keyPath isEqualToString:@"keyDetails"]) {
		G15Key *k = macro.keyDetails;
		if (k) {
			keyName.keyName = k.keyLabel;
		} else {
			keyName.keyName = @"??";
		}
	} else {
		
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
}
@end
