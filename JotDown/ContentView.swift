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
    
    var body: some View {
        TabView {
            Tab {
                NavigationStack {
                    HomeView()
                }
                .onAppear {
                    if users.isEmpty {
                        let defaultUser = User(name: "", bio: "")
                        context.insert(defaultUser)
                    }
                }
            } label: {
                Image("Visualize")
                    .renderingMode(.template)
            }
            
            Tab {
                DashboardView()
            } label: {
                Image("Dashboard")
                    .renderingMode(.template)
            }
            
            Tab {
                NavigationStack {
                    ProfileView()
                }
            } label: {
                Image("User")
                    .renderingMode(.template)
            }
            
            Tab {
                NavigationStack {
                    VisualizationView()
                }
            } label: {
                Image(.dashboard)
                    .renderingMode(.template)
            }
            
            Tab(role: .search) {
                NavigationStack {
                    CombinedSearchView()
                        .navigationTitle("Search")
                }
            } label: {
                Image("Search")
                    .renderingMode(.template)
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

