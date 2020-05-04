//
//  TABMATEView.swift
//  InputExc
//

import SwiftUI


struct TABMATEView: View {

    @ObservedObject var conf: IConfDevice

    var body: some View {
        TabView() {
            VStack {
                ForEach(0..<self.conf.pages[0].actions.count) {
                    n in HStack {
                        Text(self.conf.pages[0].actions[n].name)
                            .frame(width: 96.0)
                        Toggle("shift", isOn: self.$conf.pages[0].actions[n].shift)
                        Toggle("control", isOn: self.$conf.pages[0].actions[n].control)
                        Toggle("alternate", isOn: self.$conf.pages[0].actions[n].alternate)
                        Toggle("command", isOn: self.$conf.pages[0].actions[n].command)
                        TextField("-", text: self.$conf.pages[0].actions[n].character)
                            .frame(width: 64.0)
                            .multilineTextAlignment(TextAlignment.center)
                    }.padding(1)
                }
            }.tabItem { Text(self.conf.pages[0].name)}

            VStack {
                ForEach(0..<self.conf.pages[1].actions.count) {
                    n in HStack {
                        Text(self.conf.pages[1].actions[n].name)
                            .frame(width: 96.0)
                        Toggle("shift", isOn: self.$conf.pages[1].actions[n].shift)
                        Toggle("control", isOn: self.$conf.pages[1].actions[n].control)
                        Toggle("alternate", isOn: self.$conf.pages[1].actions[n].alternate)
                        Toggle("command", isOn: self.$conf.pages[1].actions[n].command)
                        TextField("-", text: self.$conf.pages[1].actions[n].character)
                            .frame(width: 64.0)
                            .multilineTextAlignment(TextAlignment.center)
                    }.padding(1)
                }
            }.tabItem { Text(self.conf.pages[1].name)}

            VStack {
                ForEach(0..<self.conf.pages[2].actions.count) {
                    n in HStack {
                        Text(self.conf.pages[2].actions[n].name)
                            .frame(width: 96.0)
                        Toggle("shift", isOn: self.$conf.pages[2].actions[n].shift)
                        Toggle("control", isOn: self.$conf.pages[2].actions[n].control)
                        Toggle("alternate", isOn: self.$conf.pages[2].actions[n].alternate)
                        Toggle("command", isOn: self.$conf.pages[2].actions[n].command)
                        TextField("-", text: self.$conf.pages[2].actions[n].character)
                            .frame(width: 64.0)
                            .multilineTextAlignment(TextAlignment.center)
                    }.padding(1)
                }
            }.tabItem { Text(self.conf.pages[2].name)}

            VStack {
                ForEach(0..<self.conf.pages[3].actions.count) {
                    n in HStack {
                        Text(self.conf.pages[3].actions[n].name)
                            .frame(width: 96.0)
                        Toggle("shift", isOn: self.$conf.pages[3].actions[n].shift)
                        Toggle("control", isOn: self.$conf.pages[3].actions[n].control)
                        Toggle("alternate", isOn: self.$conf.pages[3].actions[n].alternate)
                        Toggle("command", isOn: self.$conf.pages[3].actions[n].command)
                        TextField("-", text: self.$conf.pages[3].actions[n].character)
                            .frame(width: 64.0)
                            .multilineTextAlignment(TextAlignment.center)
                    }.padding(1)
                }
            }.tabItem { Text(self.conf.pages[3].name)}
        }
    }
}


struct TABMATEView_Previews: PreviewProvider {
    static var previews: some View {
        TABMATEView(conf: IConfDevice())
    }
}
