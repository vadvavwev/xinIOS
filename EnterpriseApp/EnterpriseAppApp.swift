//
//  EnterpriseAppApp.swift
//  EnterpriseApp
//
//  企业办公助手 - SwiftUI应用入口
//

import SwiftUI

@main
struct EnterpriseAppApp: App {
    @StateObject private var authViewModel = AuthViewModel()

    var body: some Scene {
        WindowGroup {
            if authViewModel.isAuthenticated {
                ContentView()
                    .environmentObject(authViewModel)
            } else {
                LoginView()
                    .environmentObject(authViewModel)
            }
        }
    }
}
