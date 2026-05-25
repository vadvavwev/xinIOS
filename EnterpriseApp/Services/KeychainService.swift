//
//  KeychainService.swift
//  EnterpriseApp
//
//  Keychain安全存储服务
//

import Foundation
import Security

class KeychainService {
    static let shared = KeychainService()

    private let tokenKey = "com.enterprise.authToken"
    private let userKey = "com.enterprise.user"

    // MARK: - Token

    func saveToken(_ token: String) {
        save(token, forKey: tokenKey)
    }

    func getToken() -> String? {
        return get(forKey: tokenKey)
    }

    func deleteToken() {
        delete(forKey: tokenKey)
    }

    // MARK: - User

    func saveUser(_ user: User) {
        if let encoded = try? JSONEncoder().encode(user) {
            save(String(data: encoded, encoding: .utf8) ?? "", forKey: userKey)
        }
    }

    func getUser() -> User? {
        guard let string = get(forKey: userKey),
              let data = string.data(using: .utf8),
              let user = try? JSONDecoder().decode(User.self, from: data) else {
            return nil
        }
        return user
    }

    func deleteUser() {
        delete(forKey: userKey)
    }

    // MARK: - Private Methods

    private func save(_ value: String, forKey key: String) {
        guard let data = value.data(using: .utf8) else { return }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]

        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }

    private func get(forKey key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess,
              let data = result as? Data,
              let value = String(data: data, encoding: .utf8) else {
            return nil
        }

        return value
    }

    private func delete(forKey key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]

        SecItemDelete(query as CFDictionary)
    }
}
