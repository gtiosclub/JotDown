//
//  WatchSearchView.swift
//  JotDownWatch Watch App
//
//  Created by Jeet Ajmani on 2025-10-23.
//

import SwiftUI

struct WatchSearchView: View {
    
    private var session = WatchSessionManager.shared
    @State private var searchInput: String = ""
    @State private var showResults = false
    
    var body: some View {
        
        NavigationStack {
            VStack {
                TextField("Search Thoughts", text: $searchInput)
                    .padding()
                HStack {
                    Button("Clear") {
                        searchInput = ""
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.red)
                    .disabled(searchInput.isEmpty)
                    
                    Button("Search") {
                        session.sendSearch(searchInput)
                        showResults = true
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.yellow)
                    .foregroundColor(.black)
                    .disabled(searchInput.isEmpty)
                    
                }
            }
        }
        .navigationDestination(isPresented: $showResults) {
            WatchThoughtsListView(title: "Search Results")
        }
        .navigationTitle("Search")
    }
}

#Preview {
    WatchSearchView()
}
