//
//  AppEnvironment.swift
//  InputExc
//

// ----------------------------------------------------------------- import(s)
import Foundation
import Cocoa
import SwiftUI


// ------------------------------------------------------------------ class(s)
class AppConfig
{
    let configure_dir = ".InputExc"
    let configure = "configure.json"
    let dict_tempalte: [String: String] = [
        "TABMATE": "template-TABMATE",
        "Joy-Con (L)": "template-Joy-Con (L)",
        "Joy-Con (R)": "template-Joy-Con (R)",
        "DUALSHOCK 4 Wireless Controller": "template-DUALSHOCK 4 Wireless Controller",
        "Xbox Wireless Controller": "template-Xbox Wireless Controller"
    ]

    var conf: IConfDevices = IConfDevices()

    init()
    {
        self.create_dir()
        self.load()
    }

    func create_dir()
    {
        let m = FileManager.default
        let target_dir: URL = m.homeDirectoryForCurrentUser
            .appendingPathComponent(self.configure_dir)

        if m.fileExists(atPath: target_dir.path) == false {
            do {
                try m.createDirectory(at: target_dir, withIntermediateDirectories: true, attributes: nil)
            } catch {
                NSLog("Failure configure dir %s", target_dir.path)
            }
        }
    }

    func load_template(template: String) -> IConfDevice
    {
        let json_url: URL = Bundle.main.url(forResource: dict_tempalte[template], withExtension: "json")!

        do {
            let raw_json: String! = try String(contentsOf: json_url)

            if let dataFromString = raw_json.data(using: .utf8, allowLossyConversion: false) {
                let json = try JSON(data: dataFromString)

                return IConfDevice(j: json)
            }
        } catch {
        }
        
        return IConfDevice()
    }

    func load()
    {
        let m = FileManager.default
        let json_url: URL = m.homeDirectoryForCurrentUser
            .appendingPathComponent(self.configure_dir)
            .appendingPathComponent(self.configure)

        do {
            let raw_json: String! = try String(contentsOf: json_url)

            if let dataFromString = raw_json.data(using: .utf8, allowLossyConversion: false) {
                let json = try JSON(data: dataFromString)

                self.conf.from_json_object(j: json)
            }
        } catch {
        }
    }

    func save()
    {
        let js_result: JSON = self.conf.to_json_object()
        let o_enc = JSONEncoder()
        let m = FileManager.default
        let json_url: URL = m.homeDirectoryForCurrentUser
            .appendingPathComponent(self.configure_dir)
            .appendingPathComponent(self.configure)

        do {
            o_enc.outputFormatting = .prettyPrinted

            let raw_json = try o_enc.encode(js_result)
            try raw_json.write(to: json_url)

        } catch {
        }
    }
}


class AppEnvironment: ObservableObject
{
    struct Device: Hashable
    {
        var io_device: IOHIDDevice!
        var b_opened: Bool = false
        var product: String = ""
        var vendor_id: Int32 = 0
        var product_id: Int32 = 0
        var serial_id: String = ""
    }
    
    @Published var selected_product: String = ""
    @Published var selected_serial_id: String = ""
    @Published var device_input_status: String = ""
    @Published var list_device: Array<Device> = []

    var config: AppConfig!

    func get_conf_device() -> IConfDevice
    {
        for device in self.config.conf.devices {
            if device.serial_id == selected_serial_id {
                return device
            }
        }

        let conf_device = self.config.load_template(template: self.selected_product)

        conf_device.product = self.selected_product
        conf_device.serial_id = self.selected_serial_id

        self.config.conf.devices.append(conf_device)

        
        return conf_device
    }
}


// [EOF]
