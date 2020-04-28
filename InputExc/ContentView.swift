//
//  ContentView.swift
//  InputExc
//

import Cocoa
import SwiftUI


struct ContentView: View {

    @State var tab_selected = 0
    @State var enable_status = false
    @State var lbl_enable_status = "Inactive"

    @EnvironmentObject var env: UIObserve

    
    var body: some View {
        VStack {

            Text(self.env.connection_status)

            Divider()

            TabView() {
                Form {
                    VStack {
                        ForEach(0..<self.env.iexc_settings.devices[0].pages[0].buttons.count) {
                            i in HStack {
                                Text(self.env.iexc_settings.devices[0].pages[0].buttons[i].name)
                                    .frame(width: 96.0)
                                Toggle("shift", isOn: self.$env.iexc_settings.devices[0].pages[0].buttons[i].shift)
                                Toggle("control", isOn: self.$env.iexc_settings.devices[0].pages[0].buttons[i].control)
                                Toggle("alternate", isOn: self.$env.iexc_settings.devices[0].pages[0].buttons[i].alternate)
                                Toggle("command", isOn: self.$env.iexc_settings.devices[0].pages[0].buttons[i].command)
                                TextField("-", text: self.$env.iexc_settings.devices[0].pages[0].buttons[i].character)
                                    .frame(width: 64.0)
                            }.padding(1)
                        }
                    }
                }.tabItem { Text(self.env.iexc_settings.devices[0].pages[0].name)}
                    .id(self.env.iexc_settings.devices[0].pages[0].id)

                Form {
                    VStack {
                        ForEach(0..<self.env.iexc_settings.devices[0].pages[1].buttons.count) {
                            i in HStack {
                                Text(self.env.iexc_settings.devices[0].pages[1].buttons[i].name)
                                    .frame(width: 96.0)
                                Toggle("shift", isOn: self.$env.iexc_settings.devices[0].pages[1].buttons[i].shift)
                                Toggle("control", isOn: self.$env.iexc_settings.devices[0].pages[1].buttons[i].control)
                                Toggle("alternate", isOn: self.$env.iexc_settings.devices[0].pages[1].buttons[i].alternate)
                                Toggle("command", isOn: self.$env.iexc_settings.devices[0].pages[1].buttons[i].command)
                                TextField("-", text: self.$env.iexc_settings.devices[0].pages[1].buttons[i].character)
                                    .frame(width: 64.0)
                            }.padding(1)
                        }
                    }
                }.tabItem { Text(self.env.iexc_settings.devices[0].pages[1].name)}
                    .id(self.env.iexc_settings.devices[0].pages[1].id)

                Form {
                    VStack {
                        ForEach(0..<self.env.iexc_settings.devices[0].pages[2].buttons.count) {
                            i in HStack {
                                Text(self.env.iexc_settings.devices[0].pages[2].buttons[i].name)
                                    .frame(width: 96.0)
                                Toggle("shift", isOn: self.$env.iexc_settings.devices[0].pages[2].buttons[i].shift)
                                Toggle("control", isOn: self.$env.iexc_settings.devices[0].pages[2].buttons[i].control)
                                Toggle("alternate", isOn: self.$env.iexc_settings.devices[0].pages[2].buttons[i].alternate)
                                Toggle("command", isOn: self.$env.iexc_settings.devices[0].pages[2].buttons[i].command)
                                TextField("-", text: self.$env.iexc_settings.devices[0].pages[2].buttons[i].character)
                                    .frame(width: 64.0)
                            }.padding(1)
                        }
                    }
                }.tabItem { Text(self.env.iexc_settings.devices[0].pages[2].name)}
                    .id(self.env.iexc_settings.devices[0].pages[2].id)

                Form {
                    VStack {
                        ForEach(0..<self.env.iexc_settings.devices[0].pages[3].buttons.count) {
                            i in HStack {
                                Text(self.env.iexc_settings.devices[0].pages[3].buttons[i].name)
                                    .frame(width: 96.0)
                                Toggle("shift", isOn: self.$env.iexc_settings.devices[0].pages[3].buttons[i].shift)
                                Toggle("control", isOn: self.$env.iexc_settings.devices[0].pages[3].buttons[i].control)
                                Toggle("alternate", isOn: self.$env.iexc_settings.devices[0].pages[3].buttons[i].alternate)
                                Toggle("command", isOn: self.$env.iexc_settings.devices[0].pages[3].buttons[i].command)
                                TextField("-", text: self.$env.iexc_settings.devices[0].pages[3].buttons[i].character)
                                    .frame(width: 64.0)
                            }.padding(1)
                        }
                    }
                }.tabItem { Text(self.env.iexc_settings.devices[0].pages[3].name)}
                    .id(self.env.iexc_settings.devices[0].pages[3].id)
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

                        if(self.enable_status)
                        {
                            self.enable_status = false
                            self.lbl_enable_status = "Inactive"
                        } else {
                            self.enable_status = true
                            self.lbl_enable_status = "Active"
                        }

                        app.evt_active(enable: self.enable_status)
                    }
                ) {
                    Text(self.lbl_enable_status)
                }
            }

        }
        .padding()
        .frame(width: 540.0, height: 640.0)
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
