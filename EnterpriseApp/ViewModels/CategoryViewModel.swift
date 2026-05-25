//
//  CategoryViewModel.swift
//  EnterpriseApp
//
//  分类视图模型
//

import Foundation
import SwiftUI

@MainActor
class CategoryViewModel: ObservableObject {
    @Published var categories: [Category] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    func loadCategories() async {
        isLoading = true
        errorMessage = nil

        do {
            categories = try await APIService.shared.getCategories()
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func createCategory(name: String) async throws {
        let category = CategoryCreate(name: name)
        _ = try await APIService.shared.createCategory(category)
        await loadCategories()
    }

    func updateCategory(id: String, name: String) async throws {
        let category = CategoryUpdate(name: name)
        _ = try await APIService.shared.updateCategory(id: id, category: category)
        await loadCategories()
    }

    func deleteCategory(id: String) async throws {
        try await APIService.shared.deleteCategory(id: id)
        await loadCategories()
    }
}
