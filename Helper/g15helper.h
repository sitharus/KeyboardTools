//
//  g15helper.h
//  G15 Tools
//
//  Created by Phillip Hutchings on 30/10/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#include <CoreFoundation/CoreFoundation.h>
#include <IOKit/hid/IOHIDKeys.h>
#import <IOKit/hid/IOHIDLib.h>
#include <IOKit/IOCFPlugIn.h>
#import <IOKit/usb/IOUSBLib.h> 
#import "KeyboardHelperProtocol.h"
#import "KeyboardClientProtocol.h"
#include "KeyboardToolsDefines.h"

#define kG15ReportBufferSize 64

@interface g15helper : NSObject <KeyboardHelperProtocol> {
	uint8_t buffer[kG15ReportBufferSize];
	
	CFRunLoopSourceRef eventTapSource;
	CFMachPortRef eventTapPort;
	
	IONotificationPortRef notifyPort;
	
	NSObject<KeyboardClientProtocol> *delegate;
	NSConnection *helperConnection;
    IOHIDManagerRef hidManager;
    IOHIDDeviceRef currentDevice;
}
@property(readwrite, nonatomic) IOHIDManagerRef hidManager;
@property(readwrite, nonatomic) IOHIDDeviceRef currentDevice;

- (void)setupConnection;
- (void)connectionDied:(NSNotification *)notification;
- (void)processReport:(uint8_t *)report ofLength:(int)length type:(IOHIDReportType)reportType;
- (void)monitorDeviceVendor:(long)vendor product:(long)product;
- (void)registerDevice:(IOHIDDeviceRef) device;
- (void)unregisterDevice:(IOHIDDeviceRef) device;
@end
