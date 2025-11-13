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
    
    // MARK: - Zoom and Pan States
    @State private var scale: CGFloat = 1.0
    @State private var finalScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    @State private var pinchAnchor: CGPoint? = nil

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
        GeometryReader { geo in
            ScrollView([.horizontal, .vertical], showsIndicators: false) {
                ZStack {
                    GridBackground()
                    
                    // Thought bubbles layout
                    RadialLayout {
                        ForEach(visibleThoughts.indices, id: \.self) { index in
                            ThoughtBubbleView(
                                thought: visibleThoughts[index],
                                color: colorForCategory(visibleThoughts[index].category.name),
                                zoomLevel: scale
                            )
                            .layoutValue(key: CategoryLayoutKey.self, value: visibleThoughts[index].category.name)
                        }
                    }
                    .frame(width: 400, height: 400)
                    
                    // Category labels layout
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
                                .frame(maxWidth: 220)
                                .fixedSize(horizontal: false, vertical: true)
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
                                    .frame(maxWidth: 220)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                    .frame(width: 400, height: 400)
                    .opacity(categoryOpacity(for: scale))
                    .animation(.easeInOut(duration: 0.2), value: scale)
                    .zIndex(0)
                    
                    // JotDown logo
                    JotDownLogo(style: .heavy, color: .gray)
                        .frame(width: 200.0, height: 200.0)
                        .font(.system(size: 100, weight: .heavy))
                        .glassEffect(.clear, in: .circle)
                }
                // MARK: - Zoom and Pan Applied Here
                .scaleEffect(scale)
                .offset(offset)
                .contentShape(.rect)
                .gesture(magnificationGesture(in: geo))
                .animation(.easeInOut(duration: 0.15), value: scale)
                .animation(.easeInOut(duration: 0.15), value: offset)
                .frame(width: 1000, height: 1400)
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
        .animation(.default, value: visualizationMode)
    }
    
    // MARK: - Gesture Logic
    func magnificationGesture(in geo: GeometryProxy) -> some Gesture {
        MagnificationGesture()
            .onChanged { value in
                if pinchAnchor == nil {
                    let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
                    pinchAnchor = center
                }
                
                let newScale = (finalScale * value).clamped(to: minZoom...maxZoom)
                let scaleDelta = newScale / scale
                
                if let anchor = pinchAnchor {
                    let anchorVector = CGSize(
                        width: anchor.x - geo.size.width / 2,
                        height: anchor.y - geo.size.height / 2
                    )
                    
                    offset = CGSize(
                        width: lastOffset.width - anchorVector.width * (scaleDelta - 1),
                        height: lastOffset.height - anchorVector.height * (scaleDelta - 1)
                    )
                }
                
                scale = newScale
            }
            .onEnded { _ in
                finalScale = scale
                lastOffset = offset
                pinchAnchor = nil
            }
    }
}

#Preview {
    VisualizationView()
        .modelContainer(for: [Thought.self, Category.self], inMemory: false)
}

// MARK: - Helper
extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
}
