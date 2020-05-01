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
    CFMutableArrayRef ary_ref_device;
    CFMutableDictionaryRef dict_event_guard;
    CFMutableDictionaryRef dict_kb_table;

    NSObject* ref_oc_bridge;
    
    InputSource* ref_input_source;
    BOOL b_enable;
}

@property NSObject* oc_bridge;
@property InputSource* input_source;

- (id) init;
- (void) pro_proc;
- (void) epi_proc;
- (void) set_enable:(BOOL)b_enable;
@end


#endif /* input_device_h */
