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
    @Binding var categoryToSelect: Category?
    @Binding var activeTab: Int

    var body: some View {
        GeometryReader { proxy in
            let writableWidth: CGFloat = 337
            let thoughtWidth: CGFloat = 251
            let screenWidth = proxy.size.width

            // Dynamic horizontal insets to perfectly center cards
            let writableInset = max(0, (screenWidth - writableWidth) / 2)
            let thoughtInset  = max(0, (screenWidth - thoughtWidth) / 2)
            let leadingInset  = (selectedIndex == 0) ? writableInset : thoughtInset
            let trailingInset = thoughts.isEmpty ? 0 : thoughtInset

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    // Writable Thought Card (new note)
                    WritableThoughtCard(
                        text: $text,
                        isFocused: _isFocused,
                        addThought: addThought
                    )
                    .id(0)

                    // Regular Thoughts
                    ForEach(thoughts.indices, id: \.self) { index in
                        let id = index + 1
                        ThoughtCard(
                            thought: thoughts[index],
                            categoryToSelect: $categoryToSelect,
                            activeTab: $activeTab
                        )
                        .id(id)
                    }
                    .onDelete(perform: deleteNote)
                }
                .padding(.leading, leadingInset)
                .padding(.trailing, trailingInset)
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.viewAligned)
            .scrollPosition(id: $selectedIndex)
            .scrollClipDisabled()
            .animation(.smooth, value: selectedIndex)
            
        }
        .frame(height: 472)
    }

    // MARK: - Delete Note
    private func deleteNote(at offsets: IndexSet) {
        for offset in offsets {
            let itemToDelete = thoughts[offset]
            context.delete(itemToDelete)
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Thought.self, Category.self, configurations: config)

    let category = Category(name: "Preview", categoryDescription: "")
    let sampleThoughts = [Thought(content: "Test thought")]
    sampleThoughts[0].category = category

    return ThoughtCardsList(
        thoughts: sampleThoughts,
        text: .constant(""),
        selectedIndex: .constant(0),
        addThought: { print("Add thought") },
        categoryToSelect: .constant(nil),
        activeTab: .constant(0)
    )
    .modelContainer(container)
}
