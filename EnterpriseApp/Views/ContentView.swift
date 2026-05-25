//
//  ContentView.swift
//  EnterpriseApp
//
//  主视图 - 标签栏导航
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        TabView {
            EmployeeListView()
                .tabItem {
                    Label("员工管理", systemImage: "person.3.fill")
                }

            CategoryListView()
                .tabItem {
                    Label("设备分类", systemImage: "square.stack.3d.up.fill")
                }
        }
        .accentColor(.blue)
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthViewModel())
}
