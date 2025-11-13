//
//  VisualizationView.swift
//  JotDown
//
//  Created by Siddharth Palanivel on 10/23/25.
//

import SwiftUI
import SwiftData

enum VisualizationMode: String, CaseIterable {
    case category = "Categories"
    case emotion = "Emotions"
}

struct VisualizationView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var context
    @Query(sort: \Thought.dateCreated, order: .reverse) var thoughts: [Thought]
    @Query var categories: [Category]
    
    // MARK: - Zoom State
    @State private var scale: CGFloat = 1.0
    @State private var visualizationMode = VisualizationMode.category

    // MARK: - Zoom Limits
    let minZoom: CGFloat = 0.67
    let maxZoom: CGFloat = 1.5
    
    // MARK: - Derived Collections
    private var visibleThoughts: [Thought] {
        thoughts.filter { $0.category.isActive }
    }
    private var activeCategories: [Category] {
        categories.filter { $0.isActive }
    }
    private var inactiveCategories: [Category] {
        categories.filter { !$0.isActive }
    }
    
    private var usedCategories: [String] {
        var uniqueNames = [String]()
        var seenNames = Set<String>()
        for thought in thoughts {
            let cat = thought.category
            if !seenNames.contains(cat.name) && !inactiveCategories.contains(cat) {
                uniqueNames.append(cat.name)
                seenNames.insert(cat.name)
            }
        }
        return uniqueNames
    }
    
    private func categoryOpacity(for currentZoom: CGFloat) -> Double {
        let fadePoint: CGFloat = 1.0
        let progress = (currentZoom - minZoom) / (fadePoint - minZoom)
        return max(0.0, min(1.0, 1.0 - progress))
    }
    
    // MARK: - Body
    var body: some View {
        ZoomableScrollView(minZoom: minZoom, maxZoom: maxZoom, currentZoom: $scale) {
            ZStack {
                // Thought bubbles and category labels layout
                RadialLayout(scale: scale) {
                    // Thought bubbles
                    ForEach(visibleThoughts.indices, id: \.self) { index in
                        ThoughtBubbleView(
                            thought: visibleThoughts[index],
                            color: colorForCategory(visibleThoughts[index].category.name),
                            zoomLevel: scale
                        )
                        .layoutThought(visibleThoughts[index])
                    }

                    // Category labels
                    ForEach(usedCategories, id: \.self) { category in
                        Text(category)
                            .layoutCategory(category)
                            .bubbleStyle(
                                color: colorForCategory(category),
                                size: 24
                            )
                    }
                    .opacity(categoryOpacity(for: scale))
                }

                // JotDown logo
                JotDownLogo(style: .heavy, color: .gray)
                    .frame(width: 200.0, height: 200.0)
                    .font(.system(size: 100, weight: .heavy))
                    .glassEffect(.clear, in: .circle)
            }
        }
        .primaryBackground()
        .toolbar {
            Button(role: .close) {
                dismiss()
            }
        }
        .animation(.default, value: visualizationMode)
    }
}

#Preview {
    VisualizationView()
        .modelContainer(for: [Thought.self, Category.self], inMemory: false)
}
