//
//  Employee.swift
//  EnterpriseApp
//
//  员工数据模型
//

import Foundation

struct Employee: Identifiable, Codable {
    let id: String
    var name: String
    var age: Int
    var email: String
    let createdAt: String

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name
        case age
        case email
        case createdAt
    }
}

struct EmployeeCreate: Codable {
    let name: String
    let age: Int
    let email: String
}

struct EmployeeUpdate: Codable {
    let name: String?
    let age: Int?
    let email: String?
}
