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
    @State private var selectedTab: Int = 0
    @Environment(\.modelContext) private var context
    @Query var users: [User]
    @State private var searchText: String = ""
    
    var body: some View {
        TabView {
            Tab {
                NavigationStack {
                    HomeView()
                        .toolbar {
                            ToolbarItem(placement: .cancellationAction) {
                                Button("Profile", systemImage: "gear") {
                                    isShowingProfileView = true
                                }
                            }
                            ToolbarItem() {
                                Button("Add Thought", systemImage: "plus") {
                                    isShowingThoughtEntry = true
                                }
                            }
                        }
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
                NavigationStack {
                    ProfileView()
                }
            } label: {
                Image("User")
                    .renderingMode(.template)
            }

            Tab(role: .search) {
                NavigationStack {
                    SearchView(searchText: $searchText)
                        .searchable(text: $searchText)
                        .navigationTitle("Search")
                }
            } label: {
                Image("Search")
                    .renderingMode(.template)
            }
            // to change tab icon color onSelected add:
            // .tint(.gray)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Thought.self, Category.self], inMemory: false)
}

