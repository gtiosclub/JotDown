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
    @FocusState var isFocused: Bool
    @Binding var isSelecting: Bool
    @Binding var selectedThoughts: Set<Thought>
    let addThought: () async throws -> Void

    
    var body: some View {
        GeometryReader { proxy in
            let writableWidth: CGFloat = 337
            let thoughtWidth: CGFloat = 251
            
            let writablePadding = (proxy.size.width - writableWidth) / 2
            let thoughtPadding = (proxy.size.width - thoughtWidth) / 2
            let leadingPadding = selectedIndex == 0 ? writablePadding : thoughtPadding
            let trailingPadding = thoughts.count > 0 ? thoughtPadding : 0
            
            ScrollViewReader { scrollProxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .center, spacing: 16) {
                        WritableThoughtCard(text: $text, isFocused: _isFocused, addThought: addThought)
                            .id(0)
                        
                        ForEach(thoughts) { thought in
                            let id = thoughts.firstIndex(of: thought)! + 1

                            ZStack(alignment: .topTrailing) {
                                ThoughtCard(thought: thought)
                                    .opacity(isSelecting && !selectedThoughts.contains(thought) ? 0.6 : 1.0)
                                    .overlay(alignment: .topTrailing) {
                                        if isSelecting {
                                            Image(systemName: selectedThoughts.contains(thought) ? "checkmark.circle.fill" : "circle")
                                                .font(.system(size: 24))
                                                .foregroundStyle(selectedThoughts.contains(thought) ? .blue : .gray.opacity(0.6))
                                                .padding(8)
                                        }
                                    }
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
                .scrollTargetBehavior(.viewAligned)
                .scrollPosition(id: $selectedIndex)
                .scrollClipDisabled()
                .animation(.smooth, value: selectedIndex)
                .onChange(of: selectedIndex) { _, newIndex in
                    // Only correct the snapping if there is one thought and we're on that card
                        guard thoughts.count == 1 && newIndex == 1 else { return }

                        // Delay the correction slightly so SwiftUI finishes snapping first
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                            // Double-check that the user didn’t scroll back
                            if selectedIndex == 1 {
                                withAnimation(.smooth) {
                                    scrollProxy.scrollTo(1, anchor: .center)
                                }
                            }
                        }
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
