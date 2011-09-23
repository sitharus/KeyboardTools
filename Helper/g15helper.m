//
//  g15helper.m
//  G15 Tools
//
//  Created by Phillip Hutchings on 30/10/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "g15helper.h"
#define kG15Vendor		0x046d
#define kG15Productv1	0xc222
#define kG15Productv2	0xc222


static char *darwin_error_str (int result) {
	switch (result) {
		case kIOReturnSuccess:
			return "no error";
		case kIOReturnNotOpen:
			return "device not opened for exclusive access";
		case kIOReturnNoDevice:
			return "no connection to an IOService";
		case kIOUSBNoAsyncPortErr:
			return "no async port has been opened for interface";
		case kIOReturnExclusiveAccess:
			return "another process has device opened for exclusive access";
		case kIOUSBPipeStalled:
			return "pipe is stalled";
		case kIOReturnError:
			return "could not establish a connection to the Darwin kernel";
		case kIOUSBTransactionTimeout:
			return "transaction timed out";
		case kIOReturnBadArgument:
			return "invalid argument";
		case kIOReturnAborted:
			return "transaction aborted";
		case kIOReturnNotResponding:
			return "device not responding";
		default:
			return "unknown error";
	}
}

void G15HIDReportCallbackFunction(void *inTarget, IOReturn inResult, void *inRefcon, void *inSender, uint32_t inBufferSize) {
	if (inResult == kIOReturnSuccess) {
		g15helper *device = (g15helper *)inTarget;
		[device processReadData:inBufferSize];
	}
}

CGEventRef G15EventTapCallback(CGEventTapProxy proxy, CGEventType type, CGEventRef event, void *refcon) {	
	int64_t keyboardType = CGEventGetIntegerValueField(event, kCGKeyboardEventKeyboardType);
	NSLog(@"Got Event! %lli", keyboardType);
	return event;
}

static void DeviceAdded(void *inRefCon, io_iterator_t inIterator) {
	g15helper *monitor = (g15helper *)inRefCon;
	io_service_t obj;
	
	while ((obj = IOIteratorNext(inIterator))) {
		[monitor deviceConnected:obj];
	}
}

static void DeviceRemoved(void *inRefCon, io_iterator_t inIterator) {
	g15helper *monitor = (g15helper *)inRefCon;
	io_service_t obj;
	
	while ((obj = IOIteratorNext(inIterator))) {
		[monitor deviceDisconnected: obj];
		IOObjectRelease(obj);
	}
}


int main(int argc, char *argv[]) {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	g15helper *helper = [[g15helper alloc] init];
	[helper setupConnection];
	
	[[NSNotificationCenter defaultCenter] addObserver:helper selector:@selector(connectionDied:) name:NSConnectionDidDieNotification object:nil];
	
	[helper monitorDeviceVendor:kG15Vendor product:kG15Productv1];
	[helper monitorDeviceVendor:kG15Vendor product:kG15Productv2];
	
    [[NSRunLoop mainRunLoop] run];
	[pool release];
}

@implementation g15helper

- (void)setupConnection {
	helperConnection = [[NSConnection alloc] init];
	[helperConnection setRootObject:self];
	if ([helperConnection registerName:@"com.sitharus.keyboardHelper"] == NO) {
		NSLog(@"Could not register connection, bailing");
		exit(0);
	}
}

- (void)connectionDied:(NSNotification *)notification {
	[delegate release];
	delegate = nil;
	NSLog(@"Connection went away, invalidating delegate");
}

- (void)setDelegate:(NSObject<KeyboardClientProtocol> *)newDelegate {
	delegate = newDelegate;
	[delegate retain];
}

- (void)setLCD:(G15Screen)lcd {
    
}

- (IOReturn)setLEDs:(int)ledSettings {
    unsigned char m_led_buf[4] = { 2, 4, 0, 0 };
//    m_led_buf[2] = ~(unsigned char)ledSettings;
//	IOUSBDevRequest request;
//	request.bmRequestType = USBmakebmRequestType(kUSBOut, kUSBClass, kUSBInterface);
//	request.bRequest = 9;
//	request.wValue = 0x302;
//	request.wIndex = 0;
//	request.wLength = 4;
//	request.pData = m_led_buf;
	return 0;
	
}

- (void)deviceConnected:(io_service_t)deviceService {
	serviceId = deviceService;
	
	NSMutableDictionary *properties = nil;
	IORegistryEntryCreateCFProperties(deviceService, (CFMutableDictionaryRef *)&properties, kCFAllocatorDefault, kNilOptions);
	[properties autorelease];
	
	NSNumber *location = [properties valueForKey: (NSString *)CFSTR(kIOHIDLocationIDKey)];
	locationId = location != nil ? [location unsignedLongValue] : 0;
	NSLog(@"Location: %ld", locationId);
	[self initHIDInterface];
	[self initDeviceInterface];
	
	if (hidDevice == nil || usbDevice == nil) {
		if (hidDevice != nil) {
			(*hidDevice)->close(hidDevice);
			(*hidDevice)->Release(hidDevice);
			hidDevice = nil;
		}
		if (usbDevice != nil) {
			(*usbDevice)->Release(usbDevice);
			usbDevice = nil;
		}		
	} else {
		CFRunLoopSourceRef eventSource;
		IOReturn result = kIOReturnError;	// assume failure (pessimist!)
		
		// Steal the device, it's ours now!
		if ((result = (*hidDevice)->open(hidDevice, kIOHIDOptionsTypeSeizeDevice)) == kIOReturnSuccess) {
			if ((result = (*hidDevice)->createAsyncEventSource(hidDevice, &eventSource)) != kIOReturnSuccess) {
				NSLog(@"completeStartup - createAsyncEventSource failed: %08x", result);
			} else {
				CFRunLoopAddSource(CFRunLoopGetCurrent(), eventSource, kCFRunLoopDefaultMode);
				result = (*hidDevice)->setInterruptReportHandlerCallback(hidDevice, buffer, kG15ReportBufferSize, G15HIDReportCallbackFunction, self, nil);
			}
		}
		
		if (result != kIOReturnSuccess) {
			NSLog(@"completeStartup failed: %08x", result);
		}
	}
}

- (void)deviceDisconnected:(io_service_t)deviceService {
	NSLog(@"Monitor reports keyboard disconnected");
	if (hidDevice != nil) {
		(*hidDevice)->close(hidDevice);
		(*hidDevice)->Release(hidDevice);
		hidDevice = nil;
	}
	if (usbDevice != nil) {
		(*usbDevice)->Release(usbDevice);
		usbDevice = nil;
	}
	if (eventTapPort) {
		CFMachPortInvalidate(eventTapPort);
		eventTapPort = nil;
	}
	if (eventTapSource) {
		CFRunLoopSourceInvalidate(eventTapSource);
		eventTapSource = nil;
	}
}

- (void)initHIDInterface {
	IOCFPlugInInterface **iodev = nil;
	IOReturn result;
    SInt32 score;
	
	result = IOCreatePlugInInterfaceForService(serviceId,  kIOHIDDeviceUserClientTypeID, kIOCFPlugInInterfaceID, &iodev, &score);
	
	if (result == kIOReturnSuccess) {
		IOHIDDeviceInterface122 **hidDeviceInterface;
		if ((result = (*iodev)->QueryInterface(iodev, CFUUIDGetUUIDBytes(kIOHIDDeviceInterfaceID122), (LPVOID) &hidDeviceInterface)) == kIOReturnSuccess) {
			hidDevice = hidDeviceInterface;
		}
		
		IODestroyPlugInInterface(iodev);
	}
	
	if (result != kIOReturnSuccess) {
		NSLog(@"initHIDInterface failed: %08x", result);
	}
}

- (void) initDeviceInterface {
	CFMutableDictionaryRef matchingDict;
	IOReturn result;
	
	if ((matchingDict = IOServiceMatching(kIOUSBDeviceClassName)) == nil) {
		NSLog(@"IOServiceMatching failed File %s Line %d", __FILE__, __LINE__);
		result = kIOReturnError;
	} else {
		NSMutableDictionary *dict = (NSMutableDictionary *)matchingDict;
		io_object_t newUsbDevice;
		
		//[dict setValue: [NSNumber numberWithLong: kG15Productv1] forKey:(NSString *)CFSTR(kUSBProductID)];
		[dict setValue: [NSNumber numberWithLong: kG15Vendor] forKey:(NSString *)CFSTR(kUSBVendorID)];
		
		if ((result = IOServiceGetMatchingServices(kIOMasterPortDefault, matchingDict, &deviceIterator)) == kIOReturnSuccess) {
			IOCFPlugInInterface **iodev = nil;
			SInt32 score;
			
			while ((newUsbDevice = IOIteratorNext(deviceIterator)) != (io_object_t)NULL && usbDevice == NULL) {
				result = IOCreatePlugInInterfaceForService(newUsbDevice, kIOUSBDeviceUserClientTypeID, kIOCFPlugInInterfaceID, &iodev, &score);
				
				if (result == kIOReturnSuccess) {
					IOUSBDeviceInterface182 **usbDeviceInterface;
					
					if ((result = (*iodev)->QueryInterface(iodev, CFUUIDGetUUIDBytes(kIOUSBDeviceInterfaceID182), (LPVOID) &usbDeviceInterface)) == kIOReturnSuccess) {
						UInt32 deviceLocationID;
						
						if ((result = (*usbDeviceInterface)->GetLocationID(usbDeviceInterface, &deviceLocationID)) == kIOReturnSuccess) {
							if (deviceLocationID == locationId) {
								usbDevice = usbDeviceInterface;
								[self initDeviceControlInterface];
							}
						}
					}
					
					if (usbDevice == nil) {
						IOObjectRelease(newUsbDevice);
					}
					
					IODestroyPlugInInterface(iodev);
				}
			}
			
			IOObjectRelease(deviceIterator);
		}
	}
	
	if (result != kIOReturnSuccess) {
		NSLog(@"initDeviceInterface failed: %08x", result);
	}
}

- (void)initDeviceControlInterface {
	if (usbDevice) {
		IOUSBFindInterfaceRequest f;
		io_iterator_t iter;
		IOCFPlugInInterface **plugInInterface = NULL;
		SInt32 score;
		
		f.bInterfaceClass = kIOUSBFindInterfaceDontCare;
		f.bInterfaceSubClass = kIOUSBFindInterfaceDontCare;
		f.bInterfaceProtocol = kIOUSBFindInterfaceDontCare;
		f.bAlternateSetting = kIOUSBFindInterfaceDontCare;
		
		io_service_t usbInterface = IO_OBJECT_NULL;
		IOReturn result = (*usbDevice)->CreateInterfaceIterator(usbDevice, &f, &iter);
		if (result != kIOReturnSuccess) {
			NSLog(@"Failed to create device iterator");
			return;
		}
		// G15 only has one interface.
		usbInterface = IOIteratorNext(iter);
		result = IOCreatePlugInInterfaceForService(usbInterface, kIOUSBInterfaceUserClientTypeID, kIOCFPlugInInterfaceID, &plugInInterface, &score);
		
		if (result != kIOReturnSuccess) {
			NSLog(@"Failed to create CFPluginInterface %i", result);
			return;
		}
		IOUSBInterfaceInterface182 **usbInterfaceInterface = 0;
		result = (*plugInInterface)->QueryInterface(plugInInterface, CFUUIDGetUUIDBytes(kIOUSBInterfaceInterfaceID),(LPVOID)&usbInterfaceInterface);
		(*plugInInterface)->Stop(plugInInterface);
		IODestroyPlugInInterface(plugInInterface);
		IOObjectRelease(usbInterface);
		IOObjectRelease(iter);
		if (result != kIOReturnSuccess) {
			NSLog(@"Failed to get Interface Interface");
			return;
		}
		usbControlInterface = usbInterfaceInterface;
		
		UInt8 numEndpoints = 0;
		result = (*usbControlInterface)->GetNumEndpoints(usbControlInterface, &numEndpoints);
		if (result != kIOReturnSuccess) {
			NSLog(@"Failed to get interface endpoints");
			return;
		}
	}
}

- (void)processReadData:(UInt32)inBufferSize {
	int pressed_keys = 0;
	
	switch (inBufferSize) {
		case 9:
			if (buffer[0] == 0x02)
			{
				if (buffer[1]&0x01) pressed_keys |= G15_KEY_G1;
				if (buffer[2]&0x02) pressed_keys |= G15_KEY_G2;
				if (buffer[3]&0x04) pressed_keys |= G15_KEY_G3;
				if (buffer[4]&0x08) pressed_keys |= G15_KEY_G4;
				if (buffer[5]&0x10) pressed_keys |= G15_KEY_G5;
				if (buffer[6]&0x20) pressed_keys |= G15_KEY_G6;
				if (buffer[2]&0x01) pressed_keys |= G15_KEY_G7;
				if (buffer[3]&0x02) pressed_keys |= G15_KEY_G8;
				if (buffer[4]&0x04) pressed_keys |= G15_KEY_G9;
				if (buffer[5]&0x08) pressed_keys |= G15_KEY_G10;
				if (buffer[6]&0x10) pressed_keys |= G15_KEY_G11;
				if (buffer[7]&0x20) pressed_keys |= G15_KEY_G12;
				if (buffer[1]&0x04) pressed_keys |= G15_KEY_G13;
				if (buffer[2]&0x08) pressed_keys |= G15_KEY_G14;
				if (buffer[3]&0x10) pressed_keys |= G15_KEY_G15;
				if (buffer[4]&0x20) pressed_keys |= G15_KEY_G16;
				if (buffer[5]&0x40) pressed_keys |= G15_KEY_G17;
				if (buffer[8]&0x40) pressed_keys |= G15_KEY_G18;
				if (buffer[6]&0x01) pressed_keys |= G15_KEY_M1;
				if (buffer[7]&0x02) pressed_keys |= G15_KEY_M2;
				if (buffer[8]&0x04) pressed_keys |= G15_KEY_M3;
				if (buffer[7]&0x40) pressed_keys |= G15_KEY_MR;
				if (buffer[8]&0x80) pressed_keys |= G15_KEY_L1;
				if (buffer[2]&0x80) pressed_keys |= G15_KEY_L2;
				if (buffer[3]&0x80) pressed_keys |= G15_KEY_L3;
				if (buffer[4]&0x80) pressed_keys |= G15_KEY_L4;
				if (buffer[5]&0x80) pressed_keys |= G15_KEY_L5;
				if (buffer[1]&0x80) pressed_keys |= G15_KEY_LIGHT;
			}
			break;
		case 5:
			if (buffer[0] == 0x02)
			{
				if (buffer[1]&0x01) pressed_keys |= G15_KEY_G1;
				if (buffer[1]&0x02) pressed_keys |= G15_KEY_G2;
				if (buffer[1]&0x04) pressed_keys |= G15_KEY_G3;
				if (buffer[1]&0x08) pressed_keys |= G15_KEY_G4;
				if (buffer[1]&0x10) pressed_keys |= G15_KEY_G5;
				if (buffer[1]&0x20) pressed_keys |= G15_KEY_G6;
				if (buffer[1]&0x40) pressed_keys |= G15_KEY_M1;
				if (buffer[1]&0x80) pressed_keys |= G15_KEY_M2;
				if (buffer[2]&0x20) pressed_keys |= G15_KEY_M3;
				if (buffer[2]&0x40) pressed_keys |= G15_KEY_MR;
				if (buffer[2]&0x80) pressed_keys |= G15_KEY_L1;
				if (buffer[2]&0x02) pressed_keys |= G15_KEY_L2;
				if (buffer[2]&0x04) pressed_keys |= G15_KEY_L3;
				if (buffer[2]&0x08) pressed_keys |= G15_KEY_L4;
				if (buffer[2]&0x10) pressed_keys |= G15_KEY_L5;
				if (buffer[2]&0x01) pressed_keys |= G15_KEY_LIGHT;
			}
			
	}

	
	if (delegate) {
		@try {
			[delegate handleKeypress:pressed_keys];				
		}
		@catch (NSException *e) {
			NSLog(@"Caught exception from delegate: %@", e);
		}
	}
}


- (void)monitorDeviceVendor:(long)vendor product:(long)product {
	CFMutableDictionaryRef matchingDict;
	IOReturn result;
	
	if ((matchingDict = IOServiceMatching(kIOHIDDeviceKey)) == nil) {
		NSLog(@"IOServiceMatching failed to initialise HIDDeviceKey");
	} else {
		NSMutableDictionary *dict = (NSMutableDictionary *)matchingDict;
		
		CFRetain(matchingDict);
		CFStringRef productStr = CFSTR(kIOHIDProductIDKey);
		CFStringRef vendorStr = CFSTR(kIOHIDVendorIDKey);
		[dict setValue: [NSNumber numberWithLong: product] forKey:(NSString *)productStr];
		[dict setValue: [NSNumber numberWithLong: vendor] forKey:(NSString *)vendorStr];
		
		if (!notifyPort) {
			notifyPort = IONotificationPortCreate(kIOMasterPortDefault);
		}
		result = IOServiceAddMatchingNotification(notifyPort, kIOFirstMatchNotification, matchingDict, &DeviceAdded, self, &deviceIterator);
		
		if (result != KERN_SUCCESS) {
			NSLog(@"IOServiceAddMatchingNotification failed result %08x", result);
			CFRelease(matchingDict);
		} else {
			DeviceAdded((void *)self, deviceIterator);
			result = IOServiceAddMatchingNotification(notifyPort, kIOTerminatedNotification, matchingDict, &DeviceRemoved, self, &deviceIterator);
			
			if (result != KERN_SUCCESS) {
				NSLog(@"IOServiceAddMatchingNotification failed result %08x", result);
			}  else {
				CFRunLoopSourceRef runLoopSource;
				
				DeviceRemoved((void *)self, deviceIterator);
				
				runLoopSource = IONotificationPortGetRunLoopSource(notifyPort);
				CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, kCFRunLoopDefaultMode);
			}
		}
	}
}

- (NSDictionary *)detailsForDevice:(io_service_t) device {
	CFMutableDictionaryRef hidProperties = 0;
	IOReturn result = IORegistryEntryCreateCFProperties(device, &hidProperties, kCFAllocatorDefault, kNilOptions);
	if ((result == KERN_SUCCESS) && hidProperties) {
		return (NSDictionary *)hidProperties;
	}
	return nil;
}

@end
