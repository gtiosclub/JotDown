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
    
    @State private var searchText: String = ""
    @State private var result: String = ""
    @State private var isSearching: Bool = false
    @State private var searchDebounceWorkItem: DispatchWorkItem?
    private let delayToSearch = 0.5
    @Binding var selectedTab: Int
    @Namespace private var namespace
    
    @State private var currentScreenWidth: CGFloat = 0
    @State private var currentScreenHeight: CGFloat = 0
    
    // Animation states
    @State private var displayedWords: [AnimatedWord] = []
    @State private var showResponse: Bool = false
    @State private var typedResponse: String = ""
    @State private var isMerging: Bool = false
    
    var body: some View {
        ZStack {
            VStack {
                // Main content area for animations
                GeometryReader { geometry in
                    // Update current screen size state
                    Color.clear
                        .onAppear {
                            currentScreenWidth = geometry.size.width
                            currentScreenHeight = geometry.size.height
                        }
                        .onChange(of: geometry.size) { newSize  in
                            currentScreenWidth = newSize.width
                            currentScreenHeight = newSize.height
                        }
                    
                    ZStack {
                        OrbView()
                            .frame(width: 200, height: 200, alignment: .center)
                        if !isMerging && !showResponse {
                            ForEach(displayedWords) { word in
                                Text(word.text)
                                    .font(.system(size: word.size))
                                    .fontWeight(.medium)
                                    .position(word.position)
                                    .opacity(word.opacity)
                                    .scaleEffect(word.scale)
                            }
                        }
                        
                        if isMerging && !showResponse {
                            ForEach(displayedWords) { word in
                                Text(word.text)
                                    .font(.system(size: word.size))
                                    .fontWeight(.medium)
                                    .matchedGeometryEffect(id: word.id, in: namespace)
                                    .position(word.position)
                            }
                        }
                        
                        if showResponse {
                            VStack(spacing: 20) {
                                Text(typedResponse)
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 40)
                                    .transition(.scale.combined(with: .opacity))
                            }
                            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                
                Spacer()
                
                CustomTabBar(selectedTab: $selectedTab)
            }
        }
        .searchable(
            text: $searchText,
            placement: .automatic,
            prompt: "Search thoughts"
        )
        .onSubmit(of: .search) {
            // Cancel any existing pending search
            searchDebounceWorkItem?.cancel()
            
            // Reset states
            displayedWords = []
            showResponse = false
            typedResponse = ""
            isMerging = false
            result = ""
            
            // If the search text is empty, don't schedule a new search
            guard !searchText.isEmpty else { return }
            
            let workItem = DispatchWorkItem { [currentScreenWidth, currentScreenHeight] in
                startSearchAnimation(screenWidth: currentScreenWidth, screenHeight: currentScreenHeight)
            }
            
            searchDebounceWorkItem = workItem
            DispatchQueue.main.asyncAfter(deadline: .now() + delayToSearch, execute: workItem)
        }
    }
    
    private func startSearchAnimation(screenWidth: CGFloat, screenHeight: CGFloat) {
        isSearching = true
        

        let selectedWords = wordFinds(thoughts: thoughts)
        
        displayedWords = selectedWords.enumerated().map { index, word in
            AnimatedWord(
                text: word,
                position: randomPosition(screenWidth: screenWidth, screenHeight: screenHeight),
                size: CGFloat.random(in: 16...28),
                opacity: 0,
                scale: 1.0
            )
        }
        
        for (index, _) in displayedWords.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.1) {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    displayedWords[index].opacity = 1.0
                }
                startFlashingAnimation(for: index)
            }
        }
        
        Task {
            let r = await searchRagFoundationQuery(query: searchText, in: thoughts)
            await MainActor.run {
                result = r
                isSearching = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    startMergingAnimation(screenWidth: screenWidth, screenHeight: screenHeight)
                }
            }
        }
    }
    
    private func startFlashingAnimation(for index: Int) {
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
            guard !isMerging && index < displayedWords.count else {
                timer.invalidate()
                return
            }
            
            withAnimation(.easeInOut(duration: 0.5)) {
                displayedWords[index].scale = displayedWords[index].scale == 1.0 ? 1.3 : 1.0
                displayedWords[index].opacity = displayedWords[index].opacity == 1.0 ? 0.5 : 1.0
            }
        }
    }
    
    private func startMergingAnimation(screenWidth: CGFloat, screenHeight: CGFloat) {
        isMerging = true
        
        let centerX = screenWidth / 2
        let centerY = screenHeight / 2
        
        withAnimation(.linear) {
            for index in displayedWords.indices {
                displayedWords[index].position = CGPoint(x: centerX, y: centerY)
                displayedWords[index].opacity = 0
                displayedWords[index].scale = 0.5
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation {
                showResponse = true
            }
            startTypingAnimation()
        }
    }
    
    private func startTypingAnimation() {
        typedResponse = ""
        let characters = Array(result)
        
        for (index, character) in characters.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.05) {
                typedResponse.append(character)
            }
        }
    }
    
    private func randomPosition(screenWidth: CGFloat, screenHeight: CGFloat) -> CGPoint {
        let minDistanceFromCenter: CGFloat = 150
        let centerX = screenWidth / 2
        let centerY = screenHeight / 2
        var point: CGPoint
        repeat {
            let x = CGFloat.random(in: 50...(screenWidth - 50))
            let y = CGFloat.random(in: 100...(screenHeight - 200))
            point = CGPoint(x: x, y: y)
        } while hypot(point.x - centerX, point.y - centerY) < minDistanceFromCenter
        return point
    }
    
    private func searchRagFoundationQuery(query: String, in thoughts: [Thought]) async -> String {
        let ragSystem = RAGSystem()
        let results = ragSystem.sortThoughts(thoughts: thoughts, query: query, limit: 5)
        let queryResult = await FoundationModelSearchService.queryResponseGenerator(query: query, in: results)
        return queryResult
        
    }
    
    private func wordFinds(thoughts: [Thought]) -> [String]{
        let noUseWords = ["the","a","an","to","for","in","i", "is"]
        var retWords: [String] = []
        let banned = Set(noUseWords)
        for thought in thoughts {
            let words = thought.content
                .lowercased()
                .components(separatedBy: CharacterSet.alphanumerics.inverted)
                .filter{!$0.isEmpty  && !banned.contains($0)}
            retWords.append(contentsOf: words)
        }
        var seen = Set<String>(); var uniq: [String] = []
        for w in retWords where seen.insert(w).inserted { uniq.append(w) }
        return uniq
        
    }
}

struct AnimatedWord: Identifiable {
    let id = UUID()
    let text: String
    var position: CGPoint
    var size: CGFloat
    var opacity: Double
    var scale: CGFloat
}

#Preview {
    CombinedSearchView(selectedTab: .constant(3))
}
