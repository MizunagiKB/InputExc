//
//  input_device.m
//  InputExc
//

// ----------------------------------------------------------------- import(s)
#import <CoreFoundation/CoreFoundation.h>
#import <IOKit/hid/IOHIDLib.h>
#import <Cocoa/Cocoa.h>
#import <Carbon/Carbon.h>

#import "input_device.h"

#import "InputExc-Swift.h"


const UInt8* get_keyboard_layout()
{
    TISInputSourceRef source_curr;
    CFDataRef layout;

    source_curr = TISCopyCurrentKeyboardInputSource();
    layout = TISGetInputSourceProperty(
                                       source_curr,
                                       kTISPropertyUnicodeKeyLayoutData
                                       );
    if(layout == nil)
    {
        source_curr = TISCopyCurrentKeyboardLayoutInputSource();
        layout = TISGetInputSourceProperty(
                                           source_curr,
                                           kTISPropertyUnicodeKeyLayoutData
                                           );
        if(layout == nil)
        {
            return nil;
        }
    }
    
    return CFDataGetBytePtr(layout);
}


CFMutableDictionaryRef create_kb_table()
{
    CFMutableDictionaryRef dict_result;
    UInt32 i;
    UCKeyboardLayout* kb_layout;

    dict_result = CFDictionaryCreateMutable(
                                            kCFAllocatorDefault,
                                            0,
                                            &kCFTypeDictionaryKeyCallBacks,
                                            &kCFTypeDictionaryValueCallBacks
                                            );

    kb_layout = (UCKeyboardLayout *)get_keyboard_layout();

    for(i = 0; i < 128; i++)
    {
        UInt32 keysDown = 0;
        UniChar c[4];
        UniCharCount realLength;

        UCKeyTranslate(
                       kb_layout,
                       i,
                       kUCKeyActionDisplay,
                       0,
                       LMGetKbdType(),
                       kUCKeyTranslateNoDeadKeysBit,
                       &keysDown,
                       sizeof(c) / sizeof(c[0]),
                       &realLength,
                       c
                       );

        CFStringRef s = CFStringCreateWithCharacters(kCFAllocatorDefault, c, 1);

        if(s != NULL)
        {
            const CFNumberRef ref_code = CFNumberCreate(kCFAllocatorDefault, kCFNumberIntType, &i);

            CFDictionarySetValue(dict_result, s, ref_code);

            CFRelease(ref_code);
            CFRelease(s);
        }
    }

    return dict_result;
}


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


typedef struct TagCDeviceCallback
{
    InputDevice* p_input_device;

    IOHIDDeviceRef ref_device;
    CFMutableDictionaryRef dict_event_guard;
} CDeviceCallback;


@implementation InputDevice

@synthesize bridge = ref_bridge;


void input_callback(void* ctx, IOReturn result, void* sender, IOHIDValueRef raw_value)
{
    CDeviceCallback* self = ctx;
    AppBridge* bridge = (AppBridge*)self -> p_input_device -> ref_bridge;

    
    const IOHIDElementRef element = IOHIDValueGetElement(raw_value);
    
    //const SInt32 type = IOHIDElementGetType(element);
    //const SInt32 page = IOHIDElementGetUsagePage(element);
    const SInt32 usage = IOHIDElementGetUsage(element);
    const SInt32 value = (SInt32)IOHIDValueGetIntegerValue(raw_value);

    {
        //OCBridge* self_oc_bridge = (OCBridge *)self -> ref_oc_bridge;

//        ActionSequence* seq = [self->ref_input_source sequnece_get:usage];
//
  //      if(seq != nil)
    //    {
      //      const CFIndex ary_count = CFArrayGetCount(seq->ary_action);

        //    for(CFIndex i = 0; i < ary_count; i ++)
          //  {
            //    Action* act = CFArrayGetValueAtIndex(seq->ary_action, i);
              //  [act event_dispatch:i_value];
//            }
  //      }

    }

    [bridge evt_device_inputWithDevice:self -> ref_device usage:usage value:value];
}


void evt_device_attach(void* ctx, IOReturn result, void* sender, IOHIDDeviceRef ref_device)
{
    InputDevice* self = (__bridge InputDevice*)ctx;
    AppBridge* bridge = (AppBridge*)self.bridge;


    [bridge append_deviceWithDevice:ref_device];
}


void evt_device_detach(void* ctx, IOReturn result, void* sender, IOHIDDeviceRef ref_device)
{
    InputDevice* self = (__bridge InputDevice*)ctx;
    AppBridge* bridge = (AppBridge*)self.bridge;

    
    [bridge remove_deviceWithDevice:ref_device];
}


- (id) init {

    if(self = [super init])
    {
        dict_kb_table = create_kb_table();

        ref_bridge = nil;
        dict_callback = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, NULL);
        b_enable = false;
    }

    return self;
}


- (void) pro_proc {
    
    //assert(ref_input_source != nil);

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
        //OCBridge* self_oc_bridge = (OCBridge *)self -> ref_oc_bridge;
        //[self_oc_bridge update_connection_statusWithConnection_status:@"IOHIDManagerOpen error"];
    }
}


- (void) epi_proc {
    IOHIDManagerClose(ref_manager, kIOHIDOptionsTypeNone);
}


- (BOOL) device_open:(IOHIDDeviceRef)ref_device
{
    CDeviceCallback* p_callback;
    
    p_callback = malloc(sizeof(CDeviceCallback));
    p_callback -> p_input_device = self;
    p_callback -> ref_device = ref_device;
    p_callback -> dict_event_guard = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    
    
    CFDictionarySetValue(dict_callback, ref_device, p_callback);
    
    
    IOHIDDeviceRegisterInputValueCallback(
                                          ref_device,
                                          input_callback,
                                          p_callback
                                          );

    IOHIDDeviceScheduleWithRunLoop(ref_device, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
    IOReturn io_result = IOHIDDeviceOpen(ref_device, kIOHIDOptionsTypeNone);

    
    return io_result == 0;
}


- (BOOL) device_close:(IOHIDDeviceRef)ref_device
{
    CDeviceCallback* p_callback = (CDeviceCallback *)CFDictionaryGetValue(dict_callback, ref_device);

    if(p_callback != NULL)
    {
        p_callback -> p_input_device = NULL;
        p_callback -> ref_device = nil;
        CFDictionaryRemoveAllValues(p_callback -> dict_event_guard);
        
        CFRelease(p_callback -> dict_event_guard);

        CFDictionaryRemoveValue(dict_callback, ref_device);
        
        free(p_callback);
        
        IOHIDDeviceUnscheduleFromRunLoop(ref_device, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
        
        IOHIDDeviceClose(ref_device, kIOHIDOptionsTypeNone);
    }
    
    return true;
}


- (CGKeyCode) CharacterToKeycode:(NSString*)s
{
    CFNumberRef ref_n;
    CGKeyCode code;
    UniChar uchar = s.UTF8String[0];
    CFStringRef s_one = NULL;

    if ([s isEqualToString:@"TAB"]) return kVK_Tab;
    if ([s isEqualToString:@"SPACE"]) return kVK_Space;
    if ([s isEqualToString:@"DELETE"]) return kVK_Delete;
    if ([s isEqualToString:@"ESCAPE"]) return kVK_Escape;
    if ([s isEqualToString:@"END"]) return kVK_End;

    if ([s isEqualToString:@"F1"]) return kVK_F1;
    if ([s isEqualToString:@"F2"]) return kVK_F2;
    if ([s isEqualToString:@"F4"]) return kVK_F4;
    if ([s isEqualToString:@"F3"]) return kVK_F3;
    if ([s isEqualToString:@"F5"]) return kVK_F5;
    if ([s isEqualToString:@"F6"]) return kVK_F6;
    if ([s isEqualToString:@"F7"]) return kVK_F7;
    if ([s isEqualToString:@"F8"]) return kVK_F8;
    if ([s isEqualToString:@"F9"]) return kVK_F9;
    if ([s isEqualToString:@"F10"]) return kVK_F10;
    if ([s isEqualToString:@"F11"]) return kVK_F11;
    if ([s isEqualToString:@"F12"]) return kVK_F12;

    if ([s isEqualToString:@"HELP"]) return kVK_Help;
    if ([s isEqualToString:@"HOME"]) return kVK_Home;
    if ([s isEqualToString:@"PGUP"]) return kVK_PageUp;
    if ([s isEqualToString:@"PGDN"]) return kVK_PageDown;

    if ([s isEqualToString:@"LEFT"]) return kVK_LeftArrow;
    if ([s isEqualToString:@"RIGHT"]) return kVK_RightArrow;
    if ([s isEqualToString:@"DOWN"]) return kVK_DownArrow;
    if ([s isEqualToString:@"UP"]) return kVK_UpArrow;

    if(s.length > 1) return UINT16_MAX;

    
    s_one = CFStringCreateWithCharacters(kCFAllocatorDefault, &uchar, 1);
    
    ref_n = CFDictionaryGetValue(dict_kb_table, s_one);

    if(ref_n == nil)
    {
        code = UINT16_MAX;
    } else {
        CFNumberGetValue(ref_n, kCFNumberSInt16Type, &code);
    }

    CFRelease(s_one);


    return code;
}


@end

