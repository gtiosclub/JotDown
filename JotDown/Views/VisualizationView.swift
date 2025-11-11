//
//  VisualizationView.swift
//  JotDown
//
//  Created by Siddharth Palanivel on 10/23/25.
//

import SwiftUI
import SwiftData

struct VisualizationView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var context
    @Query(sort: \Thought.dateCreated, order: .reverse) var thoughts: [Thought]
    @Query var categories: [Category]
    
    @State private var zoomLevel: CGFloat = 0.6
    @State private var finalZoomLevel: CGFloat = 1.0
    
    let minZoom: CGFloat = 0.67
    let maxZoom: CGFloat = 1.5
    
    private var visibleThoughts: [Thought] {
        thoughts
            .filter{$0.category.isActive}
    }
    
    private var activeCategories: [Category] {
        categories
            .filter{$0.isActive}
    }
    private var inactiveCategories: [Category] {
        categories.filter{!$0.isActive}
    }
    
    private var usedCategories: [String] {
            var uniqueNames = [String]()
            var seenNames = Set<String>()
            
            // Loop through the thoughts in their query order
            for thought in thoughts {
                let cat = thought.category
                // If we haven't seen this name yet, add it
                if !seenNames.contains(cat.name) && !inactiveCategories.contains(cat) {
                    uniqueNames.append(cat.name)
                    seenNames.insert(cat.name)
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
                        ThoughtBubbleView(
                            thought: visibleThoughts[index],
                            color: colorForCategory(visibleThoughts[index].category.name),
                            zoomLevel: zoomLevel
                        )
                        .layoutValue(key: CategoryLayoutKey.self, value: visibleThoughts[index].category.name)
                    }
                } .frame(width: 400, height: 400)
                RadialLayout {
                    if usedCategories.count == 1 {
                        Text(usedCategories.first!)
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
                        ForEach(usedCategories, id: \.self) { category in
                            Text(category)
                                .layoutValue(key: CategoryLayoutKey.self, value: category)
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
            Button(role: .close) {
                dismiss()
            }
        }
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

