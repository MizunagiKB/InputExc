//
//  input_device.h
//  InputExc
//

#ifndef input_device_h
#define input_device_h

@interface
InputDevice: NSObject {
    IOHIDManagerRef ref_manager;
    IOHIDDeviceRef ref_device;
    
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
