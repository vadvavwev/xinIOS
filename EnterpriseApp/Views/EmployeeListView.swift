//
//  EmployeeListView.swift
//  EnterpriseApp
//
//  员工列表视图
//

import SwiftUI

struct EmployeeListView: View {
    @StateObject private var viewModel = EmployeeViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showingAddSheet = false
    @State private var employeeToDelete: Employee?
    @State private var employeeToEdit: Employee?

    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.isLoading && viewModel.employees.isEmpty {
                    ProgressView("加载中...")
                } else if viewModel.employees.isEmpty {
                    emptyView
                } else {
                    employeeList
                }
            }
            .navigationTitle("员工管理")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddSheet = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }

                ToolbarItem(placement: .navigationBarLeading) {
                    Button("登出") {
                        authViewModel.logout()
                    }
                }
            }
            .refreshable {
                await viewModel.loadEmployees()
            }
            .task {
                await viewModel.loadEmployees()
            }
            .sheet(isPresented: $showingAddSheet) {
                EmployeeFormView(viewModel: viewModel)
            }
            .sheet(item: $employeeToEdit) { employee in
                EmployeeFormView(viewModel: viewModel, employee: employee)
            }
            .alert("确认删除", isPresented: .constant(employeeToDelete != nil)) {
                Button("取消", role: .cancel) {
                    employeeToDelete = nil
                }
                Button("删除", role: .destructive) {
                    if let employee = employeeToDelete {
                        Task {
                            try? await viewModel.deleteEmployee(id: employee.id)
                            employeeToDelete = nil
                        }
                    }
                }
            } message: {
                Text("确定要删除该员工吗？此操作无法撤销。")
            }
        }
    }

    private var employeeList: some View {
        List {
            ForEach(viewModel.employees) { employee in
                EmployeeRow(employee: employee)
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            employeeToDelete = employee
                        } label: {
                            Label("删除", systemImage: "trash")
                        }

                        Button {
                            employeeToEdit = employee
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
            Image(systemName: "person.3")
                .font(.system(size: 60))
                .foregroundColor(.gray)

            Text("暂无员工数据")
                .font(.headline)
                .foregroundColor(.secondary)

            Text("点击右上角按钮添加第一个员工")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

struct EmployeeRow: View {
    let employee: Employee

    var body: some View {
        HStack(spacing: 16) {
            Circle()
                .fill(LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 50, height: 50)
                .overlay {
                    Image(systemName: "person.fill")
                        .foregroundColor(.white)
                        .font(.title3)
                }

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(employee.name)
                        .font(.headline)

                    Text("\(employee.age)岁")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.1))
                        .foregroundColor(.blue)
                        .cornerRadius(8)
                }

                Label(employee.email, systemImage: "envelope")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                if let date = ISO8601DateFormatter().date(from: employee.createdAt) {
                    Text("入职时间: \(date, style: .date)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    EmployeeListView()
        .environmentObject(AuthViewModel())
}
