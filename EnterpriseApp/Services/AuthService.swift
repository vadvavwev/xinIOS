//
//  AuthService.swift
//  EnterpriseApp
//
//  认证服务
//

import Foundation

class AuthService {
    static let shared = AuthService()

    private init() {}

    func login(username: String, password: String) async throws -> User {
        let response = try await APIService.shared.login(username: username, password: password)

        // Save token and user
        KeychainService.shared.saveToken(response.token)
        KeychainService.shared.saveUser(response.user)

        return response.user
    }

    func logout() {
        KeychainService.shared.deleteToken()
        KeychainService.shared.deleteUser()
    }

    func getCurrentUser() -> User? {
        return KeychainService.shared.getUser()
    }

    func isAuthenticated() -> Bool {
        return KeychainService.shared.getToken() != nil
    }
}
