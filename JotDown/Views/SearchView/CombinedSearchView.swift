//
//  CombinedSearchView.swift
//  JotDown
//
//  Created by Stepan Kravtsov on 10/14/25.
//

import SwiftUI
import SwiftData
import Orb

struct CombinedSearchView: View {
    @Environment(\.modelContext) private var modelContext
    
    @Query(sort: \Thought.dateCreated, order: .reverse) private var thoughts: [Thought]
    @StateObject private var cloud = WordCloudController()
    @State private var searchText: String = ""
    @State var result: String = ""
    //    @State private var isSearching: Bool = false
    @State private var hasSearched: Bool = false
    // Only searches after .5 seconds of stopped typing
    @State private var searchDebounceWorkItem: DispatchWorkItem?
    private let delayToSearch = 0.5
    @Namespace private var namespace
    var body: some View {
        ZStack {
            backgroundGradient
            VStack(alignment: .leading, spacing: 24) {
                HStack {
                    Text("search")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(textColor)
                }
                .padding(.horizontal)
                .frame(alignment: .leading)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .padding(.horizontal)
            .padding(.top, 40)
            .transition(.opacity)
            WordCloudAnswerView(controller: cloud)
                
        }
        
        
        .searchable(
            text: $searchText,
            placement: .automatic,
            prompt: "Search thoughts"
        )
        .onSubmit(of: .search) {
            // Cancel any existing pending search
            searchDebounceWorkItem?.cancel()
            
            // If the search text is empty, don’t schedule a new search
            guard !searchText.isEmpty else { return }
            
            let words = WordFinds(thoughts: thoughts) // stop-word filtered, unique
            let q = searchText.lowercased()
            
            // Simple prioritization: words that contain the query first
            let prioritized = words.sorted { a, b in
                let ac = a.contains(q)
                let bc = b.contains(q)
                return ac && !bc ? true : (!ac && bc ? false : a.count > b.count)
            }
            let picked = Array(prioritized)
            cloud.reset()
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .startCloud, object: picked)
            }
            
            let workItem = DispatchWorkItem {
                Task {
                    let r = await searchRagFoundationQuery(query: searchText, in: thoughts)
                        
                    await MainActor.run {
                        result = r
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            
                            NotificationCenter.default.post(name: .finishCloud, object: r)
                        }
                    }
                }
                
            }
            // Store it so we can cancel if needed
            searchDebounceWorkItem = workItem
            
            // Schedule it to run after 0.5 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + delayToSearch, execute: workItem)
        }
        .navigationBarHidden(true)
        
        
    }
    
    private func WordFinds(thoughts: [Thought]) -> [String]{
        let noUseWords = ["the","a","an","to","for","in","on","at","of","by"]
        var retWords:[String] = []
        let banned: Set<String> = Set(noUseWords.map {
            $0.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)
        })
        for thought in thoughts{
            let words = thought.content
                .lowercased()
                .components(separatedBy: CharacterSet.alphanumerics.inverted)
                .filter{!$0.isEmpty  && !banned.contains($0)}
            retWords.append(contentsOf: words)
        }
        var seen = Set<String>(); var uniq: [String] = []
        
        for w in retWords where seen.insert(w).inserted {
            uniq.append(w)
        }
        return uniq
    }
    
    private func searchRagFoundationQuery(query: String, in thoughts: [Thought]) async -> String {
        let ragSystem = RAGSystem()
        let results = ragSystem.sortThoughts(thoughts: thoughts, query: query, limit: 5)
        let queryResult = await FoundationModelSearchService.queryResponseGenerator(query: query, in: results)
        return queryResult
        
    }
    
    private var backgroundGradient: some View {
        EllipticalGradient(
            stops: [
                Gradient.Stop(color: Color(red: 0.94, green: 0.87, blue: 0.94), location: 0.00),
                Gradient.Stop(color: Color(red: 0.78, green: 0.85, blue: 0.93), location: 1.00),
            ],
            center: UnitPoint(x: 0.67, y: 0.46)
        )
        .ignoresSafeArea()
    }
    
    private var textColor: Color {
        Color(red: 0.35, green: 0.35, blue: 0.45)
    }
}


extension Notification.Name {
    static let startCloud = Notification.Name("startCloud")
    static let finishCloud = Notification.Name("finishCloud")
}

#Preview {
    CombinedSearchView()
}
