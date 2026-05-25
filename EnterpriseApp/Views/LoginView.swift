//
//  LoginView.swift
//  EnterpriseApp
//
//  登录视图
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var username = ""
    @State private var password = ""

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color.blue, Color.purple],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 30) {
                Spacer()

                // Logo
                VStack(spacing: 16) {
                    Image(systemName: "building.2.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.white)

                    Text("企业办公助手")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    Text("HR 移动管理系统")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.9))
                }

                Spacer()

                // Login form
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("用户名")
                            .font(.headline)
                            .foregroundColor(.primary)

                        TextField("请输入用户名", text: $username)
                            .textFieldStyle(RoundedTextFieldStyle())
                            .autocapitalization(.none)
                            .disabled(authViewModel.isLoading)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("密码")
                            .font(.headline)
                            .foregroundColor(.primary)

                        SecureField("请输入密码", text: $password)
                            .textFieldStyle(RoundedTextFieldStyle())
                            .disabled(authViewModel.isLoading)
                    }

                    if let errorMessage = authViewModel.errorMessage {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(.red)
                    }

                    Button(action: handleLogin) {
                        if authViewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("登录")
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(16)
                    .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
                    .disabled(authViewModel.isLoading)

                    VStack(spacing: 4) {
                        Text("测试账号信息")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("账号：admin / 密码：admin123")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 8)
                }
                .padding(24)
                .background(Color(.systemBackground))
                .cornerRadius(24)
                .shadow(radius: 20)
                .padding(.horizontal, 24)

                Spacer()
            }
        }
    }

    private func handleLogin() {
        Task {
            await authViewModel.login(username: username, password: password)
        }
    }
}

struct RoundedTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthViewModel())
}
