//
//  input_device.m
//  InputExc
//

// ----------------------------------------------------------------- import(s)
#import <CoreFoundation/CoreFoundation.h>
#import <IOKit/hid/IOHIDLib.h>
#import <Cocoa/Cocoa.h>

#import "Action/action.h"
#import "input_source.h"
#import "input_device.h"

#import "InputExc-Swift.h"


static void create_mutable_dict(CFMutableArrayRef ary_match, UInt32 page, UInt32 usage)
{
    CFMutableDictionaryRef dict_result = CFDictionaryCreateMutable(
                                                                   kCFAllocatorDefault,
                                                                   0,
                                                                   &kCFTypeDictionaryKeyCallBacks,
                                                                   &kCFTypeDictionaryValueCallBacks
                                                                   );

    CFNumberRef ref_page = CFNumberCreate(kCFAllocatorDefault, kCFNumberIntType, &page);
    CFDictionarySetValue(dict_result, CFSTR(kIOHIDDeviceUsagePageKey), ref_page);
    CFRelease(ref_page);

    CFNumberRef ref_usage = CFNumberCreate(kCFAllocatorDefault, kCFNumberIntType, &usage);
    CFDictionarySetValue(dict_result, CFSTR(kIOHIDDeviceUsageKey), ref_usage);
    CFRelease(ref_usage);

    CFArrayAppendValue(ary_match, dict_result);

    CFRelease(dict_result);
}


@implementation InputDevice

@synthesize oc_bridge = ref_oc_bridge;
@synthesize input_source = ref_input_source;


void input_callback(void* ctx, IOReturn inResult, void* inSender, IOHIDValueRef value)
{
    InputDevice* self = (__bridge InputDevice *)ctx;
    //OCBridge* self_oc_bridge = self -> ref_oc_bridge;

    if(self -> b_enable) {

        IOHIDElementRef element = IOHIDValueGetElement(value);

        SInt32 type = IOHIDElementGetType(element);
        SInt32 page = IOHIDElementGetUsagePage(element);
        SInt32 usage = IOHIDElementGetUsage(element);
        SInt32 i_value = (SInt32)IOHIDValueGetIntegerValue(value);
            
        ActionSequence* seq = [self->ref_input_source sequnece_get:usage];

        if(seq != nil)
        {
            const CFIndex ary_count = CFArrayGetCount(seq->ary_action);

            for(CFIndex i = 0; i < ary_count; i ++)
            {
                Action* act = CFArrayGetValueAtIndex(seq->ary_action, i);
                [act event_dispatch:i_value];
            }
        }

        NSLog(@"type %04x, page %04x, usage %04x, value %d\n", type, page, usage, i_value);
    }
}


void evt_device_attach(void* ctx, IOReturn inResult, void* inSender, IOHIDDeviceRef device)
{
    InputDevice* self = (__bridge InputDevice*)ctx;

    
    if(self -> ref_device == nil)
    {
        OCBridge* self_oc_bridge = (OCBridge *)self -> ref_oc_bridge;

        [self_oc_bridge device_name_setWithName:@"Connected"];

        IOHIDDeviceRegisterInputValueCallback(
                                              device,
                                              input_callback,
                                              (__bridge void * _Nullable)(self)
                                              );

        IOHIDDeviceScheduleWithRunLoop(device, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
        IOReturn io_result = IOHIDDeviceOpen(device, kIOHIDOptionsTypeNone);

        if(io_result != 0)
        {
            [self_oc_bridge device_name_setWithName:@"IOHIDDeviceOpen error"];
        }

        self -> ref_device = device;
    }
}


void evt_device_detach(void* ctx, IOReturn inResult, void* inSender, IOHIDDeviceRef device)
{
    InputDevice* self = (__bridge InputDevice*)ctx;


    if(self -> ref_device == device)
    {
        OCBridge* self_oc_bridge = (OCBridge *)self -> ref_oc_bridge;

        [self_oc_bridge device_name_setWithName:@"Disconnected"];

        IOHIDDeviceClose(self -> ref_device, kIOHIDOptionsTypeNone);
        self -> ref_device = nil;
    }
}


- (id) init {

    if(self = [super init])
    {
        ref_device = nil;

        ref_oc_bridge = nil;
        ref_input_source = nil;
        b_enable = false;
    }

    return self;
}


- (void) pro_proc {
    
    assert(ref_input_source != nil);

    ref_manager = IOHIDManagerCreate(kCFAllocatorDefault, kIOHIDOptionsTypeNone);

    CFMutableArrayRef ary_match = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);

    create_mutable_dict(ary_match, kHIDPage_GenericDesktop, kHIDUsage_GD_GamePad);
    create_mutable_dict(ary_match, kHIDPage_GenericDesktop, kHIDUsage_GD_Joystick);
    create_mutable_dict(ary_match, kHIDPage_GenericDesktop, kHIDUsage_GD_MultiAxisController);
    
    IOHIDManagerSetDeviceMatchingMultiple(ref_manager, ary_match);
    CFRelease(ary_match);

    IOHIDManagerRegisterDeviceMatchingCallback(
                                               ref_manager,
                                               evt_device_attach,
                                               (__bridge void * _Nullable)(self)
                                               );
    IOHIDManagerRegisterDeviceRemovalCallback(
                                              ref_manager,
                                              evt_device_detach,
                                              (__bridge void * _Nullable)(self)
                                              );

    IOHIDManagerScheduleWithRunLoop(ref_manager, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
    IOReturn io_result = IOHIDManagerOpen(ref_manager, kIOHIDOptionsTypeNone);
    
    if(io_result != 0)
    {
        OCBridge* self_oc_bridge = (OCBridge *)self -> ref_oc_bridge;
        [self_oc_bridge device_name_setWithName:@"IOHIDManagerOpen error"];
    }
}


- (void) epi_proc {
}


- (void) set_enable:(BOOL)b_enable {

    self -> b_enable = b_enable;
}


@end

