//
//  schema.swift
//  InputExc
//

import Foundation


class IConfAction {
    var usage: Int32 = 0
    var value: Int32? = nil
    var name: String = ""

    var shift: Bool = false
    var control: Bool = false
    var alternate: Bool = false
    var command: Bool = false
    var character: String = ""

    init() {}
    init(j: JSON) { self.from_json_object(j: j) }
    
    func from_json_object(j: JSON)
    {
        self.usage = j["usage"].int32Value

        self.value = j["value"].rawValue as? Int32

        self.name = j["name"].stringValue
        self.shift = j["shift"].boolValue
        self.control = j["control"].boolValue
        self.alternate = j["alternate"].boolValue
        self.command = j["command"].boolValue
        self.character = j["character"].stringValue
    }

    func to_json_object() -> JSON
    {
        var js_result: JSON = JSON()

        js_result["usage"].int32 = self.usage

        if self.value == nil {} else { js_result["value"].int32 = self.value }

        js_result["name"].string = self.name
        js_result["shift"].bool = self.shift
        js_result["control"].bool = self.control
        js_result["alternate"].bool = self.alternate
        js_result["command"].bool = self.command
        js_result["character"].string = self.character

        return js_result
    }
}


class IConfPage {
    var name: String = ""
    var actions: Array<IConfAction> = []

    init() {}
    init(j: JSON) { self.from_json_object(j: j) }
    
    func from_json_object(j: JSON)
    {
        self.name = j["name"].stringValue
        self.actions = j["actions"].arrayValue.map {IConfAction(j: $0)}
    }

    func to_json_object() -> JSON
    {
        var js_result: JSON = JSON()

        js_result["name"].string = self.name
        js_result["actions"].arrayObject = self.actions.map {$0.to_json_object()}
        
        return js_result
    }
}


class IConfDevice: ObservableObject {
    @Published var product: String = ""
    @Published var vendor_id: Int32 = 0
    @Published var product_id: Int32 = 0
    @Published var serial_id: String = ""

    @Published var pages: Array<IConfPage> = []

    init() {}
    init(j: JSON) { self.from_json_object(j: j) }
    
    func from_json_object(j: JSON)
    {
        self.product = j["product"].stringValue
        self.vendor_id = j["vendor_id"].int32Value
        self.product_id = j["product_id"].int32Value
        self.serial_id = j["serial_id"].stringValue
        self.pages = j["pages"].arrayValue.map {IConfPage(j: $0)}
    }

    func to_json_object() -> JSON
    {
        var js_result: JSON = JSON()

        js_result["product"].string = self.product
        js_result["vendor_id"].int32 = self.vendor_id
        js_result["product_id"].int32 = self.product_id
        js_result["serial_id"].string = self.serial_id
        js_result["pages"].arrayObject = self.pages.map {$0.to_json_object()}
        
        return js_result
    }
}


class IConfDevices {
    var devices: Array<IConfDevice> = []

    init() {}
    init(j: JSON) { self.from_json_object(j: j) }
    
    func from_json_object(j: JSON)
    {
        self.devices = j["devices"].arrayValue.map {IConfDevice(j: $0)}
    }

    func to_json_object() -> JSON
    {
        var js_result: JSON = JSON()

        js_result["devices"].arrayObject = self.devices.map {$0.to_json_object()}
        
        return js_result
    }
}

