//
//  NoteCategoryView.swift
//  JotDown
//
//  Created by Charles Huang on 10/14/25.
//

import SwiftUI

struct NoteCategoryView: View {
    var categoryName: String
    var emoji: String
    var numberOfNotes: Int
    var noteSnippets: [String]

    @ViewBuilder
    private func noteCard(text: String) -> some View {
        ZStack {
            // The solid grey background of the card.
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(.systemGray6))

            // The white border, drawn on top of the background.
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.white, lineWidth: 10)

            // The text is overlaid on top of the card.
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
            // MARK: - Stack of Notes
            ZStack {
                // Back Card (Right)
                if noteSnippets.count > 2 {
                    noteCard(text: noteSnippets[2])
                        .rotationEffect(.degrees(10))
                        .offset(x: 50, y: -50)
                } else {
                    noteCard(text: "")
                        .rotationEffect(.degrees(10))
                        .offset(x: 50, y: -50)
                }

                // Middle Card (Left)
                if noteSnippets.count > 1 {
                    noteCard(text: noteSnippets[1])
                        .rotationEffect(.degrees(-10))
                        .offset(x: -50, y: -75)
                } else {
                    noteCard(text: "")
                        .rotationEffect(.degrees(-10))
                        .offset(x: -50, y: -75)
                }
                
                // Front Card (Center)
                if !noteSnippets.isEmpty {
                    noteCard(text: noteSnippets[0])
                } else {
                    noteCard(text: "...")
                }
            }
            .scaleEffect(0.8)
            .compositingGroup()
            .shadow(color: .black.opacity(0.1), radius: 5, y: 4)
            .frame(height: 150)

            // MARK: - Category Info
            HStack(spacing: 4) {
                Text(categoryName)
                    .font(.headline)
                Text(emoji)
            }

            Text("\(numberOfNotes) notes")
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

struct NoteCategoryView_Previews: PreviewProvider {
    static var previews: some View {
        NoteCategoryView(
            categoryName: "Recipes",
            emoji: "🥗",
            numberOfNotes: 10,
            noteSnippets: [
                "i just realized i could make ice cream mochi but with mango sticky rice inside!!!",
                "remember to toast the rice flour first",
                "try coconut milk powder for firmer texture"
            ]
        )
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
