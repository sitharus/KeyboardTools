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

static void deviceMatchingCallback(void *inContext, IOReturn result, void *sender, IOHIDDeviceRef device) {
    
    printf("Registering Device");
    [(g15helper *)inContext registerDevice:device];
}

static void deviceRemovedCallback(void *inContext, IOReturn result, void *sender, IOHIDDeviceRef device) {
    [(g15helper *)inContext unregisterDevice:device];
}

static void specificDeviceRemovalCallback(void *inContext, IOReturn inResult, void * inSender) {
    [(g15helper *)inContext unregisterDevice:(IOHIDDeviceRef)inSender];
}

static void deviceIOHIDReportCallback(void *inContext, IOReturn inResult, void *inSender, IOHIDReportType inType, uint32_t inReportID, uint8_t *inReport, CFIndex         inReportLength)
{
    [(g15helper *)inContext processReport:inReport ofLength:inReportLength type:inType];
}


int main(int argc, char *argv[]) {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    printf("Foo?");
    
    IOHIDManagerRef tIOHIDManagerRef = IOHIDManagerCreate(kCFAllocatorDefault, kIOHIDOptionsTypeNone);
    
	
	g15helper *helper = [[g15helper alloc] init];
    helper.hidManager = tIOHIDManagerRef;
    
    NSLog(@"Starting monitoring");
    IOHIDManagerRegisterDeviceMatchingCallback(tIOHIDManagerRef, deviceMatchingCallback, helper);
    IOHIDManagerRegisterDeviceRemovalCallback(tIOHIDManagerRef, deviceRemovedCallback, helper);
    IOHIDManagerScheduleWithRunLoop(tIOHIDManagerRef, CFRunLoopGetMain(), kCFRunLoopCommonModes);
	
	[[NSNotificationCenter defaultCenter] addObserver:helper selector:@selector(connectionDied:) name:NSConnectionDidDieNotification object:nil];
	
	[helper setupConnection];
	[helper monitorDeviceVendor:kG15Vendor product:kG15Productv1];
	
    [[NSRunLoop mainRunLoop] run];
	[pool drain];
}

@implementation g15helper
@synthesize hidManager, currentDevice;
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
    m_led_buf[2] = ~(unsigned char)ledSettings;
	IOUSBDevRequest request;
	request.bmRequestType = USBmakebmRequestType(kUSBOut, kUSBClass, kUSBInterface);
    request.bRequest = 9;
	request.wValue = 0x302;
	request.wIndex = 0;
	request.wLength = 4;
	request.pData = m_led_buf;
    //io_service_t service = IOHIDDeviceGetService(currentDevice);
    
	return kIOReturnSuccess;
}

- (void)processReport:(uint8_t *)report ofLength:(int)length type:(IOHIDReportType)reportType {
	int pressed_keys = 0;
	
    switch (length) {
        case 9:
			if (report[0] == 0x02)
			{
				if (report[1]&0x01) pressed_keys |= G15_KEY_G1;
				if (report[2]&0x02) pressed_keys |= G15_KEY_G2;
				if (report[3]&0x04) pressed_keys |= G15_KEY_G3;
				if (report[4]&0x08) pressed_keys |= G15_KEY_G4;
				if (report[5]&0x10) pressed_keys |= G15_KEY_G5;
				if (report[6]&0x20) pressed_keys |= G15_KEY_G6;
				if (report[2]&0x01) pressed_keys |= G15_KEY_G7;
				if (report[3]&0x02) pressed_keys |= G15_KEY_G8;
				if (report[4]&0x04) pressed_keys |= G15_KEY_G9;
				if (report[5]&0x08) pressed_keys |= G15_KEY_G10;
				if (report[6]&0x10) pressed_keys |= G15_KEY_G11;
				if (report[7]&0x20) pressed_keys |= G15_KEY_G12;
				if (report[1]&0x04) pressed_keys |= G15_KEY_G13;
				if (report[2]&0x08) pressed_keys |= G15_KEY_G14;
				if (report[3]&0x10) pressed_keys |= G15_KEY_G15;
				if (report[4]&0x20) pressed_keys |= G15_KEY_G16;
				if (report[5]&0x40) pressed_keys |= G15_KEY_G17;
				if (report[8]&0x40) pressed_keys |= G15_KEY_G18;
				if (report[6]&0x01) pressed_keys |= G15_KEY_M1;
				if (report[7]&0x02) pressed_keys |= G15_KEY_M2;
				if (report[8]&0x04) pressed_keys |= G15_KEY_M3;
				if (report[7]&0x40) pressed_keys |= G15_KEY_MR;
				if (report[8]&0x80) pressed_keys |= G15_KEY_L1;
				if (report[2]&0x80) pressed_keys |= G15_KEY_L2;
				if (report[3]&0x80) pressed_keys |= G15_KEY_L3;
				if (report[4]&0x80) pressed_keys |= G15_KEY_L4;
				if (report[5]&0x80) pressed_keys |= G15_KEY_L5;
				if (report[1]&0x80) pressed_keys |= G15_KEY_LIGHT;
			}
            break;
        case 5:
			if (report[0] == 0x02)
			{
				if (report[1]&0x01) pressed_keys |= G15_KEY_G1;
				if (report[1]&0x02) pressed_keys |= G15_KEY_G2;
				if (report[1]&0x04) pressed_keys |= G15_KEY_G3;
				if (report[1]&0x08) pressed_keys |= G15_KEY_G4;
				if (report[1]&0x10) pressed_keys |= G15_KEY_G5;
				if (report[1]&0x20) pressed_keys |= G15_KEY_G6;
				if (report[1]&0x40) pressed_keys |= G15_KEY_M1;
				if (report[1]&0x80) pressed_keys |= G15_KEY_M2;
				if (report[2]&0x20) pressed_keys |= G15_KEY_M3;
				if (report[2]&0x40) pressed_keys |= G15_KEY_MR;
				if (report[2]&0x80) pressed_keys |= G15_KEY_L1;
				if (report[2]&0x02) pressed_keys |= G15_KEY_L2;
				if (report[2]&0x04) pressed_keys |= G15_KEY_L3;
				if (report[2]&0x08) pressed_keys |= G15_KEY_L4;
				if (report[2]&0x10) pressed_keys |= G15_KEY_L5;
				if (report[2]&0x01) pressed_keys |= G15_KEY_LIGHT;
			}

        default:
            break;
    }
    NSLog(@"Pressed keys! %i", pressed_keys);
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
    
    CFMutableDictionaryRef matchingDict = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    
    CFNumberRef vendorIdRef = CFNumberCreate(kCFAllocatorDefault, kCFNumberLongType, &vendor);
    CFDictionarySetValue(matchingDict, CFSTR(kIOHIDVendorIDKey), vendorIdRef);
    CFRelease(vendorIdRef);
    
    CFNumberRef productIdRef = CFNumberCreate(kCFAllocatorDefault, kCFNumberLongType, &product);
    CFDictionarySetValue(matchingDict, CFSTR(kIOHIDProductIDKey), productIdRef);
    CFRelease(productIdRef);
    
    IOHIDManagerSetDeviceMatching(hidManager, matchingDict);
    if (matchingDict) CFRelease(matchingDict);
}

- (void)registerDevice:(IOHIDDeviceRef) device {
    if (self.currentDevice) {
        IOHIDDeviceUnscheduleFromRunLoop(self.currentDevice, CFRunLoopGetMain(), kCFRunLoopCommonModes);
    }
    
    IOReturn result = IOHIDDeviceOpen(device, kIOHIDOptionsTypeSeizeDevice);
    if (result == kIOReturnSuccess) {
        IOHIDDeviceRegisterRemovalCallback(device, specificDeviceRemovalCallback, self);
        IOHIDDeviceRegisterInputReportCallback(device, buffer, kG15ReportBufferSize, deviceIOHIDReportCallback, self);
        IOHIDDeviceScheduleWithRunLoop(device, CFRunLoopGetMain(), kCFRunLoopCommonModes);
        
        self.currentDevice = device;
        [self initDeviceControlInterface];
    } else {
        NSLog(@"Registration failed! %i", result);
    }
}

- (void)unregisterDevice:(IOHIDDeviceRef) device {
    IOHIDDeviceUnscheduleFromRunLoop(self.currentDevice, CFRunLoopGetMain(), kCFRunLoopCommonModes);
    self.currentDevice = NULL;
}



- (NSDictionary *)detailsForDevice:(io_service_t) device {
    return NULL;
}

@end
