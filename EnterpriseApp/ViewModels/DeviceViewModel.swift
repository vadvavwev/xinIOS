//
//  DeviceViewModel.swift
//  EnterpriseApp
//
//  设备视图模型
//

import Foundation
import SwiftUI

@MainActor
class DeviceViewModel: ObservableObject {
    @Published var devices: [Device] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    func loadDevices(categoryId: String) async {
        isLoading = true
        errorMessage = nil

        do {
            devices = try await APIService.shared.getDevices(categoryId: categoryId)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func createDevice(name: String, model: String?, categoryId: String) async throws {
        let device = DeviceCreate(name: name, model: model, categoryId: categoryId)
        _ = try await APIService.shared.createDevice(device)
        await loadDevices(categoryId: categoryId)
    }

    func updateDevice(id: String, name: String, model: String?, categoryId: String) async throws {
        let device = DeviceUpdate(name: name, model: model, categoryId: categoryId)
        _ = try await APIService.shared.updateDevice(id: id, device: device)
        await loadDevices(categoryId: categoryId)
    }

    func deleteDevice(id: String, categoryId: String) async throws {
        try await APIService.shared.deleteDevice(id: id)
        await loadDevices(categoryId: categoryId)
    }
}
