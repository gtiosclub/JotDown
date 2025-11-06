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
    let namespace: Namespace.ID
    @Query var thoughts: [Thought]

    // initializer to set up the filter for the @Query
    init(category: Category, namespace: Namespace.ID) {
        self.category = category
        self.namespace = namespace
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

    // Define the dark text color from the visual
    private var textColor: Color {
         Color(red: 0.35, green: 0.35, blue: 0.45)
    }

    @ViewBuilder
    private func noteCard(text: String, isFront: Bool = false) -> some View {
        ZStack(alignment: .topLeading) {
            // text
            Text(text)
                .font(.system(size: 12, weight: .medium))
                .padding(15)
                .foregroundStyle(textColor)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        // background
        .background(
            isFront ?
            .ultraThinMaterial // Frosted-glass effect for the front card
            :
            Material.regular // Opaque white-ish material for back cards
        )
        .cornerRadius(15)
        .aspectRatio(1.0, contentMode: .fit)
        .clipped()
    }

    var body: some View {
        VStack(alignment: .center, spacing: 16) {
            ZStack(alignment: .center) {
                // Back Card (Right) - 3rd newest note
                if thoughts.count > 2 {
                    noteCard(text: thoughts[2].content)
                        .matchedGeometryEffect(id: thoughts[2].id, in: namespace)
                        .rotationEffect(.degrees(6))
                        .offset(x: 30, y: -45)
                        .opacity(0.6)
                } else {
                    noteCard(text: "")
                        .rotationEffect(.degrees(6))
                        .offset(x: 30, y: -45)
                        .opacity(0.6)
                }

                // Middle Card (Left) - 2nd newest note
                if thoughts.count > 1 {
                    noteCard(text: thoughts[1].content)
                        .matchedGeometryEffect(id: thoughts[1].id, in: namespace)
                        .rotationEffect(.degrees(-6))
                        .offset(x: -30, y: -60)
                        .opacity(0.8)
                } else {
                    noteCard(text: "")
                        .rotationEffect(.degrees(-6))
                        .offset(x: -30, y: -60)
                        .opacity(0.8)
                }

                // Front Card (Center) - Newest note
                if let newestThought = thoughts.first {
                    noteCard(text: newestThought.content, isFront: true)
                        .matchedGeometryEffect(id: newestThought.id, in: namespace)
                        .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
                } else {
                    noteCard(text: "", isFront: true)
                }
            }
            .compositingGroup()
            .frame(height: 125, alignment: .bottom)

            // MARK: - Title & Count
            
            // Category Name
            Text(category.name)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(textColor)
                .matchedGeometryEffect(id: "\(category.id)-title", in: namespace)

            // Display the total number of thoughts in this category in a "pill"
            Text("\(thoughts.count) notes")
                .font(.system(size: 12, weight: .regular))
                .foregroundStyle(textColor.opacity(0.8))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.black.opacity(0.04)) // Translucent pill
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(Color.black.opacity(0.08), lineWidth: 1)
                )
                .matchedGeometryEffect(id: "\(category.id)-count", in: namespace)
        }
    }
}
