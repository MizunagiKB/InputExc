//
//  AppDelegate.swift
//  InputExc
//

// ----------------------------------------------------------------- import(s)
import Cocoa
import SwiftUI


// ------------------------------------------------------------------ class(s)
@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate
{
    var bridge: AppBridge!
    var window: NSWindow!
    
    func applicationDidFinishLaunching(_ aNotification: Notification)
    {
        // Create the SwiftUI view that provides the window contents.

        bridge = AppBridge()
        bridge.env = AppEnvironment()
        bridge.env.config = AppConfig()

        bridge.dev = IODevAttacher()
        bridge.dev.bridge = bridge
        bridge.dev.pro_proc()

        let content_view = ContentView().environmentObject(bridge.env)

        // Create the window and set the content view. 
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
            styleMask: [.titled, .closable, .miniaturizable, .fullSizeContentView],
            backing: .buffered, defer: false)
        window.title = "InputExc"
        window.center()
        window.setFrameAutosaveName("Main Window")
        window.contentView = NSHostingView(rootView: content_view)
        window.makeKeyAndOrderFront(nil)

        window.update()
    }

    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool
    {
        bridge.dev.epi_proc()
        return true
    }

    
    @IBAction func evt_menu_about(_ sender: Any)
    {
    }

    @IBAction func evt_menu_save(_ sender: Any)
    {
        self.bridge.save_settings()
    }
    
    @IBAction func evt_menu_preference(_ sender: Any)
    {
        for w in NSApplication.shared.windows
        {
            w.makeKeyAndOrderFront(self)
        }
    }
}


// [EOF]
