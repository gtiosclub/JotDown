//
//  VisualizationView.swift
//  JotDown
//
//  Created by Siddharth Palanivel on 10/23/25.
//

import SwiftUI
import SwiftData

struct VisualizationView: View {
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
                                .foregroundColor(Color(red: 0.35, green: 0.35, blue: 0.45))
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
                Text("visualization")
                    .foregroundColor(Color(red: 0.35, green: 0.35, blue: 0.45))
                    .font(.system(size: 40, weight: .heavy))
                    .offset(x: 15, y: 20)
            }
            .scaleEffect(zoomLevel)
            .gesture(magnificationGesture)
            .frame(width: 800, height: 800)
        }
        .background {
            EllipticalGradient(
                stops: [
                    Gradient.Stop(color: Color(red: 0.94, green: 0.87, blue: 0.94), location: 0.00),
                    Gradient.Stop(color: Color(red: 0.78, green: 0.85, blue: 0.93), location: 1.00),
                ],
                center: UnitPoint(x: 0.67, y: 0.46)
            )
            .ignoresSafeArea()
        }
        .scrollIndicators(.hidden)
        .defaultScrollAnchor(.center)
        .scrollBounceBehavior(.basedOnSize)
        .scrollContentBackground(.hidden)
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


// MARK: - GridBackground

struct GridBackground: View {
    let size: CGFloat = 4000
    let spacing: CGFloat = 50
    let lineColor = Color(.lightGray).opacity(0)
    let lineWidth: CGFloat = 1
    
    var body: some View {
        Canvas { context, size in
            for x in stride(from: 0, to: size.width, by: spacing) {
                var path = Path()
                path.move(to: CGPoint(x: x, y: 0))
                path.addLine(to: CGPoint(x: x, y: size.height))
                context.stroke(path, with: .color(lineColor), lineWidth: lineWidth)
            }
            
            for y in stride(from: 0, to: size.height, by: spacing) {
                var path = Path()
                path.move(to: CGPoint(x: 0, y: y))
                path.addLine(to: CGPoint(x: size.width, y: y))
                context.stroke(path, with: .color(lineColor), lineWidth: lineWidth)
            }
        }
        .frame(width: size, height: size)
    }
}

struct ThoughtBubbleView: View {
    let thought: Thought
    let color: Color
    let zoomLevel: CGFloat
    
    // Define a constant size for the bubble
    private let bubbleSize: CGFloat = 70
    
    private var textOpacity: Double {
            let fadeStart: CGFloat = 0.75
            let fadeEnd: CGFloat = 1.0 // The zoom level where text is fully visible
            
            // Calculate progress between the start and end
            let progress = (zoomLevel - fadeStart) / (fadeEnd - fadeStart)
            // Clamp the result between 0.0 and 1.0
            return max(0.0, min(1.0, progress))
    }
    
    var body: some View {
        Text(thought.content)
            .font(.caption) // Use caption font to fit more text
            .multilineTextAlignment(.center)
            .foregroundStyle(.primary) // Use primary text color for readability
            .opacity(textOpacity)
            .animation(.easeInOut(duration: 0.2), value: textOpacity)
            .padding(8) // Add some internal padding
            .frame(width: bubbleSize, height: bubbleSize) // Apply the constant size
            .background(color.opacity(0.15)) // Use the category color for the background
            .cornerRadius(10) // Make it a rounded box
            .overlay(
                // Add a border using the category color
                RoundedRectangle(cornerRadius: 10)
                    .stroke(color, lineWidth: 2)
            )
    }
}

private func colorForCategory(_ categoryName: String) -> Color {
        // Get the absolute hash value of the string
        let hash = abs(categoryName.hashValue)
        
        // Map the hash to a hue value (0.0 to 1.0)
        // Using 360 (degrees in a color wheel) gives a good distribution
        let hue = Double(hash % 360) / 360.0
        
        // Use fixed saturation and brightness for a pleasing, consistent color palette
        let saturation = 0.7
        let brightness = 0.85
        
        return Color(hue: hue, saturation: saturation, brightness: brightness)
}





#Preview {
    VisualizationView()
        .modelContainer(for: [Thought.self, Category.self], inMemory: false)
    
}

