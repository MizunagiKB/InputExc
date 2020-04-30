//
//  action-keyboard.m
//  InputExc
//

// ----------------------------------------------------------------- import(s)
#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

#import "action.h"


@implementation ActionKeyboard

@synthesize shift = b_shift;
@synthesize control = b_control;
@synthesize alternate = b_alternate;
@synthesize command = b_command;
@synthesize character = c_character;


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
