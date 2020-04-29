//
//  action.h
//  InputExc
//

#ifndef action_h
#define action_h

CFStringRef KeyCodeToString(CGKeyCode key_code);

typedef enum E_ACTION_TYPE : NSUInteger {
    E_NONE,
    E_KEYBOARD
} E_ACTION_TYPE;


@interface
Action: NSObject {
}
- (void) event_dispatch:(bool)is_keydown;
@end


@interface
ActionKeyboard: Action {
    bool b_shift;
    bool b_control;
    bool b_alternate;
    bool b_command;

    NSString* c_character;
}
@property bool shift;
@property bool control;
@property bool alternate;
@property bool command;
@property NSString* character;
- (id) init;
- (void) event_dispatch:(bool)is_keydown;
@end


#endif /* action_h */
