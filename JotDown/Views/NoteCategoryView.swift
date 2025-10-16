//
//  NoteCategoryView.swift
//  JotDown
//
//  Created by Charles Huang on 10/14/25.
//

import SwiftUI
import SwiftData

struct NoteCategoryView: View {
    let category: Category
    @Query var thoughts: [Thought]

    // initializer to set up the filter for the @Query
    init(category: Category) {
        self.category = category
        let categoryName = category.name
        // filter for category name
        let predicate = #Predicate<Thought> { thought in
            thought.category.name == categoryName
        }
        // descriptor sorts thoughts by date - newest first since only display newest 3 thoughts
        let sortDescriptor = SortDescriptor(\Thought.dateCreated, order: .reverse)

        // initialize the @Query with the filter and sort order
        self._thoughts = Query(filter: predicate, sort: [sortDescriptor], transaction: Transaction(animation: .default))
    }

    // get the content of the 3 newest thoughts
    private var noteSnippets: [String] {
        // take first 3 thoughts from the query result
        let recentThoughts = Array(thoughts.prefix(3))
        return recentThoughts.map { $0.content }
    }

    @ViewBuilder
    private func noteCard(text: String) -> some View {
        ZStack {
            //background
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(.systemGray6))
            // border
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.white, lineWidth: 10)
            // text
            Text(text)
                .font(.system(size: 12, weight: .medium))
                .padding(15)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .aspectRatio(1.0, contentMode: .fit)
    }

    var body: some View {
        VStack(alignment: .center, spacing: 12) {
            ZStack {
                // TO DO: Figure out if we want to only show x cards if x < 3 or just have blank cards
                // Back Card (Right) - 3rd newest note
                if thoughts.count > 2 {
                    noteCard(text: thoughts[2].content)
                        .rotationEffect(.degrees(10))
                        .offset(x: 50, y: -50)
                } else {
                    noteCard(text: "")
                        .rotationEffect(.degrees(10))
                        .offset(x: 50, y: -50)
                }

                // Middle Card (Left) - 2nd newest note
                if thoughts.count > 1 {
                    noteCard(text: thoughts[1].content)
                        .rotationEffect(.degrees(-10))
                        .offset(x: -50, y: -75)
                } else {
                    noteCard(text: "")
                        .rotationEffect(.degrees(-10))
                        .offset(x: -50, y: -75)
                }
            
                // Front Card (Center) - Newest note
                if let newestThought = thoughts.first {
                    noteCard(text: newestThought.content)
                } else {
                    noteCard(text: "")
                }
            }
            .scaleEffect(0.8)
            .compositingGroup()
            .shadow(color: .black.opacity(0.1), radius: 5, y: 4)
            .frame(height: 150)

            HStack(spacing: 4) {
                Text(category.name)
                    .font(.headline)
                // Text(category.emoji)
                // TO DO: have foundation models create an emoji for the category
            }

            // Display the total number of thoughts in this category
            Text("\(thoughts.count) notes")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Color.gray.opacity(0.15))
                .clipShape(Capsule())
        }
    }
}
