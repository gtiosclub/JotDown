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

    @State private var searchText: String = ""
    @State private var mode: SearchMode = .regexContains
    @State private var results: [Thought] = []
    @State private var isSearching: Bool = false
    @State private var hasSearched: Bool = false

    var body: some View {
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
            if !searchText.isEmpty {
                performSearch()
            }
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
                let r = await searchFoundationModels(query: query, in: thoughts)
                await MainActor.run {
                    results = r
                    isSearching = false
                }
            }
        case .rag:
            isSearching = true
            Task {
                let r = await searchRAG(query: query, in: thoughts)
                await MainActor.run {
                    results = r
                    isSearching = false
                }
            }
        }
    }

    // MARK: - Search Implementations

    private func searchRegexContains(query: String, in thoughts: [Thought]) -> [Thought] {
        thoughts.first.map { [$0] } ?? []
    }

    private func searchFoundationModels(query: String, in thoughts: [Thought]) async -> [Thought] {
        thoughts.first.map { [$0] } ?? []
        let session = FoundationModels.LanguageModelSession()
        
        //1. First try to identify the category of the query
        var uniqueCategories: [String] = []
        
        for thought in thoughts {
            let name = thought.category.name
            if (!uniqueCategories.contains(name)) {
                uniqueCategories.append(name)
            }
        }
        
        //Makes sure array is not empty
        if uniqueCategories.isEmpty {
            return []
        }
        
        do {
            //2. Determine the cateogry of the query
            let categoryPrompt = """
            Given the search query: "\(query)"
            And these available categories: [\(uniqueCategories.joined(separator: ", "))]
            
            Which category is most likely to contain thoughts related to this search query?
            Return only the exact category name from the list above and nothing else.
            """
            
            let categoryResponse = try await session.respond(to: categoryPrompt)
            let selectedCategory = categoryResponse.content.trimmingCharacters(in: .whitespacesAndNewlines)
            
            let categoryFilteredThoughts = thoughts.filter { $0.category.name.lowercased() == selectedCategory.lowercased() }
            
            //3. Search through filtered thoughts and determine relevance
            var relevantThoughts: [Thought] = [] //Relevant thoughts that will be returned
            
            for thought in categoryFilteredThoughts {
                let relevancePrompt = """
                    Search query: \(query)
                    Thought content: \(thought.content)
                    
                    Is this thought relevant to the search query? Consider meaning, not just exact words.
                    Answer only "yes" or "no".
                    """
                
                let relevanceResponse = try await session.respond(to: relevancePrompt)
                
                // If relevant then append to search results
                if relevanceResponse.content.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == "yes" {
                    relevantThoughts.append(thought)
                }
            }
            
            return relevantThoughts
            
        } catch {
            print("Error in Foundation Models search: \(error)")
            return []
        }
    }
    

    private func searchRAG(query: String, in thoughts: [Thought]) async -> [Thought] {
        thoughts.first.map { [$0] } ?? []
    }
}

#Preview {
    SearchView()
}
