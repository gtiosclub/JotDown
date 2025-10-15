import SwiftUI

struct VisualizationView: View {
    
    // 1. STATE VARIABLES FOR ZOOMING
    // Tracks the live zoom level during a pinch gesture
    @State private var zoomLevel: CGFloat = 1.0
    
    // Stores the committed zoom level after a gesture ends
    @State private var finalZoomLevel: CGFloat = 1.0
    
    // Define the zoom limits
    let minZoom: CGFloat = 0.5
    let maxZoom: CGFloat = 3.0
    let categories = ["Foo", "Baz", "Bar"]

    var body: some View {
        ScrollView([.horizontal, .vertical]) {
            ZStack {
                GridBackground()
                Circle()
                    .stroke(Color.green, lineWidth: 1) // outline color + width
                    .frame(width: 400, height: 400)
                
                Text("\(categories[0])")
                    .padding()
                    .background(Color.yellow)
                    .cornerRadius(8)
                    .shadow(radius: 5)
                    .position(x: 2500, y: 2500)
            }
            // 2. APPLY THE ZOOM
            .scaleEffect(zoomLevel) // This modifier scales the entire ZStack
            // 3. ATTACH THE GESTURE
            .gesture(magnificationGesture)
        }
        .defaultScrollAnchor(.center)
        .background(Color(.systemBackground))
        .ignoresSafeArea()
    }
    
    // Helper property to define the gesture
    var magnificationGesture: some Gesture {
        MagnificationGesture()
            .onChanged { value in
                // Combine the gesture's change with the last known zoom level
                // The 'value' is the magnification factor of the current pinch
                self.zoomLevel = self.finalZoomLevel * value
            }
            .onEnded { value in
                // Save the final zoom level and clamp it within our limits
                self.finalZoomLevel = self.zoomLevel
                
                if self.finalZoomLevel < minZoom {
                    self.finalZoomLevel = minZoom
                } else if self.finalZoomLevel > maxZoom {
                    self.finalZoomLevel = maxZoom
                }
                
                // Animate the bounce-back if zoom goes out of bounds
                withAnimation {
                    self.zoomLevel = self.finalZoomLevel
                }
            }
    }
}


struct GridBackground: View {
    // Define the properties for our grid
    let size: CGFloat = 5000 // The total width and height of the grid canvas
    let spacing: CGFloat = 50  // The distance between each grid line
    let lineColor = Color(.lightGray).opacity(0.7)
    let lineWidth: CGFloat = 1

    var body: some View {
        // Canvas is a high-performance view for custom 2D drawing.
        Canvas { context, size in
            // Draw the vertical lines
            for x in stride(from: 0, to: size.width, by: spacing) {
                var path = Path()
                path.move(to: CGPoint(x: x, y: 0))
                path.addLine(to: CGPoint(x: x, y: size.height))
                context.stroke(path, with: .color(lineColor), lineWidth: lineWidth)
            }

            // Draw the horizontal lines
            for y in stride(from: 0, to: size.height, by: spacing) {
                var path = Path()
                path.move(to: CGPoint(x: 0, y: y))
                path.addLine(to: CGPoint(x: size.width, y: y))
                context.stroke(path, with: .color(lineColor), lineWidth: lineWidth)
            }
        }
        // It's critical to give the Canvas a large, explicit frame.
        // This is what the ScrollView uses to determine its scrollable area.
        .frame(width: size, height: size)
    }
}

#Preview {
    VisualizationView()
}
