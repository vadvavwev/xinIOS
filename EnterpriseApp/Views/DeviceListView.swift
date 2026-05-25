//
//  DeviceListView.swift
//  EnterpriseApp
//
//  设备列表视图
//

import SwiftUI

struct DeviceListView: View {
    let category: Category

    @StateObject private var viewModel = DeviceViewModel()
    @State private var showingAddSheet = false
    @State private var deviceToDelete: Device?
    @State private var deviceToEdit: Device?

    var body: some View {
        ZStack {
            if viewModel.isLoading && viewModel.devices.isEmpty {
                ProgressView("加载中...")
            } else if viewModel.devices.isEmpty {
                emptyView
            } else {
                deviceList
            }
        }
        .navigationTitle(category.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingAddSheet = true }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                }
            }
        }
        .refreshable {
            await viewModel.loadDevices(categoryId: category.id)
        }
        .task {
            await viewModel.loadDevices(categoryId: category.id)
        }
        .sheet(isPresented: $showingAddSheet) {
            DeviceFormView(viewModel: viewModel, categoryId: category.id)
        }
        .sheet(item: $deviceToEdit) { device in
            DeviceFormView(viewModel: viewModel, categoryId: category.id, device: device)
        }
        .alert("确认删除", isPresented: .constant(deviceToDelete != nil)) {
            Button("取消", role: .cancel) {
                deviceToDelete = nil
            }
            Button("删除", role: .destructive) {
                if let device = deviceToDelete {
                    Task {
                        try? await viewModel.deleteDevice(id: device.id, categoryId: category.id)
                        deviceToDelete = nil
                    }
                }
            }
        } message: {
            Text("确定要删除该设备吗？此操作无法撤销。")
        }
    }

    private var deviceList: some View {
        List {
            ForEach(viewModel.devices) { device in
                DeviceRow(device: device)
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            deviceToDelete = device
                        } label: {
                            Label("删除", systemImage: "trash")
                        }

                        Button {
                            deviceToEdit = device
                        } label: {
                            Label("编辑", systemImage: "pencil")
                        }
                        .tint(.blue)
                    }
            }
        }
        .listStyle(.insetGrouped)
    }

    private var emptyView: some View {
        VStack(spacing: 16) {
            Image(systemName: "laptopcomputer")
                .font(.system(size: 60))
                .foregroundColor(.gray)

            Text("该分类下暂无设备")
                .font(.headline)
                .foregroundColor(.secondary)

            Text("点击右上角按钮添加第一个设备")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

struct DeviceRow: View {
    let device: Device

    var body: some View {
        HStack(spacing: 16) {
            RoundedRectangle(cornerRadius: 12)
                .fill(LinearGradient(colors: [.green, .teal], startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 50, height: 50)
                .overlay {
                    Image(systemName: "laptopcomputer")
                        .foregroundColor(.white)
                        .font(.title3)
                }

            VStack(alignment: .leading, spacing: 6) {
                Text(device.name)
                    .font(.headline)

                if let model = device.model, !model.isEmpty {
                    Text(model)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.1))
                        .foregroundColor(.blue)
                        .cornerRadius(8)
                }

                if let categoryName = device.categoryName {
                    Text("分类: \(categoryName)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    NavigationView {
        DeviceListView(category: Category(id: "1", name: "办公设备", deviceCount: 0))
    }
}
