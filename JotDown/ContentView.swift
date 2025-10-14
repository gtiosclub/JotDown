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
    
    var body: some View {
        TabView {
            NavigationStack {
                HomeView()
            }
            .sheet(isPresented: $isShowingProfileView) {
                ProfileView()
            }
            .sheet(isPresented: $isShowingThoughtEntry) {
                ThoughtsEntryView()
            }
            .onAppear {
                if users.isEmpty {
                    let defaultUser = User(name: "", bio: "")
                    context.insert(defaultUser)
                }
            }.tabItem {
                Label("Thoughts", systemImage: "list.bullet")
            }

            NavigationStack {
                SearchView()
                    .navigationTitle("Search")
            }
            .tabItem {
                Label("Search", systemImage: "magnifyingglass")
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Thought.self, Category.self], inMemory: false)
}
