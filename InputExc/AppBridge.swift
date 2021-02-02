//
//  AppBridge.swift
//  InputExc
//
//  Objective-CからSwiftを利用するためのクラス
//

import Foundation
import CoreGraphics
import InputMethodKit


@objc class AppBridge: NSObject
{
    var env: AppEnvironment!
    var dev: IODevAttacher!

    func save_settings()
    {
        self.env.config.save()
    }

    func device_open(io_device: IOHIDDevice) -> Bool
    {
        for n in 0..<self.env.list_device.count
        {
            if self.env.list_device[n].io_device == io_device
            {
                self.env.list_device[n].b_opened = self.dev.device_open(io_device)

                return self.env.list_device[n].b_opened
            }
        }
        
        return false
    }

    func device_close(io_device: IOHIDDevice) -> Bool
    {
        for n in 0..<self.env.list_device.count
        {
            if self.env.list_device[n].io_device == io_device
            {
                self.env.list_device[n].b_opened = self.dev.device_close(io_device)

                return self.env.list_device[n].b_opened
            }
        }
        
        return true
    }
    
    func send_meta_keycode(action: IConfAction, keydown: Bool)
    {
        let src = CGEventSource(stateID: CGEventSourceStateID.hidSystemState)

        if action.shift
        {
            let ev = CGEvent(keyboardEventSource: src, virtualKey: CGKeyCode(kVK_Shift), keyDown: keydown)
            ev?.post(tap: CGEventTapLocation.cghidEventTap)
        }

        if action.control {
            let ev = CGEvent(keyboardEventSource: src, virtualKey: CGKeyCode(kVK_Control), keyDown: keydown)
            ev?.post(tap: CGEventTapLocation.cghidEventTap)
        }
        
        if action.alternate {
            let ev = CGEvent(keyboardEventSource: src, virtualKey: CGKeyCode(kVK_Option), keyDown: keydown)
            ev?.post(tap: CGEventTapLocation.cghidEventTap)
        }

        if action.command {
            let ev = CGEvent(keyboardEventSource: src, virtualKey: CGKeyCode(kVK_Command), keyDown: keydown)
            ev?.post(tap: CGEventTapLocation.cghidEventTap)
        }
    }
    
    func send_keycode(action: IConfAction, keydown: Bool)
    {
        let key_code = dev.character(toKeycode: action.character)

        let src = CGEventSource(stateID: CGEventSourceStateID.hidSystemState)
        let event = CGEvent(keyboardEventSource: src, virtualKey: key_code, keyDown: keydown)

        if action.shift { event?.flags.insert(.maskShift) }
        if action.control { event?.flags.insert(.maskControl) }
        if action.alternate { event?.flags.insert(.maskAlternate) }
        if action.command { event?.flags.insert(.maskCommand) }

        if keydown == true
        {
            self.send_meta_keycode(action: action, keydown: keydown)
        }

        event?.post(tap: CGEventTapLocation.cghidEventTap)

        if keydown == false
        {
            self.send_meta_keycode(action: action, keydown: keydown)
        }
    }

    @objc func evt_device_input(device: IOHIDDevice, usage: Int32, value: Int32)
    {
        let product = IOHIDDeviceGetProperty(device, kIOHIDProductKey as CFString) as! String
        let serial_id = IOHIDDeviceGetProperty(device, kIOHIDSerialNumberKey as CFString) as! String

        self.env.device_input_status = product + String(format: " usage:%d value:%d", usage, value)

        NSLog(self.env.device_input_status)


        for conf_device in self.env.config.conf.devices
        {
            if conf_device.serial_id == serial_id
            {
                for page in conf_device.pages
                {
                    for action in page.actions
                    {
                        if action.usage == usage
                        {
                            if action.character.count > 0
                            {
                                if action.value == nil
                                {
                                    self.send_keycode(action: action, keydown: value > 0 ? true : false)
                                } else if action.value == value {
                                    self.send_keycode(action: action, keydown: true)
                                    self.send_keycode(action: action, keydown: false)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    @objc func append_device(device: IOHIDDevice)
    {
        var b_found = false

        for dev in self.env.list_device
        {
            if dev.io_device == device
            {
                b_found = true
                break
            }
        }
        
        if b_found == false
        {
            let serial_id = IOHIDDeviceGetProperty(device, kIOHIDSerialNumberKey as CFString)

            if(serial_id != nil)
            {
                let dev = AppEnvironment.Device(
                    io_device: device,
                    product: IOHIDDeviceGetProperty(device, kIOHIDProductKey as CFString) as! String,
                    vendor_id: IOHIDDeviceGetProperty(device, kIOHIDVendorIDKey as CFString) as! Int32,
                    product_id: IOHIDDeviceGetProperty(device, kIOHIDProductIDKey as CFString) as! Int32,
                    serial_id: serial_id as! String
                )

                self.env.list_device.append(dev)

                NSLog(String(format: "append [%04X] [%04X] ", dev.vendor_id, dev.product_id) + dev.product)
            }
        }
    }

    @objc func remove_device(device: IOHIDDevice)
    {
        var b_remove = false

        repeat {
            var pos = 0

            b_remove = false

            for dev in self.env.list_device {
                if dev.io_device == device {
                    self.env.list_device.remove(at: pos)
                    
                    if self.env.selected_product == dev.product
                    {
                        self.env.selected_product = ""
                        self.env.selected_serial_id = ""
                        self.env.device_input_status = ""
                    }
                    b_remove = true

                    NSLog(String(format: "remove [%04X] [%04X] ", dev.vendor_id, dev.product_id) + dev.product)
                }
                pos += 1
            }
        } while b_remove == true
    }
}


// [EOF]
