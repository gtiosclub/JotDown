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
    @Query var categories: [Category]
    
    var body: some View {
        VStack {
            switch selectedTab {
            case 0:
                NavigationStack {
                    HomeView(selectedTab: $selectedTab)
                }
                .sheet(isPresented: $isShowingProfileView) {
                    ProfileView(selectedTab: $selectedTab)
                }
                .onAppear {
                    if users.isEmpty {
                        let defaultUser = User(name: "", bio: "")
                        context.insert(defaultUser)
                    }
                }
            case 1:
                NavigationStack {
                    DashboardView(selectedTab: $selectedTab)
                }
            case 2:
                NavigationStack {
                    SearchView(selectedTab: $selectedTab)
                        .navigationTitle("Search")
                }
            case 3:
                NavigationStack {
                    ProfileView(selectedTab: $selectedTab)
                }
            default:
                NavigationStack {
                    HomeView(selectedTab: $selectedTab)
                }
                
            }
        }
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: Int
    
    var body: some View {
        HStack(spacing: 0) {
            // Thoughts Tab
            Button(action: { selectedTab = 0 }) {
                Image("Visualize")
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundColor(.black)
            }
            
            Spacer()
            
            // Dashboard Tab
            Button(action: { selectedTab = 1 }) {
                Image("User")
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundColor(.black)
            }
            
            Spacer()
            
            // Search Tab
            Button(action: { selectedTab = 2 }) {
                Image("Search")
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundColor(.black)
            }
            
            Spacer()
            
            // Profile Tab
            Button(action: { selectedTab = 3 }) {
                Image("User")
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundColor(.black)
            }
            
        }
        .padding(.horizontal, 53)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 30)
                .fill(.ultraThinMaterial)
                //.glassEffect()
        )
        .padding(.horizontal, 30)
        .padding(.bottom, 20)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Thought.self, Category.self], inMemory: false)
}
