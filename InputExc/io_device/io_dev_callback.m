//
//  io_hid_callback.m
//  InputExc
//

#import <Foundation/Foundation.h>
#import <IOKit/hid/IOHIDLib.h>

#import "io_dev_attacher.h"
#import "io_dev_callback.h"

#import "InputExc-Swift.h"


void input_callback(void* ctx, IOReturn result, void* sender, IOHIDValueRef raw_value)
{
    IODevCallback* self = (__bridge IODevCallback *)(ctx);
    AppBridge* bridge = (AppBridge*)self.io_dev_attacher.bridge;

    
    const IOHIDElementRef element = IOHIDValueGetElement(raw_value);
    
    const SInt32 usage = IOHIDElementGetUsage(element);
    const SInt32 value = (SInt32)IOHIDValueGetIntegerValue(raw_value);

    [bridge evt_device_inputWithDevice:self.io_device usage:usage value:value];
}


@implementation IODevCallback


@synthesize io_dev_attacher = ref_io_dev_attacher;
@synthesize io_device = ref_io_device;


- (IOReturn) open:(IODevAttacher*)ref_io_dev_attacher IOHIDDeviceRef:(IOHIDDeviceRef)ref_io_device
{
    self -> ref_io_dev_attacher = ref_io_dev_attacher;
    self -> ref_io_device = ref_io_device;
    self -> last_return = 0;

    IOHIDDeviceRegisterInputValueCallback(
                                          self -> ref_io_device,
                                          input_callback,
                                          (__bridge void * _Nullable)self
                                          );

    IOHIDDeviceScheduleWithRunLoop(ref_io_device, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
    self -> last_return = IOHIDDeviceOpen(ref_io_device, kIOHIDOptionsTypeNone);


    return self -> last_return;
}


- (IOReturn) close
{
    self -> last_return = 0;
    
    if(self -> ref_io_device != nil)
    {
        IOHIDDeviceUnscheduleFromRunLoop(self -> ref_io_device, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
        last_return = IOHIDDeviceClose(self -> ref_io_device, kIOHIDOptionsTypeNone);

        self -> ref_io_device = nil;
    }
    
    return self -> last_return;
}


- (void) dealloc
{
    [self close];
}


@end


// [EOF]
