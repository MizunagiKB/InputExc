//
//  input_device.h
//  InputExc
//

#ifndef input_device_h
#define input_device_h


@interface
IODevAttacher: NSObject {
    IOHIDManagerRef ref_manager;
    CFMutableDictionaryRef dict_kb_table;

    NSObject* ref_bridge;
    CFMutableDictionaryRef dict_callback;
}

@property NSObject* bridge;

//- (id) init;
- (void) pro_proc;
- (void) epi_proc;

- (BOOL) device_open:(IOHIDDeviceRef)ref_io_device;
- (BOOL) device_close:(IOHIDDeviceRef)ref_io_device;

- (UInt16) CharacterToKeycode:(NSString*)s;
@end


#endif /* input_device_h */
