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
    
    @Binding var searchText: String
    @State private var result: String = ""
    @State private var isSearching: Bool = false
    @State private var searchDebounceWorkItem: DispatchWorkItem?
    private let delayToSearch = 0.5
    @Namespace private var namespace
    
    @State private var currentScreenWidth: CGFloat = 0
    @State private var currentScreenHeight: CGFloat = 0
    
    // Animation states
    @State private var displayedWords: [AnimatedWord] = []
    @State private var showResponse: Bool = false
    @State private var typedResponse: String = ""
    @State private var isMerging: Bool = false
    @State private var hasSearched = false
    @State private var orbConfig: OrbConfiguration = OrbConfiguration(
        backgroundColors: [.purple, .pink],
        glowColor: .purple,
        coreGlowIntensity: 1.2,
        speed: 60
    )
    @State private var orbSize: CGSize = CGSize(width: 250, height: 250)
    @State private var flashTimers: [Timer] = []
    
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
                        
                        if isMerging && !showResponse && isSearching {
                            ForEach(displayedWords) { word in
                                Text(word.text)
                                    .font(.system(size: word.size))
                                    .fontWeight(.medium)
                                    .matchedGeometryEffect(id: word.id, in: namespace)
                                    .position(word.position)
                            }
                        }
                        OrbView(configuration: orbConfig)
                            .frame(width: orbSize.width, height: orbSize.height, alignment: .center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                
                Spacer()
                
                
            }
            .sheet(isPresented: $showResponse) {
                VStack(spacing: 20) {
                    Text(typedResponse)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .transition(.scale.combined(with: .opacity))
                }
                .presentationDetents([.medium])
            }
            
        }
        .background {
            EllipticalGradient(
                stops: [
                    Gradient.Stop(color: Color(red: 0.94, green: 0.87, blue: 0.94), location: 0.00),
                    Gradient.Stop(color: Color(red: 0.78, green: 0.85, blue: 0.93), location: 1.00),
                ],
                center: UnitPoint(x: 0.67, y: 0.46)
            )
            .ignoresSafeArea()
        }
        .searchable(
            text: $searchText,
            placement: .automatic,
            prompt: "Ask the Orb"
        )
        .onSubmit(of: .search) {
            // Cancel any existing pending search
            searchDebounceWorkItem?.cancel()
            
            // Reset states
            displayedWords = []
            showResponse = false
            typedResponse = ""
            hasSearched = false
            result = ""
            isMerging = false
            flashTimers.forEach { $0.invalidate() }
            flashTimers.removeAll()
            
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
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.06) {
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
                searchText = ""
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    startMergingAnimation(screenWidth: screenWidth, screenHeight: screenHeight)
                }
            }
        }
    }
    
    private func startFlashingAnimation(for index: Int) {
        
        let timer = Timer.scheduledTimer(withTimeInterval: 0.4, repeats: true) { timer in
            guard !isMerging && index < displayedWords.count else {
                timer.invalidate()
                return
            }
            
            withAnimation(.easeInOut(duration: 0.4)) {
                displayedWords[index].scale = displayedWords[index].scale <= 1.0 ? 1.3 : 0.85
                displayedWords[index].opacity = displayedWords[index].opacity == 1.0 ? 0.5 : 1.0
            }
        }
        flashTimers.append(timer)
    }
    
    private func startMergingAnimation(screenWidth: CGFloat, screenHeight: CGFloat) {
        isMerging = true
        
        let centerX = screenWidth / 2
        let centerY = screenHeight / 2
        
        let perWordDelay = 0.06
        let totalDelay = Double(displayedWords.count) * perWordDelay
        
        for index in displayedWords.indices {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * perWordDelay) {
                withAnimation(.spring) {
                    displayedWords[index].position = CGPoint(x: centerX, y: centerY)
                    displayedWords[index].opacity = 0
                    displayedWords[index].scale = 0.5
                }
            }
        }
        
        
        withAnimation(.linear(duration: totalDelay)) {
            orbConfig = OrbConfiguration(
                backgroundColors: [.purple, .blue, .indigo, .red],
                glowColor: .purple,
                coreGlowIntensity: 1.2,
                showParticles: true,
                speed: 120
            )
            orbSize = CGSize(width: 400, height: 400)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + totalDelay + 0.5) {
            showResponse = true
            isSearching = false
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
        withAnimation(.linear(duration: 1)) {
            orbSize = CGSize(width: 250, height: 250)
        }
        withAnimation(.linear(duration: 1)) {
            orbConfig = OrbConfiguration(
                backgroundColors: [.purple, .pink],
                glowColor: .purple,
                coreGlowIntensity: 1.2,
                speed: 60
            )
        }
    }
    
    private func randomPosition(screenWidth: CGFloat, screenHeight: CGFloat) -> CGPoint {
        let minDistanceFromCenter: CGFloat = 150
        let centerX = screenWidth / 2
        let centerY = screenHeight / 2
        var point: CGPoint
        repeat {
            let x = CGFloat.random(in: 20...(screenWidth - 20))
            let y = CGFloat.random(in: 100...(screenHeight - 100))
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

