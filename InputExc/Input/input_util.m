//
//  input_util.m
//  InputExc
//

#import <Foundation/Foundation.h>
#import <Carbon/Carbon.h>


CFStringRef CFStringCreateWithKeyCode(CGKeyCode key_code)
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
    
    const UCKeyboardLayout* keyboardLayout = (const UCKeyboardLayout *)CFDataGetBytePtr(layout);

    UInt32 keysDown = 0;
    UniChar c[4];
    UniCharCount realLength;

    UCKeyTranslate(
                   keyboardLayout,
                   key_code,
                   kUCKeyActionDisplay,
                   0,
                   LMGetKbdType(),
                   kUCKeyTranslateNoDeadKeysBit,
                   &keysDown,
                   sizeof(c) / sizeof(c[0]),
                   &realLength,
                   c
                   );

    
    return CFStringCreateWithCharacters(kCFAllocatorDefault, c, 1);
}


CGKeyCode StringToKeyCode(const NSString* s)
{
    static CFMutableDictionaryRef charToCodeDict = NULL;
    CFNumberRef ref_n;
    CGKeyCode code;
    UniChar character = s.UTF8String[0];
    CFStringRef charStr = NULL;

    if ([s isEqualToString:@"RETURN"]) return kVK_Return;
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
    
    if(charToCodeDict == NULL)
    {
        UInt32 i;
        charToCodeDict = CFDictionaryCreateMutable(kCFAllocatorDefault,
                                                   0,
                                                   &kCFTypeDictionaryKeyCallBacks,
                                                   &kCFTypeDictionaryValueCallBacks
                                                   );
        if(charToCodeDict == NULL) return UINT16_MAX;

        for(i = 0; i < 128; i++)
        {
            CFStringRef string = CFStringCreateWithKeyCode((CGKeyCode)i);
            if(string != NULL)
            {
                CFNumberRef ref_code = CFNumberCreate(kCFAllocatorDefault, kCFNumberIntType, &i);

                CFDictionarySetValue(charToCodeDict, string, ref_code);

                CFRelease(ref_code);
                CFRelease(string);
            }
        }
    }

    charStr = CFStringCreateWithCharacters(kCFAllocatorDefault, &character, 1);
    
    if(!CFDictionaryGetValueIfPresent(
                                      charToCodeDict,
                                      charStr,
                                      (const void **)&ref_n))
    {
        code = UINT16_MAX;
    } else {
        CFNumberGetValue(ref_n, kCFNumberSInt16Type, &code);
    }

    CFRelease(charStr);


    return code;
}

bool check_available_character(const NSString* s)
{
    return StringToKeyCode(s) != UINT16_MAX;
}

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
    CFMutableDictionaryRef dict_result = NULL;
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
