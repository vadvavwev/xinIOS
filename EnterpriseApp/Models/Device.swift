//
//  Device.swift
//  EnterpriseApp
//
//  设备数据模型
//

import Foundation

struct Device: Identifiable, Codable {
    let id: String
    var name: String
    var model: String?
    var categoryId: String
    var categoryName: String?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name
        case model
        case categoryId
        case categoryName
    }
}

struct DeviceCreate: Codable {
    let name: String
    let model: String?
    let categoryId: String
}

struct DeviceUpdate: Codable {
    let name: String?
    let model: String?
    let categoryId: String?
}
