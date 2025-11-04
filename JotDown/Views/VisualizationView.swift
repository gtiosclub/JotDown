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
    @Query var thoughts: [Thought]
    
    @State private var zoomLevel: CGFloat = 1.0
    @State private var finalZoomLevel: CGFloat = 1.0
    
    let minZoom: CGFloat = 0.5
    let maxZoom: CGFloat = 3.0
    
    
    var body: some View {
        ScrollView([.horizontal, .vertical]) {
            ZStack {
                GridBackground()
                RadialLayout {
                    ForEach(thoughts.indices, id: \.self) { index in
                        ThoughtBubbleView(thought: thoughts[index], color: colorForCategory(thoughts[index].category.name))
                            .layoutValue(key: CategoryLayoutKey.self, value: thoughts[index].category.name)
                    }
                } .frame(width: 400, height: 400)
            }
            .scaleEffect(zoomLevel)
            .gesture(magnificationGesture)

        }
        .defaultScrollAnchor(.center)
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
                
                withAnimation {
                    self.zoomLevel = self.finalZoomLevel
                }
            }
    }
}


// MARK: - GridBackground

struct GridBackground: View {
    let size: CGFloat = 5000
    let spacing: CGFloat = 50
    let lineColor = Color(.lightGray).opacity(0.7)
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
    
    // Define a constant size for the bubble
    private let bubbleSize: CGFloat = 70
    
    var body: some View {
        Text(thought.content)
            .font(.caption) // Use caption font to fit more text
            .multilineTextAlignment(.center)
            .foregroundStyle(.primary) // Use primary text color for readability
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

