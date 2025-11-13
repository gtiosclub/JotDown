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

    @State private var zoomLevel: CGFloat = 0.6
    @State private var finalZoomLevel: CGFloat = 1.0
    @State private var visualizationMode: VisualizationMode = .category

    let minZoom: CGFloat = 0.67
    let maxZoom: CGFloat = 1.5
    
    private var visibleThoughts: [Thought] {
        switch visualizationMode {
        case .category:
            return thoughts.filter { $0.category.isActive }
        case .emotion:
            return thoughts.filter { $0.emotion != .unknown }
        }
    }

    private var activeCategories: [Category] {
        categories
            .filter{$0.isActive}
    }
    private var inactiveCategories: [Category] {
        categories.filter{!$0.isActive}
    }

    private var usedGroups: [String] {
        var uniqueNames = [String]()
        var seenNames = Set<String>()

        switch visualizationMode {
        case .category:
            // Loop through the thoughts in their query order
            for thought in thoughts {
                let cat = thought.category
                // If we haven't seen this name yet, add it
                if !seenNames.contains(cat.name) && !inactiveCategories.contains(cat) {
                    uniqueNames.append(cat.name)
                    seenNames.insert(cat.name)
                }
            }
        case .emotion:
            // Get unique emotions from visible thoughts
            for thought in visibleThoughts {
                let emotionName = thought.emotion?.rawValue.capitalized ?? ""
                if !seenNames.contains(emotionName) {
                    uniqueNames.append(emotionName)
                    seenNames.insert(emotionName)
                }
            }
        }
        return uniqueNames
    }
    
    private func categoryOpacity(for currentZoom: CGFloat) -> Double {
            let fadePoint: CGFloat = 1.0
            // Calculate how far we are between minZoom and the fadePoint
            let progress = (currentZoom - minZoom) / (fadePoint - minZoom)
            // Invert the progress (1.0 -> 0.0) and clamp it between 0 and 1
            return max(0.0, min(1.0, 1.0 - progress))
    }
    
    var body: some View {
        ScrollView([.horizontal, .vertical]) {
            ZStack {
                GridBackground()
                RadialLayout {
                    ForEach(visibleThoughts.indices, id: \.self) { index in
                        let thought = visibleThoughts[index]
                        let groupValue = visualizationMode == .category
                            ? thought.category.name
                            : thought.emotion?.rawValue.capitalized ?? ""
                        ThoughtBubbleView(
                            thought: thought,
                            color: visualizationMode == .category
                                ? colorForCategory(thought.category.name)
                            : colorForEmotion(thought.emotion ?? .unknown),
                            zoomLevel: zoomLevel
                        )
                        .layoutValue(key: CategoryLayoutKey.self, value: groupValue)
                    }
                } .frame(width: 400, height: 400)
                RadialLayout {
                    if usedGroups.count == 1 {
                        Text(usedGroups.first!)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .position(x: -33, y: 25)
                            .foregroundColor(.primaryText)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                            .minimumScaleFactor(0.5)
                            .frame(maxWidth: 220) // limits width
                            .fixedSize(horizontal: false, vertical: true) // which axis has a fixed size
                    } else {
                        ForEach(usedGroups, id: \.self) { groupName in
                            Text(groupName)
                                .layoutValue(key: CategoryLayoutKey.self, value: groupName)
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.primaryText)
                                .multilineTextAlignment(.center)
                                .lineLimit(2)
                                .minimumScaleFactor(0.5)
                                .frame(maxWidth: 220) // limits width
                                .fixedSize(horizontal: false, vertical: true) // which axis has a fixed size
                        }
                    }
                }
                .frame(width: 400, height: 400)
                .opacity(categoryOpacity(for: zoomLevel))
                .animation(.easeInOut(duration: 0.2), value: zoomLevel)
                .zIndex(0)
                JotDownLogo(style: .heavy, color: .gray)
                    .frame(width: 200.0, height: 200.0)
                    .font(.system(size: 100, weight: .heavy)) // This scales the symbol
                    .glassEffect(.clear, in: .circle)
            }
            .scaleEffect(zoomLevel)
            .gesture(magnificationGesture)
            .frame(width: 1000 * zoomLevel, height: 1400 * zoomLevel)
        }
        .primaryBackground()
        .scrollIndicators(.hidden)
        .defaultScrollAnchor(.center)
        .scrollBounceBehavior(.basedOnSize)
        .scrollContentBackground(.hidden)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Picker("Visualization Mode", selection: $visualizationMode) {
                    ForEach(VisualizationMode.allCases, id: \.self) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
            }

            ToolbarItem {
                Button(role: .close) {
                    dismiss()
                }
            }
        }
        .animation(.default, value: visualizationMode)
    }
    
    var magnificationGesture: some Gesture {
        MagnificationGesture()
            .onChanged { value in
                self.zoomLevel = self.finalZoomLevel * value
            }
            .onEnded { value in
                self.finalZoomLevel = self.zoomLevel
                
                if self.finalZoomLevel < minZoom {
                    self.finalZoomLevel = minZoom
                } else if self.finalZoomLevel > maxZoom {
                    self.finalZoomLevel = maxZoom
                }
                
                let transitionStart: CGFloat = 0.6
                let transitionEnd: CGFloat = 1.0
                let transitionMidpoint: CGFloat = (transitionStart + transitionEnd) / 2.0 // 0.875 Normally
                
                // 2. Check if we ended inside the transition zone
                if self.finalZoomLevel > transitionStart && self.finalZoomLevel < transitionEnd {
                    // 3. If so, snap to the nearest "clean" state
                    if self.finalZoomLevel < transitionMidpoint {
                        self.finalZoomLevel = transitionStart // Snap down
                    } else {
                        self.finalZoomLevel = transitionEnd // Snap up
                    }
                }
                
                withAnimation {
                    self.zoomLevel = self.finalZoomLevel
                }
            }
    }
}

#Preview {
    VisualizationView()
        .modelContainer(for: [Thought.self, Category.self], inMemory: false)
}

