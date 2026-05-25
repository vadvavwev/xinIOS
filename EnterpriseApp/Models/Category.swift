//
//  Category.swift
//  EnterpriseApp
//
//  设备分类数据模型
//

import Foundation

struct Category: Identifiable, Codable {
    let id: String
    var name: String
    var deviceCount: Int

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name
        case deviceCount
    }
}

struct CategoryCreate: Codable {
    let name: String
}

struct CategoryUpdate: Codable {
    let name: String?
}
