//
//  CategoryFormView.swift
//  EnterpriseApp
//
//  分类表单视图
//

import SwiftUI

struct CategoryFormView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: CategoryViewModel

    let category: Category?

    @State private var name = ""
    @State private var isLoading = false
    @State private var errorMessage: String?

    init(viewModel: CategoryViewModel, category: Category? = nil) {
        self.viewModel = viewModel
        self.category = category

        if let category = category {
            _name = State(initialValue: category.name)
        }
    }

    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("分类名称", text: $name)
                }

                if let errorMessage = errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
            }
            .navigationTitle(category == nil ? "添加分类" : "编辑分类")
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
            errorMessage = "请输入分类名称"
            return
        }

        isLoading = true
        errorMessage = nil

        Task {
            do {
                if let category = category {
                    try await viewModel.updateCategory(id: category.id, name: name)
                } else {
                    try await viewModel.createCategory(name: name)
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
    CategoryFormView(viewModel: CategoryViewModel())
}
