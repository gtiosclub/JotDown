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
    
    //Mark data
    let categories = ["Foo", "Baz", "Bar", "Blud"]
    
    var body: some View {
        ScrollView([.horizontal, .vertical]) {
            ZStack {
                GridBackground()
                    .opacity(0)
                GeometryReader { geo in
                    let width = geo.safeAreaInsets.leading + geo.size.width + geo.safeAreaInsets.trailing
                    let height = geo.safeAreaInsets.top + geo.size.height + geo.safeAreaInsets.bottom
                    let radius = min(width, height) * 0.5
                    let center = CGPoint(x: width / 2, y: height / 2)
                    
                    Circle()
                        .stroke(Color.green, lineWidth: 1) // outlinecolor + width
                        .frame(width: radius * 2, height: radius * 2)
                        .position(center)
                        .opacity(0)
                    
                    drawSectors(notes: categories, center: center,radius: radius)
                }
                .frame(width: 400, height: 400)
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

func drawSectors(notes: [String], center: CGPoint, radius: CGFloat) -> some View {
    let n = notes.count
    
    return ForEach(0..<n, id: \.self) { k in
        let (start, end, mid) = anglesForSector(index: k, total: n)
        
        // Radial line at start of sector
        Path { path in
            path.move(to: center)
            path.addLine(to: point(on: center, radius: radius, angle: start))
        }
        .stroke(Color.clear, lineWidth: 1)
        
        // Radial line at end of sector
        Path { path in
            path.move(to: center)
            path.addLine(to: point(on: center, radius: radius, angle: end))
        }
        .stroke(Color.clear, lineWidth: 1)
        
        // Optional: fill sector with angular gradient (makes it easier to see the slice)
        Path { path in
            path.move(to: center)
            path.addArc(center: center,
                        radius: radius,
                        startAngle: Angle(radians: start),
                        endAngle: Angle(radians: end),
                        clockwise: false)
            path.closeSubpath()
        }
        .fill(sectorGradient(index: k, total: n, center: center, startAngle: start, endAngle: end))
        .opacity(0.6)
        
        // Label in the center of sector
        // Place it at 50% radius along the mid-angle for better centering
        let labelPoint = point(on: center, radius: radius * 0.5, angle: mid)
        Text(notes[k])
            .font(.caption)
            .padding(6)
            .background(Color.yellow.opacity(0.85))
            .cornerRadius(6)
            .shadow(radius: 2)
            .position(labelPoint)
    }
}


// Returns (start, end, mid) angles in radians for sector `index`
func anglesForSector(index: Int, total: Int) -> (Double,Double, Double) {
    let step = 2 * .pi / Double(total)
    let start = -Double.pi / 2 + Double(index) * step //start at top
    let end = start + step
    let mid = (start + end) / 2
    return (start, end, mid)
}

// Converts polar coordinates to a CGPoint
func point(on center: CGPoint, radius: CGFloat, angle:Double) -> CGPoint {
    CGPoint(
        x: center.x + radius * CGFloat(cos(angle)),
        y: center.y + radius * CGFloat(sin(angle))
    )
}

// Keeps label text upright
func labelRotation(_ midAngle: Double) -> Double {
    var deg = midAngle * 180 / .pi
    if deg > 90 && deg < 270 { deg += 180 }
    return deg
}

// Returns a per-item angular gradient oriented around the circle
func sectorGradient(index: Int, total: Int, center: CGPoint, startAngle: Double, endAngle: Double) -> AngularGradient {
    // A high-contrast, well-separated palette
    let palette: [Color] = [
        .red, // red
        .green, // green
        .blue, // blue
        .purple, // purple
        .yellow, // yellow
        .orange, // orange
        .teal, // teal
        Color(red: 0.55, green: 0.76, blue: 0.29), // lime
        Color(red: 0.86, green: 0.11, blue: 0.35), // magenta
        Color(red: 0.36, green: 0.42, blue: 0.46)  // slate
    ]

    let base = palette[index % palette.count]

    // Derive a darker variant for subtle depth
    let darker = base.opacity(0.95)

    let start = Angle(radians: startAngle)
    let end = Angle(radians: endAngle)

    return AngularGradient(
        gradient: Gradient(colors: [base.opacity(0.80), darker.opacity(0.80)]),
        center: .init(x: center.x, y: center.y),
        startAngle: start,
        endAngle: end
    )
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
