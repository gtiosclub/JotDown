//
//  ContentView.swift
//  JotDown
//
//  Created by Rahul on 9/22/25.
//

import SwiftData
import SwiftUI

import Foundation

extension Notification.Name {
    static let openCategory = Notification.Name("openCategory")
}


struct ContentView: View {
    @Environment(\.modelContext) private var context
    @Query var users: [User]

    @State private var selectedTab = 0
    @Namespace private var ns
    @State private var dashboardResetID = UUID()
    
    @State private var pendingDashboardResetToken: UUID? = nil
    private let dashboardResetDelay: TimeInterval = 0.35


    var body: some View {
        TabView(selection: $selectedTab) {
            Tab(value: 0) {
                NavigationStack {
                    HomeView(selectedTab: $selectedTab)
                        .onAppear {
                            if users.isEmpty {
                                let defaultUser = User(name: "", bio: "")
                                context.insert(defaultUser)
                            }
                        }
                }
            } label: {
                Image("Home")
                    .renderingMode(.template)
            }

            Tab(value: 1) {
                NavigationStack {
                    DashboardView()
                }
                .id(dashboardResetID)
            } label: {
                Image("Dashboard")
                    .renderingMode(.template)
            }

            Tab(value: 2) {
                NavigationStack {
                    ProfileView()
                }
            } label: {
                Image("User")
                    .renderingMode(.template)
            }

            Tab(value: 3, role: .search) {
                NavigationStack {
                    CombinedSearchView()
                }
            } label: {
                Image("Search")
                    .renderingMode(.template)
            }
        }
        .onChange(of: selectedTab) { oldValue, newValue in
            // came to dashboard so cancel any pending reset
            if newValue == 1 {
                pendingDashboardResetToken = nil
                return
            }

            // we just left category screen, so start a delayed reset
            if oldValue == 1 && newValue != 1 {
                let token = UUID()
                pendingDashboardResetToken = token

                DispatchQueue.main.asyncAfter(deadline: .now() + dashboardResetDelay) {
                    guard selectedTab != 1, pendingDashboardResetToken == token else { return }

                    withTransaction(Transaction(animation: nil)) {
                        dashboardResetID = UUID()
                    }

                    pendingDashboardResetToken = nil
                }
            }
        }
        // to change tab icon color onSelected add:
        // .tint(.gray)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Thought.self, Category.self], inMemory: false)
}
