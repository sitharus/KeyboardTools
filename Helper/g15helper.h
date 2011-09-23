//
//  g15helper.h
//  G15 Tools
//
//  Created by Phillip Hutchings on 30/10/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#include <IOKit/IOCFPlugIn.h>
#include <IOKit/hid/IOHIDKeys.h>
#include <CoreFoundation/CoreFoundation.h>
#import <IOKit/usb/IOUSBLib.h>
#import <IOKit/hid/IOHIDLib.h>
#import "KeyboardHelperProtocol.h"
#import "KeyboardClientProtocol.h"
#include "KeyboardToolsDefines.h"

#define kG15ReportBufferSize 9

@interface g15helper : NSObject <KeyboardHelperProtocol> {
	UInt32 locationId;
	
	io_service_t serviceId;
	IOUSBDeviceInterface182 **usbDevice;
	IOUSBInterfaceInterface182 **usbControlInterface;
	IOHIDDeviceInterface122 **hidDevice;
	IOHIDQueueInterface **hidQueue;
	UInt8 interruptEndpoint;
	UInt8 buffer[kG15ReportBufferSize];
	
	CFRunLoopSourceRef eventTapSource;
	CFMachPortRef eventTapPort;
	
	io_iterator_t deviceIterator;
	IONotificationPortRef notifyPort;
	
	NSObject<KeyboardClientProtocol> *delegate;
	NSConnection *helperConnection;
}
- (void)setupConnection;
- (void)connectionDied:(NSNotification *)notification;
- (void)initHIDInterface;
- (void)initDeviceInterface;
- (void)initDeviceControlInterface;
- (void)processReadData:(UInt32)inBufferSize;
- (void)deviceConnected:(io_service_t)device;
- (void)deviceDisconnected:(io_service_t)device;
- (void)monitorDeviceVendor:(long)vendor product:(long)product;
@end
