//
//  DeviceFormView.swift
//  EnterpriseApp
//
//  设备表单视图
//

import SwiftUI

struct DeviceFormView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: DeviceViewModel

    let categoryId: String
    let device: Device?

    @State private var name = ""
    @State private var model = ""
    @State private var isLoading = false
    @State private var errorMessage: String?

    init(viewModel: DeviceViewModel, categoryId: String, device: Device? = nil) {
        self.viewModel = viewModel
        self.categoryId = categoryId
        self.device = device

        if let device = device {
            _name = State(initialValue: device.name)
            _model = State(initialValue: device.model ?? "")
        }
    }

    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("设备名称", text: $name)
                    TextField("型号（可选）", text: $model)
                }

                if let errorMessage = errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
            }
            .navigationTitle(device == nil ? "添加设备" : "编辑设备")
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
        guard !name.isEmpty else {
            errorMessage = "请输入设备名称"
            return
        }

        isLoading = true
        errorMessage = nil

        let modelValue = model.isEmpty ? nil : model

        Task {
            do {
                if let device = device {
                    try await viewModel.updateDevice(id: device.id, name: name, model: modelValue, categoryId: categoryId)
                } else {
                    try await viewModel.createDevice(name: name, model: modelValue, categoryId: categoryId)
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
    DeviceFormView(viewModel: DeviceViewModel(), categoryId: "1")
}
