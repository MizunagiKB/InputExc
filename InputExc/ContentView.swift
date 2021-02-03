//
//  ContentView.swift
//  InputExc
//

// ----------------------------------------------------------------- import(s)
import Cocoa
import SwiftUI


// --------------------------------------------------------------- function(s)
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
struct ContentView: View
{
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
                        self.selected_device = device.io_device
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
            } else if self.env.selected_product == "DUALSHOCK 4 Wireless Controller" {
                DualSenseView(conf: self.env.get_conf_device())
            } else if self.env.selected_product == "Xbox Wireless Controller" {
                XboxSeriesView(conf: self.env.get_conf_device())
            } else {
            }

            HStack {
                Button(action: { self.env.config.save() }) { Text("Save") }
                Button(action: { self.device_opened = req_open_device(io_device: self.selected_device!) }) { Text("Device Open") }.disabled(self.device_opened)
                Button(action: { self.device_opened = !req_close_device(io_device: self.selected_device!) }) { Text("Device Close") }.disabled(!self.device_opened)
            }.disabled(self.env.selected_product.count == 0)
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
