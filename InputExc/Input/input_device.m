//
//  input_device.m
//  InputExc
//

// ----------------------------------------------------------------- import(s)
#import <CoreFoundation/CoreFoundation.h>
#import <IOKit/hid/IOHIDLib.h>
#import <Cocoa/Cocoa.h>

#import "Action/action.h"
#import "Action/action_list.h"
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
    CFDictionarySetValue(dict_result, @kIOHIDDeviceUsagePageKey, ref_page);
    CFRelease(ref_page);

    CFNumberRef ref_usage = CFNumberCreate(kCFAllocatorDefault, kCFNumberIntType, &usage);
    CFDictionarySetValue(dict_result, @kIOHIDDeviceUsageKey, ref_usage);
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

    const IOHIDElementRef element = IOHIDValueGetElement(value);
    
    const SInt32 type = IOHIDElementGetType(element);
    const SInt32 page = IOHIDElementGetUsagePage(element);
    const SInt32 usage = IOHIDElementGetUsage(element);
    const SInt32 i_value = (SInt32)IOHIDValueGetIntegerValue(value);

    CFNumberRef ref_k = CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt32Type, &usage);
    CFNumberRef ref_v = CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt32Type, &i_value);
    CFNumberRef cmp_v = CFDictionaryGetValue(self -> dict_event_guard, ref_k);
    bool bEventDup = false;

    if(cmp_v == NULL)
    {
        bEventDup = false;
    } else {
        bEventDup = ref_v == cmp_v;
    }

    CFDictionarySetValue(self -> dict_event_guard, ref_k, ref_v);

    if(self -> b_enable && bEventDup == false)
    {
        //OCBridge* self_oc_bridge = (OCBridge *)self -> ref_oc_bridge;

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
    CFRange range = CFRangeMake(0, CFArrayGetCount(self -> ary_ref_device));

    if(CFArrayGetFirstIndexOfValue(self -> ary_ref_device, range, device) == -1)
    {
        OCBridge* self_oc_bridge = (OCBridge *)self -> ref_oc_bridge;
        SInt32 v = 0;
        SInt32 p = 0;
        
        CFNumberRef ref_vend = IOHIDDeviceGetProperty(
                               device,
                               CFSTR(kIOHIDVendorIDKey)
                               );
        if(ref_vend) CFNumberGetValue(ref_vend, kCFNumberSInt32Type, &v);

        CFNumberRef ref_prod = IOHIDDeviceGetProperty(
                               device,
                               CFSTR(kIOHIDProductIDKey)
                               );
        if(ref_prod) CFNumberGetValue(ref_prod, kCFNumberSInt32Type, &p);

        CFStringRef ref_name = IOHIDDeviceGetProperty(
                               device,
                               CFSTR(kIOHIDProductKey)
                               );
        if(ref_name)
        {
            CFIndex len = CFStringGetLength(ref_name);
            CFIndex maxSize = CFStringGetMaximumSizeForEncoding(len, kCFStringEncodingUTF8);
            char* name = malloc(maxSize + 1);

            CFStringGetCString(ref_name, name, maxSize, kCFStringEncodingUTF8);

            NSLog(@"request VendorID[%04X] : ProductID[%04X] : %s", v, p, name);

            if([self_oc_bridge device_compareWithProduct:(__bridge NSString * _Nonnull)(ref_name)] == true)
            {
                IOHIDDeviceRegisterInputValueCallback(
                                                      device,
                                                      input_callback,
                                                      (__bridge void * _Nullable)(self)
                                                      );

                IOHIDDeviceScheduleWithRunLoop(device, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
                IOReturn io_result = IOHIDDeviceOpen(device, kIOHIDOptionsTypeNone);

                if(io_result == 0)
                {
                    [self_oc_bridge update_device_infoWithVendor_id:v product_id:p vendor:(__bridge NSString * _Nonnull)(ref_name)];
                    [self_oc_bridge update_connection_statusWithConnection_status:@"Connected"];
                    
                    CFArrayAppendValue(self -> ary_ref_device, device);

                    NSLog(@"connect VendorID[%04X] : ProductID[%04X] : %s", v, p, name);

                } else {
                    [self_oc_bridge update_connection_statusWithConnection_status:@"IOHIDDeviceOpen error"];
                }
            }

            free(name);
        }
    }
}


void evt_device_detach(void* ctx, IOReturn inResult, void* inSender, IOHIDDeviceRef device)
{
    InputDevice* self = (__bridge InputDevice*)ctx;
    const CFIndex ary_size = CFArrayGetCount(self -> ary_ref_device);
    CFIndex i;

    for(i = 0; i < ary_size; i ++)
    {
        const IOHIDDeviceRef ref_device = CFArrayGetValueAtIndex(self -> ary_ref_device, i);
    
        if(ref_device == device)
        {
            OCBridge* self_oc_bridge = (OCBridge *)self -> ref_oc_bridge;

            [self_oc_bridge update_connection_statusWithConnection_status:@"Disconnected"];
            [self_oc_bridge update_device_infoWithVendor_id:0 product_id:0 vendor:@""];

            IOHIDDeviceClose(ref_device, kIOHIDOptionsTypeNone);
            
            CFArrayRemoveValueAtIndex(self -> ary_ref_device, i);

            break;
        }
    }
}


- (id) init {

    if(self = [super init])
    {
        ary_ref_device = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
        dict_event_guard = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);

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
    create_mutable_dict(ary_match, kHIDPage_GenericDesktop, kHIDUsage_GD_Keyboard);

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
        [self_oc_bridge update_connection_statusWithConnection_status:@"IOHIDManagerOpen error"];
    }
}


- (void) epi_proc {
    IOHIDManagerClose(ref_manager, kIOHIDOptionsTypeNone);
}


- (void) set_enable:(BOOL)b_enable {

    self -> b_enable = b_enable;
}


@end

