//
//  DualSenseView.swift
//  InputExc
//

import Cocoa
import SwiftUI


struct DualSenseView: View
{
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
        }
    }
}


struct DualSenseView_Previews: PreviewProvider {
    static var previews: some View {
        DualSenseView(conf: IConfDevice())
    }
}

