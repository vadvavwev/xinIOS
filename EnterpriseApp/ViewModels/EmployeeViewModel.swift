//
//  EmployeeViewModel.swift
//  EnterpriseApp
//
//  员工视图模型
//

import Foundation
import SwiftUI

@MainActor
class EmployeeViewModel: ObservableObject {
    @Published var employees: [Employee] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    func loadEmployees() async {
        isLoading = true
        errorMessage = nil

        do {
            employees = try await APIService.shared.getEmployees()
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func createEmployee(name: String, age: Int, email: String) async throws {
        let employee = EmployeeCreate(name: name, age: age, email: email)
        _ = try await APIService.shared.createEmployee(employee)
        await loadEmployees()
    }

    func updateEmployee(id: String, name: String, age: Int, email: String) async throws {
        let employee = EmployeeUpdate(name: name, age: age, email: email)
        _ = try await APIService.shared.updateEmployee(id: id, employee: employee)
        await loadEmployees()
    }

    func deleteEmployee(id: String) async throws {
        try await APIService.shared.deleteEmployee(id: id)
        await loadEmployees()
    }
}
