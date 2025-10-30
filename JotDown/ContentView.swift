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
    
    @State private var activeTab: Int = 0
    @State private var thoughtToSelect: Thought? = nil
    
    var body: some View {
        TabView(selection: $activeTab) {
            NavigationStack {
                HomeView(thoughtToSelect: $thoughtToSelect)
            }
            .onAppear {
                if users.isEmpty {
                    let defaultUser = User(name: "", bio: "")
                    context.insert(defaultUser)
                }
            }
            .tabItem {
                Image("Visualize")
                    .renderingMode(.template)
            }
            .tag(0)
            
            DashboardView(onThoughtSelected: { thought in
                thoughtToSelect = thought
                activeTab = 0
            })
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
                SearchView(searchText: $searchText)
                    .searchable(text: $searchText)
                    .navigationTitle("Search")
            }
            .tabItem {
                Image("Search")
                    .renderingMode(.template)
            }
            .tag(3)
        }
        // to change tab icon color onSelected add:
        // .tint(.gray)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Thought.self, Category.self], inMemory: false)
}
