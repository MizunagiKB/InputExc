//
//  schema.swift
//  InputExc
//

import Foundation


class IExcButton: Codable {
    var id: Int32 = 0
    var name: String = ""

    var shift: Bool = false
    var control: Bool = false
    var alternate: Bool = false
    var command: Bool = false
    var character: String = ""
}


class IExcPage: Codable {
    var id: Int32 = 0
    var name: String = ""
    var buttons: Array<IExcButton> = []
}


class IExcDevice: Codable {
    var vendor: Int32 = 0
    var product: Int32 = 0
    var name: String = ""
    var pages: Array<IExcPage> = []
}


class IExcSettings: Codable {
    var devices: Array<IExcDevice> = []
}

