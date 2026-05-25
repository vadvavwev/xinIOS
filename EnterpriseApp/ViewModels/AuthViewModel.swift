//
//  AuthViewModel.swift
//  EnterpriseApp
//
//  认证视图模型
//

import Foundation
import SwiftUI

@MainActor
class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var errorMessage: String?

    init() {
        checkAuthStatus()
    }

    func checkAuthStatus() {
        isAuthenticated = AuthService.shared.isAuthenticated()
        currentUser = AuthService.shared.getCurrentUser()
    }

    func login(username: String, password: String) async {
        isLoading = true
        errorMessage = nil

        do {
            let user = try await AuthService.shared.login(username: username, password: password)
            currentUser = user
            isAuthenticated = true
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func logout() {
        AuthService.shared.logout()
        currentUser = nil
        isAuthenticated = false
    }
}
