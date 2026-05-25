//
//  CategoryListView.swift
//  EnterpriseApp
//
//  分类列表视图
//

import SwiftUI

struct CategoryListView: View {
    @StateObject private var viewModel = CategoryViewModel()
    @State private var showingAddSheet = false
    @State private var categoryToDelete: Category?
    @State private var categoryToEdit: Category?

    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.isLoading && viewModel.categories.isEmpty {
                    ProgressView("加载中...")
                } else if viewModel.categories.isEmpty {
                    emptyView
                } else {
                    categoryList
                }
            }
            .navigationTitle("设备分类")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddSheet = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
            }
            .refreshable {
                await viewModel.loadCategories()
            }
            .task {
                await viewModel.loadCategories()
            }
            .sheet(isPresented: $showingAddSheet) {
                CategoryFormView(viewModel: viewModel)
            }
            .sheet(item: $categoryToEdit) { category in
                CategoryFormView(viewModel: viewModel, category: category)
            }
            .alert("确认删除", isPresented: .constant(categoryToDelete != nil)) {
                Button("取消", role: .cancel) {
                    categoryToDelete = nil
                }
                Button("删除", role: .destructive) {
                    if let category = categoryToDelete {
                        Task {
                            try? await viewModel.deleteCategory(id: category.id)
                            categoryToDelete = nil
                        }
                    }
                }
            } message: {
                Text("确定要删除该分类吗？如果分类下有设备，将无法删除。")
            }
        }
    }

    private var categoryList: some View {
        List {
            ForEach(viewModel.categories) { category in
                NavigationLink(destination: DeviceListView(category: category)) {
                    CategoryRow(category: category)
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button(role: .destructive) {
                        categoryToDelete = category
                    } label: {
                        Label("删除", systemImage: "trash")
                    }

                    Button {
                        categoryToEdit = category
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
            Image(systemName: "square.stack.3d.up")
                .font(.system(size: 60))
                .foregroundColor(.gray)

            Text("暂无分类数据")
                .font(.headline)
                .foregroundColor(.secondary)

            Text("点击右上角按钮创建第一个分类")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

struct CategoryRow: View {
    let category: Category

    var body: some View {
        HStack(spacing: 16) {
            RoundedRectangle(cornerRadius: 12)
                .fill(LinearGradient(colors: [.purple, .pink], startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 50, height: 50)
                .overlay {
                    Image(systemName: "square.stack.3d.up.fill")
                        .foregroundColor(.white)
                        .font(.title3)
                }

            VStack(alignment: .leading, spacing: 6) {
                Text(category.name)
                    .font(.headline)

                Label("\(category.deviceCount) 个设备", systemImage: "laptopcomputer")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
                .font(.caption)
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    CategoryListView()
}
