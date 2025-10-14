//
//  CombinedSearchView.swift
//  JotDown
//
//  Created by Stepan Kravtsov on 10/14/25.
//

import SwiftUI
import SwiftData

struct CombinedSearchView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Thought.dateCreated, order: .reverse) private var thoughts: [Thought]
    
    @State private var searchText: String = ""
    @State var result: String = ""
    @State private var isSearching: Bool = false
    @State private var hasSearched: Bool = false
    // Only searches after .5 seconds of stopped typing
    @State private var searchDebounceWorkItem: DispatchWorkItem?
    private let delayToSearch = 0.5
    var body: some View {
        VStack {
            Text(result)
        }
        .listStyle(.plain)
        .searchable(
            text: $searchText,
            placement: .automatic,
            prompt: "Search thoughts"
        )
        .overlay {
            if searchText.isEmpty && !isSearching{
                ContentUnavailableView(
                    "Search",
                    systemImage: "magnifyingglass",
                    description: Text("Enter a query to search your thoughts.")
                )
            } else if result == "" {
                ContentUnavailableView.search(text: searchText)
            }
        }
        .onChange(of: searchText) { _, _ in
            // Cancel any existing pending search
            searchDebounceWorkItem?.cancel()
            
            // If the search text is empty, don’t schedule a new search
            guard !searchText.isEmpty else { return }
            
            let workItem = DispatchWorkItem {
                isSearching = true
                Task {
                    let r = await searchRagFoundationQuery(query: searchText, in: thoughts)
                    await MainActor.run {
                        result = r
                        isSearching = false
                    }
                }
                
            }
            // Store it so we can cancel if needed
            searchDebounceWorkItem = workItem
            
            // Schedule it to run after 0.5 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + delayToSearch, execute: workItem)
        }
        .navigationTitle("Smart search")
    }
    
    private func searchRagFoundationQuery(query: String, in thoughts: [Thought]) async -> String {
        let ragSystem = RAGSystem()
        let results = ragSystem.sortThoughts(thoughts: thoughts, query: query, limit: 5)
        let queryResult = await FoundationModelSearchService.queryResponseGenerator(query: query, in: results)
        return queryResult
        
    }
}

#Preview {
    CombinedSearchView()
}
