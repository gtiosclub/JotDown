//
//  ThoughtsListView.swift
//  JotDown
//
//  Created by Sankaet Cheemalamarri on 9/22/25.
//

import SwiftData
import SwiftUI

struct ThoughtsListView: View {
    @Query(sort: \Thought.dateCreated, order: .reverse) var thoughts: [Thought]
    @Environment(\.modelContext) private var context

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/dd/yyyy"
        return formatter
    }()
    
    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter
    }()
    
    var body: some View {
        List {
            ForEach(thoughts) { thought in
                HStack {
                    Text(thought.content)
                    Spacer()
                    VStack {
                        Text(ThoughtsListView.dateFormatter.string(from: thought.dateCreated)).font(.caption)
                        Text(ThoughtsListView.timeFormatter.string(from: thought.dateCreated)).font(.caption)
                        Text(thought.category.name)
                    }
                }
            }.onDelete(perform: deleteNote)
        }
        .navigationTitle("Thoughts")
    }
    
    private func deleteNote(at offsets: IndexSet) {
        for offset in offsets {
            let itemToDelete = thoughts[offset]
            context.delete(itemToDelete)
        }
    }
}

#Preview {
    ThoughtsListView()
}
