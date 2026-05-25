//
//  User.swift
//  EnterpriseApp
//
//  用户数据模型
//

import Foundation

struct User: Codable {
    let username: String
    let role: String
}

struct LoginRequest: Codable {
    let username: String
    let password: String
}

struct LoginResponse: Codable {
    let token: String
    let user: User
}

struct APIResponse<T: Codable>: Codable {
    let success: Bool
    let data: T?
    let message: String?
}
