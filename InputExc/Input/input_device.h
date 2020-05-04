//
//  input_device.h
//  InputExc
//

#ifndef input_device_h
#define input_device_h


bool check_available_character(const NSString* s);


@interface
InputDevice: NSObject {
    IOHIDManagerRef ref_manager;
    CFMutableDictionaryRef dict_kb_table;

    NSObject* ref_bridge;
    CFMutableDictionaryRef dict_callback;

    BOOL b_enable;
}

@property NSObject* bridge;

- (id) init;
- (void) pro_proc;
- (void) epi_proc;

- (BOOL) device_open:(IOHIDDeviceRef)ref_device;
- (BOOL) device_close:(IOHIDDeviceRef)ref_device;

- (CGKeyCode) CharacterToKeycode:(NSString*)character;
@end


#endif /* input_device_h */
