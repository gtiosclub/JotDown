//
//  ThoughtCardsList.swift
//  JotDown
//
//  Created by Drew Mendelow on 10/14/25.
//
import SwiftUI
import SwiftData

struct ThoughtCardsList: View {
    var thoughts: [Thought]
    @Binding var text: String
    @Environment(\.modelContext) private var context
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false){
            HStack(spacing: 16){
                WritableThoughtCard(text: $text)
                ForEach(thoughts) { thought in
                    ThoughtCard(thought: thought)
                }.onDelete(perform: deleteNote)
            }
        }
    }
    
    private func deleteNote(at offsets: IndexSet) {
        for offset in offsets {
            let itemToDelete = thoughts[offset]
            context.delete(itemToDelete)
        }
    }
}
