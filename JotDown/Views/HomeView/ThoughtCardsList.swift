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
                        
                        ForEach(thoughts.indices, id: \.self) { index in
                            let id = index + 1
                            ThoughtCard(thought: thoughts[index])
                                .id(id)
                        }
                        .onDelete(perform: deleteNote)
                    }
                    .scrollTargetLayout()
                    .padding(.leading, leadingPadding)
                    .padding(.trailing, trailingPadding)
                    .animation(.smooth, value: selectedIndex == 0)
                }
                .scrollTargetBehavior(.viewAligned)
                .scrollPosition(id: $selectedIndex)
                .scrollClipDisabled()
                .animation(.smooth, value: selectedIndex)
                .onChange(of: selectedIndex) { _, newIndex in
                    guard thoughts.count == 1 && newIndex == 1 else { return }

                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
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
    
    private func deleteNote(at offsets: IndexSet) {
        for offset in offsets {
            let itemToDelete = thoughts[offset]
            context.delete(itemToDelete)
        }
    }
}
