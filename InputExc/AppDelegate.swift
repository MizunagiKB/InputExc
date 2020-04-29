//
//  AppDelegate.swift
//  InputExc
//

// ----------------------------------------------------------------- import(s)
import Cocoa
import SwiftUI


// ------------------------------------------------------------------ class(s)
class UIObserve: ObservableObject {
    @Published var connection_status: String = "Disconnected"
    @Published var iexc_settings: IExcSettings!
}


@objc class OCBridge: NSObject {

    var env: UIObserve!
    var input_device: InputDevice!

    @objc func device_name_set(name: String) {
        env.connection_status = name
    }
    
    @objc func save_settings() {
        JsonConfigure().save(iexc_settings: env.iexc_settings)
    }
    
    @objc func update_settings() {
        let input_source = InputSource()

        for device in env.iexc_settings.devices {
            for page in device.pages {
                for button in page.buttons {

                    var act_k: ActionKeyboard
                    var ref_sequence: ActionSequence

                    act_k = ActionKeyboard()
                    act_k.shift = button.shift
                    act_k.control = button.control
                    act_k.alternate = button.alternate
                    act_k.command = button.command
                    act_k.character = button.character

                    ref_sequence = ActionSequence()
                    ref_sequence.append(act_k)

                    input_source!.sequnece_set(button.id, value: ref_sequence)
                }
            }
        }

        input_device.input_source = input_source
    }

    @objc func device_compate(product: String) -> Bool {

        return self.env.iexc_settings.devices[0].name == product
    }

    @objc func test() {
        print("adamo")
    }
}


@NSApplicationMain


class AppDelegate: NSObject, NSApplicationDelegate {

    var oc_bridge: OCBridge!

    var window: NSWindow!
    var o_json_configure: JsonConfigure!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Create the SwiftUI view that provides the window contents.

        o_json_configure = JsonConfigure()
        o_json_configure.create_dir()

        oc_bridge = OCBridge()
        oc_bridge.env = UIObserve()

        #if true
                
        oc_bridge.env?.iexc_settings = o_json_configure.load()

        o_json_configure.save(iexc_settings: oc_bridge.env.iexc_settings)

        #else

        oc_bridge.env.iexc_settings = IExcSettings()
        oc_bridge.env.iexc_settings.devices = [IExcDevice()]
        oc_bridge.env.iexc_settings.devices[0].name = "TABMATE"
        oc_bridge.env.iexc_settings.devices[0].pages = [IExcPage()]
        oc_bridge.env.iexc_settings.devices[0].pages[0].id = 0
        oc_bridge.env.iexc_settings.devices[0].pages[0].name = "TEST"
        oc_bridge.env.iexc_settings.devices[0].pages[0].buttons = [IExcButton()]
        oc_bridge.env.iexc_settings.devices[0].pages[0].buttons[0].name = "X"
        oc_bridge.env.iexc_settings.devices[0].pages[0].buttons[0].character = "v"

        #endif

        let content_view = ContentView().environmentObject(oc_bridge.env)

        // Create the window and set the content view. 
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: false)
        window.center()
        window.setFrameAutosaveName("Main Window")
        window.contentView = NSHostingView(rootView: content_view)
        window.makeKeyAndOrderFront(nil)

        window.update()
        
        oc_bridge.input_device = InputDevice()
        oc_bridge.input_device.oc_bridge = oc_bridge
        oc_bridge.update_settings()
        oc_bridge.input_device.pro_proc()
    }

    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
        
        oc_bridge.input_device.epi_proc()
    }

    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
    
    
    func evt_save_settings() {
        oc_bridge.save_settings()
    }
    
    
    func evt_update_settings() {

        oc_bridge.update_settings()
    }

    
    func evt_active(enable: Bool) {
        
        oc_bridge.input_device.set_enable(enable)
    }

}

