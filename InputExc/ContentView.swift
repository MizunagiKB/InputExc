//
//  ContentView.swift
//  InputExc
//

// ----------------------------------------------------------------- import(s)
import Cocoa
import SwiftUI


// ----------------------------------------------------------------- struct(s)
func req_open_device(io_device: IOHIDDevice) -> Bool
{
    let app = NSApplication.shared.delegate as! AppDelegate
    return app.bridge.device_open(io_device: io_device)
}


func req_close_device(io_device: IOHIDDevice) -> Bool
{
    let app = NSApplication.shared.delegate as! AppDelegate
    return app.bridge.device_close(io_device: io_device)
}


// ----------------------------------------------------------------- struct(s)
struct ContentView: View {

//    @State var tab_selected = 0
//    @State var enable_status = false
//    @State var lbl_enable_status = "Inactive"
//    @State var dict_button_status: [Int: Color] = [:]

//    @State var product_curr = ""
    
    @State var selected_device: IOHIDDevice? = nil
    @State var device_opened: Bool = false

    @EnvironmentObject var env: AppEnvironment

    var body: some View {
        VStack {

            MenuButton(label: Text(self.env.selected_product))
            {
                ForEach(self.env.list_device, id: \.self)
                {
                    device in Button(action: {
                        self.env.selected_product = device.product
                        self.env.selected_serial_id = device.serial_id
                        self.env.device_input_status = ""
                        self.selected_device = device.device
                        self.device_opened = device.b_opened
                    }) {
                        Text(device.product)
                    }
                }
            }
            
            Text(self.env.device_input_status)

            if self.env.selected_product == "TABMATE" {
                TABMATEView(conf: self.env.get_conf_device())
            } else if self.env.selected_product == "Joy-Con (L)" {
                JoyConView(conf: self.env.get_conf_device())
            } else if self.env.selected_product == "Joy-Con (R)" {
                JoyConView(conf: self.env.get_conf_device())
            } else {
            }

            HStack {
                Button(action: { self.env.config.save() }) { Text("Save") }
                Button(action: { self.device_opened = req_open_device(io_device: self.selected_device!) }) { Text("Device Open") }.disabled(self.device_opened)
                Button(action: { self.device_opened = !req_close_device(io_device: self.selected_device!) }) { Text("Device Close") }.disabled(!self.device_opened)
            }.disabled(self.env.selected_product.count == 0)

            Divider()

            
            
            
            
            
            
            
            #if false
            Text(self.env.connection_status)
            
            HStack {
                Text("VendorID: \(String(format: "%04X", self.env.vendor_id))")
                Text("ProductID: \(String(format: "%04X", self.env.product_id))")
                Text("Product: " + self.env.product)
            }
                .padding(1)
            

            Divider()

            if self.env.product_curr == "TABMATE" {
                //TABMATEView()
            } else if self.env.product_curr == "JOY-CON" {
                //JoyConView()
            } else {
            }

            Divider()

            HStack {

                Button(
                    action:
                    {
                        let app = NSApplication.shared.delegate as! AppDelegate

                        app.evt_save_settings()
                    }
                ) {
                    Text("Save")
                }

                Button(
                    action:
                    {
                        let app = NSApplication.shared.delegate as! AppDelegate

                        app.evt_update_settings()
                    }
                ) {
                    Text("Update")
                }

                Button(
                    action:
                    {
                        let app = NSApplication.shared.delegate as! AppDelegate

                        if(self.enable_status == false)
                        {
                            self.enable_status = true
                        }

                        app.evt_active(enable: self.enable_status)
                    }
                ) { Text("Active") }
                    .disabled(self.enable_status ? true : false)
                
                Button(
                    action:
                    {
                        let app = NSApplication.shared.delegate as! AppDelegate

                        if(self.enable_status)
                        {
                            self.enable_status = false
                        }

                        app.evt_active(enable: self.enable_status)
                    }
                ) { Text("Inactive") }
                    .disabled(self.enable_status ? false : true)
            }
            #endif
        }
        .padding()
        .frame(width: 540.0, height: 680.0)
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
