//
//  input_device.m
//  InputExc
//

// ----------------------------------------------------------------- import(s)
#import <Foundation/Foundation.h>
#import <IOKit/hid/IOHIDLib.h>
#import <Cocoa/Cocoa.h>
#import <Carbon/Carbon.h>

#import "io_dev_attacher.h"
#import "io_dev_callback.h"

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


@implementation IODevAttacher


@synthesize bridge = ref_bridge;


void evt_device_attach(void* ctx, IOReturn result, void* sender, IOHIDDeviceRef ref_device)
{
    IODevAttacher* self = (__bridge IODevAttacher*)ctx;
    AppBridge* bridge = (AppBridge*)self.bridge;


    [bridge append_deviceWithDevice:ref_device];
}


void evt_device_detach(void* ctx, IOReturn result, void* sender, IOHIDDeviceRef ref_device)
{
    IODevAttacher* self = (__bridge IODevAttacher*)ctx;
    AppBridge* bridge = (AppBridge*)self.bridge;

    
    [bridge remove_deviceWithDevice:ref_device];
}


- (id) init
{
    if(self = [super init])
    {
        dict_kb_table = create_kb_table();

        ref_bridge = nil;
        dict_callback = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    }

    return self;
}


- (void) pro_proc
{
    if( self -> ref_manager == nil)
    {
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
        }
    }
}


- (void) epi_proc
{
    if(self -> ref_manager != nil)
    {
        IOHIDManagerUnscheduleFromRunLoop(ref_manager, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
        IOHIDManagerClose(ref_manager, kIOHIDOptionsTypeNone);
        
        self -> ref_manager = nil;
    }
}


- (BOOL) device_open:(IOHIDDeviceRef)ref_io_device
{
    IODevCallback* ref_io_dev_callback;
    IOReturn io_result;
    
    ref_io_dev_callback = [[IODevCallback alloc] init];

    io_result = [ref_io_dev_callback open:self IOHIDDeviceRef:ref_io_device];

    if(io_result == 0)
    {
        CFDictionarySetValue(dict_callback, ref_io_device, (__bridge const void *)(ref_io_dev_callback));
    }


    return io_result == 0;
}


- (BOOL) device_close:(IOHIDDeviceRef)ref_io_device
{
    const IODevCallback* ref_io_dev_callback = (IODevCallback *)CFDictionaryGetValue(dict_callback, ref_io_device);
    IOReturn io_result;

    if(ref_io_dev_callback != NULL)
    {
        io_result = [ref_io_dev_callback close];
        CFDictionaryRemoveValue(dict_callback, ref_io_device);
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


// [EOF]
