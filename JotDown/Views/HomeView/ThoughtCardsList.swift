//
//  ThoughtCardsList.swift
//  JotDown
//
//  Created by Drew Mendelow on 10/14/25.
//
import SwiftUI
import SwiftData

struct ThoughtCardsList: View {
    @Environment(\.modelContext) private var context
    var thoughts: [Thought]
    @Binding var text: String
    @Binding var selectedIndex: Int?
    @Binding var showWritableThought: Bool
    @FocusState var isFocused: Bool
    @Binding var isSelecting: Bool
    @Binding var selectedThoughts: Set<Thought>
    let addThought: () async throws -> Void
    @State private var firstCardOffset: CGFloat = 0
    @GestureState private var isDragging = false
    @State private var sendHapticFeedback: Bool = true
    @Binding var selectedTab: Int
    @Binding var categoryToPresent: Category?

    
    // Handles new note offset
    private func handlePreferenceChange(offset: CGFloat, proxy: GeometryProxy, thoughtWidth: CGFloat) {
        if selectedIndex == 1 && thoughts.count > 0 {
            let thoughtPadding = (proxy.size.width - thoughtWidth) / 2
            let expectedCardMinX = thoughtPadding
            
            let rightwardMovement = max(0, offset - expectedCardMinX)
            
            firstCardOffset = rightwardMovement
        } else {
            firstCardOffset = 0
        }
    }
    
    private func resetOffsets() {
        firstCardOffset = 0
    }
    
    var body: some View {
        GeometryReader { proxy in
            let writableWidth: CGFloat = 337
            let thoughtWidth: CGFloat = 251
            
            let writablePadding: CGFloat = (proxy.size.width - writableWidth) / 2
            let thoughtPadding: CGFloat = (proxy.size.width - thoughtWidth) / 2
            let leadingPadding: CGFloat = showWritableThought && selectedIndex == 0 ? writablePadding : thoughtPadding
            let trailingPadding: CGFloat = thoughts.count > 0 ? thoughtPadding : 0
            
            let revealAmount: CGFloat = max(0, min(firstCardOffset / 80, 1.0))
            let shouldShowNewNote: Bool = !showWritableThought && thoughts.count > 0 && selectedIndex == 1 && firstCardOffset > 0
                
            ZStack(alignment: .leading) {
                // new note action that appears when swiping right
                if shouldShowNewNote {
                    NewNoteSwipableAction(revealAmount: revealAmount)
                        .frame(width: proxy.size.width * 0.3, height: 472)
                        .offset(x: 0)
                        .opacity(revealAmount)
                }
                
                ScrollViewReader { scrollProxy in
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(alignment: .center, spacing: 16) {
                            if showWritableThought {
                                WritableThoughtCard(text: $text, isFocused: _isFocused, addThought: addThought)
                                    .id(0)
                            }
                            
                            ForEach(thoughts) { thought in
                                let index = thoughts.firstIndex(of: thought)!
                                let id = index + 1

                                ZStack(alignment: .topTrailing) {
                                    ThoughtCard(thought: thought, selectedTab: $selectedTab, categoryToPresent: $categoryToPresent)
                                        .opacity(isSelecting && !selectedThoughts.contains(thought) ? 0.6 : 1.0)
                                        .overlay(alignment: .topTrailing) {
                                            if isSelecting {
                                                Image(systemName: selectedThoughts.contains(thought) ? "checkmark.circle.fill" : "circle")
                                                    .font(.system(size: 24))
                                                    .foregroundStyle(selectedThoughts.contains(thought) ? .blue : .gray.opacity(0.6))
                                                    .padding(8)
                                            }
                                        }
                                        .background(
                                            GeometryReader { cardGeometry in
                                                Color.clear
                                                    .preference(
                                                        key: FirstCardOffsetPreferenceKey.self,
                                                        value: index == 0 ? cardGeometry.frame(in: .named("scroll")).minX : FirstCardOffsetPreferenceKey.defaultValue
                                                    )
                                            }
                                        )
                                }
                                .id(id)
                                .onTapGesture {
                                    if isSelecting {
                                        toggleSelection(for: thought)
                                    } else {
                                        selectedIndex = id
                                    }
                                }
                            }
                        }
                        .scrollDisabled(isSelecting)
                        .scrollTargetLayout()
                        .padding(.leading, leadingPadding)
                        .padding(.trailing, trailingPadding)
                    }
                    .frame(height: 472)
                    .coordinateSpace(name: "scroll")
                    .scrollTargetBehavior(.viewAligned)
                    .scrollPosition(id: $selectedIndex)
                    .scrollClipDisabled()
                    .animation(.smooth, value: selectedIndex)
                    .onPreferenceChange(FirstCardOffsetPreferenceKey.self) { offset in
                        if offset != FirstCardOffsetPreferenceKey.defaultValue {
                            handlePreferenceChange(offset: offset, proxy: proxy, thoughtWidth: thoughtWidth)
                        }
                        
                        if !showWritableThought && firstCardOffset >= 55.0 {
                            if (sendHapticFeedback) {
                                let generator = UIImpactFeedbackGenerator(style: .light)
                                generator.impactOccurred()
                                sendHapticFeedback = false
                            }
                            
                            if (!isDragging) {
                                // new note swiped
                                sendHapticFeedback = true
                                showWritableThought = true
                                isFocused = true
                            }
                        } else {
                            sendHapticFeedback = true
                        }
                    }
                    .onChange(of: selectedIndex ?? -1) { oldIndex, newIndex in
                        if newIndex != 1 {
                            resetOffsets()
                        }
                        
                        guard showWritableThought && newIndex >= 1 else { return }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                            withAnimation(.smooth) {
                                scrollProxy.scrollTo(1, anchor: .center)
                            }
                        }
                        showWritableThought = false
                        isFocused = false
                        text = ""
                    }
                    .simultaneousGesture(
                        DragGesture(minimumDistance: 0)
                            .updating($isDragging) { _, state, _ in
                                state = true
                            }
                    )
                }
            }
        }
        .frame(height: 472)
    }
    private func toggleSelection(for thought: Thought) {
        if selectedThoughts.contains(thought) {
            selectedThoughts.remove(thought)
        } else {
            selectedThoughts.insert(thought)
        }
    }
}

private struct FirstCardOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        // only take the value if it's not the default (meaning it's from the first card)
        let next = nextValue()
        if next != defaultValue {
            value = next
        }
    }
}
