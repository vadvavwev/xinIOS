//
//  EmployeeFormView.swift
//  EnterpriseApp
//
//  员工表单视图
//

import SwiftUI

struct EmployeeFormView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: EmployeeViewModel

    let employee: Employee?

    @State private var name = ""
    @State private var age = ""
    @State private var email = ""
    @State private var isLoading = false
    @State private var errorMessage: String?

    init(viewModel: EmployeeViewModel, employee: Employee? = nil) {
        self.viewModel = viewModel
        self.employee = employee

        if let employee = employee {
            _name = State(initialValue: employee.name)
            _age = State(initialValue: "\(employee.age)")
            _email = State(initialValue: employee.email)
        }
    }

    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("姓名", text: $name)
                    TextField("年龄", text: $age)
                        .keyboardType(.numberPad)
                    TextField("邮箱", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                }

                if let errorMessage = errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
            }
            .navigationTitle(employee == nil ? "添加员工" : "编辑员工")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        handleSave()
                    }
                    .disabled(isLoading)
                }
            }
            .disabled(isLoading)
            .overlay {
                if isLoading {
                    ProgressView()
                }
            }
        }
    }

    private func handleSave() {
        guard !name.isEmpty, !age.isEmpty, !email.isEmpty else {
            errorMessage = "请填写所有字段"
            return
        }

        guard let ageInt = Int(age), ageInt >= 18, ageInt <= 60 else {
            errorMessage = "年龄必须在18-60之间"
            return
        }

        isLoading = true
        errorMessage = nil

        Task {
            do {
                if let employee = employee {
                    try await viewModel.updateEmployee(id: employee.id, name: name, age: ageInt, email: email)
                } else {
                    try await viewModel.createEmployee(name: name, age: ageInt, email: email)
                }
                dismiss()
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }
}

#Preview {
    EmployeeFormView(viewModel: EmployeeViewModel())
}
