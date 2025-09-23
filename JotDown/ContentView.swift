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
    
    var body: some View {
        NavigationStack {
            ThoughtsListView()
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Profile", systemImage: "gear") {
                            isShowingProfileView = true
                        }
                    }
                    ToolbarItem() {
                        Button("Add Thought", systemImage: "plus") {
                            //TODO: Add Functionality to Lead to ThoughtEntryView
                        }
                    }
                }
        }
        .sheet(isPresented: $isShowingProfileView) {
            ProfileView()
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Thought.self, Category.self], inMemory: false)
}
