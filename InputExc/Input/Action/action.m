//
//  action.m
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


CFStringRef createStringForKey(CGKeyCode key_code)
{
    TISInputSourceRef currentKeyboard = TISCopyCurrentKeyboardInputSource();

    CFDataRef layoutData = TISGetInputSourceProperty(
                                                     currentKeyboard,
                                                     kTISPropertyUnicodeKeyLayoutData
                                                     );
    const UCKeyboardLayout* keyboardLayout = (const UCKeyboardLayout *)CFDataGetBytePtr(layoutData);

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

    CFRelease(currentKeyboard);

    
    return CFStringCreateWithCharacters(kCFAllocatorDefault, c, 1);
}


CGKeyCode keyCodeForChar(NSString* keyString)
{
    if ([keyString isEqualToString:@"a"]) return 0;
    if ([keyString isEqualToString:@"s"]) return 1;
    if ([keyString isEqualToString:@"d"]) return 2;
    if ([keyString isEqualToString:@"f"]) return 3;
    if ([keyString isEqualToString:@"h"]) return 4;
    if ([keyString isEqualToString:@"g"]) return 5;
    if ([keyString isEqualToString:@"z"]) return 6;
    if ([keyString isEqualToString:@"x"]) return 7;
    if ([keyString isEqualToString:@"c"]) return 8;
    if ([keyString isEqualToString:@"v"]) return 9;
    if ([keyString isEqualToString:@"b"]) return 11;
    if ([keyString isEqualToString:@"q"]) return 12;
    if ([keyString isEqualToString:@"w"]) return 13;
    if ([keyString isEqualToString:@"e"]) return 14;
    if ([keyString isEqualToString:@"r"]) return 15;
    if ([keyString isEqualToString:@"y"]) return 16;
    if ([keyString isEqualToString:@"t"]) return 17;
    if ([keyString isEqualToString:@"1"]) return 18;
    if ([keyString isEqualToString:@"2"]) return 19;
    if ([keyString isEqualToString:@"3"]) return 20;
    if ([keyString isEqualToString:@"4"]) return 21;
    if ([keyString isEqualToString:@"6"]) return 22;
    if ([keyString isEqualToString:@"5"]) return 23;
    if ([keyString isEqualToString:@"="]) return 24;
    if ([keyString isEqualToString:@"9"]) return 25;
    if ([keyString isEqualToString:@"7"]) return 26;
    if ([keyString isEqualToString:@"-"]) return 27;
    if ([keyString isEqualToString:@"8"]) return 28;
    if ([keyString isEqualToString:@"0"]) return 29;
    if ([keyString isEqualToString:@"]"]) return 30;
    if ([keyString isEqualToString:@"o"]) return 31;
    if ([keyString isEqualToString:@"u"]) return 32;
    if ([keyString isEqualToString:@"["]) return 33;
    if ([keyString isEqualToString:@"i"]) return 34;
    if ([keyString isEqualToString:@"p"]) return 35;
    if ([keyString isEqualToString:@"RETURN"]) return 36;
    if ([keyString isEqualToString:@"l"]) return 37;
    if ([keyString isEqualToString:@"j"]) return 38;
    if ([keyString isEqualToString:@"'"]) return 39;
    if ([keyString isEqualToString:@"k"]) return 40;
    if ([keyString isEqualToString:@";"]) return 41;
    if ([keyString isEqualToString:@"\\"]) return 42;
    if ([keyString isEqualToString:@","]) return 43;
    if ([keyString isEqualToString:@"/"]) return 44;
    if ([keyString isEqualToString:@"n"]) return 45;
    if ([keyString isEqualToString:@"m"]) return 46;
    if ([keyString isEqualToString:@"."]) return 47;
    if ([keyString isEqualToString:@"TAB"]) return 48;
    if ([keyString isEqualToString:@"SPACE"]) return 49;
    if ([keyString isEqualToString:@"`"]) return 50;
    if ([keyString isEqualToString:@"DELETE"]) return 51;
    if ([keyString isEqualToString:@"ENTER"]) return 52;
    if ([keyString isEqualToString:@"ESCAPE"]) return 53;

    // some more missing codes abound, reserved I presume, but it would
    // have been helpful for Apple to have a document with them all listed

    if ([keyString isEqualToString:@"."]) return 65;

    if ([keyString isEqualToString:@"*"]) return 67;

    if ([keyString isEqualToString:@"+"]) return 69;

    if ([keyString isEqualToString:@"CLEAR"]) return 71;

    if ([keyString isEqualToString:@"/"]) return 75;
    if ([keyString isEqualToString:@"ENTER"]) return 76;  // numberpad on full kbd

    if ([keyString isEqualToString:@"="]) return 78;

    if ([keyString isEqualToString:@"="]) return 81;
    if ([keyString isEqualToString:@"0"]) return 82;
    if ([keyString isEqualToString:@"1"]) return 83;
    if ([keyString isEqualToString:@"2"]) return 84;
    if ([keyString isEqualToString:@"3"]) return 85;
    if ([keyString isEqualToString:@"4"]) return 86;
    if ([keyString isEqualToString:@"5"]) return 87;
    if ([keyString isEqualToString:@"6"]) return 88;
    if ([keyString isEqualToString:@"7"]) return 89;

    if ([keyString isEqualToString:@"8"]) return 91;
    if ([keyString isEqualToString:@"9"]) return 92;

    if ([keyString isEqualToString:@"F5"]) return 96;
    if ([keyString isEqualToString:@"F6"]) return 97;
    if ([keyString isEqualToString:@"F7"]) return 98;
    if ([keyString isEqualToString:@"F3"]) return 99;
    if ([keyString isEqualToString:@"F8"]) return 100;
    if ([keyString isEqualToString:@"F9"]) return 101;

    if ([keyString isEqualToString:@"F11"]) return 103;

    if ([keyString isEqualToString:@"F13"]) return 105;

    if ([keyString isEqualToString:@"F14"]) return 107;

    if ([keyString isEqualToString:@"F10"]) return 109;

    if ([keyString isEqualToString:@"F12"]) return 111;

    if ([keyString isEqualToString:@"F15"]) return 113;
    if ([keyString isEqualToString:@"HELP"]) return 114;
    if ([keyString isEqualToString:@"HOME"]) return 115;
    if ([keyString isEqualToString:@"PGUP"]) return 116;
    if ([keyString isEqualToString:@"DELETE"]) return 117;
    if ([keyString isEqualToString:@"F4"]) return 118;
    if ([keyString isEqualToString:@"END"]) return 119;
    if ([keyString isEqualToString:@"F2"]) return 120;
    if ([keyString isEqualToString:@"PGDN"]) return 121;
    if ([keyString isEqualToString:@"F1"]) return 122;
    if ([keyString isEqualToString:@"LEFT"]) return 123;
    if ([keyString isEqualToString:@"RIGHT"]) return 124;
    if ([keyString isEqualToString:@"DOWN"]) return 125;
    if ([keyString isEqualToString:@"UP"]) return 126;

    return 0;
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
    CGKeyCode key_code = keyCodeForChar(c_character);
    
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


@implementation Action
- (void) event_dispatch:(bool)is_keydown {}
@end


