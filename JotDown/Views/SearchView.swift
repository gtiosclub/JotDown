import SwiftUI
import SwiftData
import FoundationModels

enum SearchMode: String, CaseIterable, Identifiable {
    case regexContains = "Regex/Contains"
    case foundationModels = "Foundation Models"
    case rag = "RAG"

    var id: Self { self }
}

struct SearchView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Thought.dateCreated, order: .reverse) private var thoughts: [Thought]
    
    @Binding var searchText: String
    @State private var mode: SearchMode = .regexContains
    @State private var results: [Thought] = []
    @State private var isSearching: Bool = false
    @State private var hasSearched: Bool = false
    // Only searches after .5 seconds of stopped typing
    @State private var searchDebounceWorkItem: DispatchWorkItem?
    private let delayToSearch = 0.5


    var body: some View {
        VStack {
            List(results) { thought in
                VStack(alignment: .leading) {
                    HStack {
                        Text(thought.dateCreated, style: .date)
                        Spacer()
                        Text(thought.category.name)
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    
                    Text(thought.content)
                }
            }
            .listStyle(.plain)
            .searchable(
                text: $searchText,
                placement: .automatic,
                prompt: "Search thoughts"
            )
            .overlay {
                if searchText.isEmpty {
                    ContentUnavailableView(
                        "Search",
                        systemImage: "magnifyingglass",
                        description: Text("Enter a query to search your thoughts.")
                    )
                } else if results.isEmpty {
                    ContentUnavailableView.search(text: searchText)
                }
            }
            .onChange(of: searchText) { _, _ in
                // Cancel any existing pending search
                searchDebounceWorkItem?.cancel()
                
                // If the search text is empty, don’t schedule a new search and clear results
                guard !searchText.isEmpty else {
                    results = []
                    return
                }
                
                let workItem = DispatchWorkItem {
                    performSearch()
                }
                // Store it so we can cancel if needed
                searchDebounceWorkItem = workItem
                
                // Schedule it to run after 0.5 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + delayToSearch, execute: workItem)
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Picker("Mode", selection: $mode) {
                        Text("Regex/Contains").tag(SearchMode.regexContains)
                        Text("Foundation Models").tag(SearchMode.foundationModels)
                        Text("RAG").tag(SearchMode.rag)
                    }
                    .pickerStyle(.menu)
                }
            }
            .navigationTitle("Search")
        }
    }
    
    private func performSearch() {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else {
            results = []
            hasSearched = false
            return
        }
        hasSearched = true
        
        switch mode {
        case .regexContains:
            results = searchRegexContains(query: query, in: thoughts)
        case .foundationModels:
            isSearching = true
            Task {
                let r = await FoundationModelSearchService.getRelevantThoughts(query: query, in: thoughts)
                await MainActor.run {
                    results = r
                    isSearching = false
                }
            }
        case .rag:
            isSearching = true
            results = searchRAG(query: query, in: thoughts)
            isSearching = false
            
        }
    }
    
    // MARK: - Search Implementations
    private func searchRegexContains(query: String, in thoughts: [Thought]) -> [Thought] {
        do {
            let regex = try NSRegularExpression(pattern: query, options: [.caseInsensitive])
            return thoughts.filter { thought in
                let range = NSRange(location: 0, length: thought.content.utf16.count)
                return regex.firstMatch(in: thought.content, options: [], range: range) != nil
            }
        } catch {
            print("Invalid regex: \(error.localizedDescription)")
            return []
        }
    }
    
    private func searchRAG(query: String, in thoughts: [Thought]) -> [Thought] {
        let ragSystem = RAGSystem()
        let results = ragSystem.sortThoughts(thoughts: thoughts, query: query, limit: 5)
        return results
    }
}
#Preview {
    SearchView(searchText: .constant(""))
}
