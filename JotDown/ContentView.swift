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
    
    var body: some View {
        NavigationStack {
            ThoughtsListView()
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Profile", systemImage: "gear") {
                            isShowingProfileView = true
                        }
                    }
                }
        }
        .sheet(isPresented: $isShowingProfileView) {
            ProfileView()
        }
        .sheet(isPresented: $isShowingThoughtEntry) {
            ThoughtsEntryView()
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Thought.self, Category.self], inMemory: false)
}
