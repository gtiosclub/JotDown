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
    @State private var scale: CGFloat = 0.8
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

    private var usedEmotions: [String] {
        var uniqueEmotions = [String]()
        var seenEmotions = Set<String>()
        for thought in visibleThoughts {
            if let emotion = thought.emotion {
                let emotionName = emotion.rawValue.capitalized
                if !seenEmotions.contains(emotionName) {
                    uniqueEmotions.append(emotionName)
                    seenEmotions.insert(emotionName)
                }
            }
        }
        return uniqueEmotions.sorted()
    }

    private var displayedLabels: [String] {
        visualizationMode == .category ? usedCategories : usedEmotions
    }
    
    // MARK: - Body
    var body: some View {
        ZoomableScrollView(minZoom: minZoom, maxZoom: maxZoom, currentZoom: $scale) {
            ZStack {
                // Thought bubbles and category labels layout
                RadialLayout(scale: scale, groupBy: visualizationMode) {
                    // Thought bubbles
                    ForEach(visibleThoughts.indices, id: \.self) { index in
                        ThoughtBubbleView(
                            thought: visibleThoughts[index],
                            color: visualizationMode == .category
                                ? colorForCategory(visibleThoughts[index].category.name)
                                : colorForEmotion(visibleThoughts[index].emotion ?? .unknown),
                            zoomLevel: scale
                        )
                        .layoutThought(visibleThoughts[index])
                    }

                    // Category/Emotion labels
                    ForEach(displayedLabels, id: \.self) { label in
                        Text(label)
                            .layoutCategory(label)
                            .bubbleStyle(
                                color: visualizationMode == .category
                                    ? colorForCategory(label)
                                    : colorForEmotion(Emotion(rawValue: label.lowercased()) ?? .unknown),
                                size: 24
                            )
                            .opacity(categoryOpacity(for: scale))
                    }
                }

                // JotDown logo
                JotDownLogo(style: .heavy, color: .gray)
                    .frame(width: 200.0, height: 200.0)
                    .font(.system(size: 100, weight: .heavy))
                    .glassEffect(.clear, in: .circle)
            }
            .animation(.spring(duration: 0.6, bounce: 0.3), value: visualizationMode)
        }
        .primaryBackground()
        .toolbar {
            ToolbarItem(placement: .principal) {
                Picker("Visualization Mode", selection: $visualizationMode) {
                    ForEach(VisualizationMode.allCases, id: \.self) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
            }

            ToolbarItem(placement: .topBarTrailing) {
                Button(role: .close) {
                    dismiss()
                }
            }
        }
        .animation(.default, value: visualizationMode)
    }

    private func categoryOpacity(for currentZoom: CGFloat) -> Double {
        let fadePoint: CGFloat = 1.0
        let progress = (currentZoom - minZoom) / (fadePoint - minZoom)
        return max(0.0, min(1.0, 1.0 - progress))
    }
}

#Preview {
    VisualizationView()
        .modelContainer(for: [Thought.self, Category.self], inMemory: false)
}
