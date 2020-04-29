//
//  action-keyboard.m
//  InputExc
//

// ----------------------------------------------------------------- import(s)
#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import <Carbon/Carbon.h>

#import "action.h"


@implementation ActionKeyboard
@synthesize shift = b_shift;
@synthesize control = b_control;
@synthesize alternate = b_alternate;
@synthesize command = b_command;
@synthesize character = c_character;


CFStringRef KeyCodeToString(CGKeyCode key_code)
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


CGKeyCode StringToKeyCode(NSString* s)
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
            CFStringRef string = KeyCodeToString((CGKeyCode)i);
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


- (id) init {

    if(self = [super init])
    {
        b_shift = false;
        b_control = false;
        b_alternate = false;
        b_command = false;
        c_character = @"";
    }

    return self;
}


- (void) event_dispatch:(bool)is_keydown {

    CGEventSourceRef src = CGEventSourceCreate(kCGEventSourceStateHIDSystemState);
    CGKeyCode key_code = StringToKeyCode(c_character);
    
    CGEventRef event = CGEventCreateKeyboardEvent(src, key_code, is_keydown);

    CGEventFlags flg = 0;
    if(b_shift) flg |= kCGEventFlagMaskShift;
    if(b_control) flg |= kCGEventFlagMaskControl;
    if(b_alternate) flg |= kCGEventFlagMaskAlternate;
    if(b_command) flg |= kCGEventFlagMaskCommand;

    CGEventSetFlags(event, flg);
    CGEventPost(kCGHIDEventTap, event);
    
    CFRelease(event);
    CFRelease(src);
}


@end
