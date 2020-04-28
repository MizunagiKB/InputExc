//
//  json_configure.swift
//  InputExc
//

import Foundation
import Carbon.HIToolbox





class JsonConfigure: NSObject {

    let configure_default = "default-TABMATE"
    let configure_dir = ".InputExc"
    let configure = "configure.json"
    

    func create_dir() {

        let m = FileManager.default
        let target_dir = NSHomeDirectory() + self.configure_dir

        if m.fileExists(atPath: target_dir) == false {
            do {
                try m.createDirectory(atPath: target_dir, withIntermediateDirectories: true, attributes: nil)
            } catch {
                NSLog("Failure configure dir %s", target_dir)
            }
        }
    }


    func load_default() -> IExcSettings {

        let json_url: URL = Bundle.main.url(forResource: self.configure_default, withExtension: "json")!

        do {
            let raw_json: String! = try String(contentsOf: json_url)
            let raw_data: Data! = raw_json.data(using: String.Encoding.utf8)
        
            return try JSONDecoder().decode(IExcSettings.self, from: raw_data)
        } catch {
            return IExcSettings()
        }
    }


    func load() -> IExcSettings! {

        let m = FileManager.default
        let json_url: URL = m.homeDirectoryForCurrentUser
            .appendingPathComponent(self.configure_dir)
            .appendingPathComponent(self.configure)

        do {
            let raw_json: String! = try String(contentsOf: json_url)
            let raw_data: Data! = raw_json.data(using: String.Encoding.utf8)
        
            return try JSONDecoder().decode(IExcSettings.self, from: raw_data)
        } catch {
            return self.load_default()
        }
    }

    
    func save(iexc_settings: IExcSettings) {

        let o_enc = JSONEncoder()
        let m = FileManager.default
        let json_url: URL = m.homeDirectoryForCurrentUser
            .appendingPathComponent(self.configure_dir)
            .appendingPathComponent(self.configure)

        do {
            o_enc.outputFormatting = .prettyPrinted

            let raw_json = try o_enc.encode(iexc_settings)
            try raw_json.write(to: json_url)

        } catch {
        }
    }
}
