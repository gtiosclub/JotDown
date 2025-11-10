//
//  ContentView.swift
//  JotDown
//
//  Created by Rahul on 9/22/25.
//

import SwiftData
import SwiftUI

struct ContentView: View {
    @State private var isShowingProfileView = false
    @State private var isShowingThoughtEntry = true
    @Environment(\.modelContext) private var context
    @Query var users: [User]
    @State private var searchText: String = ""
    @State private var selectedTab = 0
    @Namespace private var ns
    @State private var categoryToPresent: Category? = nil
    @State private var dashboardResetID = UUID()

    
    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                HomeView(selectedTab: $selectedTab, categoryToPresent: $categoryToPresent)
                    .onAppear {
                        if users.isEmpty {
                            let defaultUser = User(name: "", bio: "")
                            context.insert(defaultUser)
                        }
                    }
            }
            .tabItem {
                Image("Visualize")
                    .renderingMode(.template)
            }
            .tag(0)
            
            NavigationStack {
                DashboardView()
            }
            .id(dashboardResetID)
            .tabItem {
                Image("Dashboard")
                    .renderingMode(.template)
            }
            .tag(1)
            
            NavigationStack {
                ProfileView()
            }
            .tabItem {
                Image("User")
                    .renderingMode(.template)
            }
            .tag(2)
            
            NavigationStack {
                VisualizationView()
            }
            .tabItem {
                Image(.dashboard)
                    .renderingMode(.template)
            }
            .tag(3)
            
            NavigationStack {
                CombinedSearchView()
            }
            .tabItem {
                Image("Search")
                    .renderingMode(.template)
            }
            .tag(4)
            
        }
        .onChange(of: selectedTab) { oldValue, newValue in
            if oldValue == 1 && newValue != 1 {
                dashboardResetID = UUID()
                categoryToPresent = nil
            }
        }
        .fullScreenCover(item: $categoryToPresent) { show in
            CategoryDashboardView(
                category: show,
                namespace: ns,
                onDismiss: { categoryToPresent = nil }
            )
        }
        // to change tab icon color onSelected add:
        // .tint(.gray)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Thought.self, Category.self], inMemory: false)
}

