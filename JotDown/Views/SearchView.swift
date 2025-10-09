import SwiftUI
import SwiftData
import NaturalLanguage

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
        do{
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

    private func searchFoundationModels(query: String, in thoughts: [Thought]) async -> [Thought] {
        thoughts.first.map { [$0] } ?? []
    }

    private func searchRAG(query: String, in thoughts: [Thought]) async -> [Thought] {
        guard let model = NLEmbedding.wordEmbedding(for: .english) else {
            print("Unable to load embeddings model")
            return thoughts
        }
        let words = query.lowercased().components(separatedBy: .whitespacesAndNewlines)
        let embeddings = words.compactMap { model.vector(for: $0) }
        let queryEmbedding = average(embeddings)
        let results = thoughts.sorted {
            cosineSimilarity($0.vectorEmbedding, queryEmbedding) > cosineSimilarity($1.vectorEmbedding, queryEmbedding)
        }.prefix(4)
        return Array(results)
    }
}

#Preview {
    SearchView()
}
