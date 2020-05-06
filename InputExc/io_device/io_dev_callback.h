//
//  io_hid_callback.h
//  InputExc
//

#ifndef io_hid_callback_h
#define io_hid_callback_h


@interface
IODevCallback: NSObject
{
    IODevAttacher* ref_io_dev_attacher;
    IOHIDDeviceRef ref_io_device;
    IOReturn last_return;
}

@property IODevAttacher* io_dev_attacher;
@property IOHIDDeviceRef io_device;

- (IOReturn) open:(IODevAttacher*)ref_io_dev_attacher IOHIDDeviceRef:(IOHIDDeviceRef)ref_io_device;
- (IOReturn) close;
- (void) dealloc;
@end


#endif /* io_hid_callback_h */
