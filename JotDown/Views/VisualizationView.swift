import SwiftUI

// MARK: - VisualizationView

struct VisualizationView: View {
    
    // ... State Variables
    @State private var zoomLevel: CGFloat = 1.0
    @State private var finalZoomLevel: CGFloat = 1.0
    
    let minZoom: CGFloat = 0.5
    let maxZoom: CGFloat = 3.0
    
    // Mark data
    let categories = ["Foo", "Baz", "Bar", "Blud"]
    
    // High-Contrast Palette
    let sectorColors: [Color] = [
        .red,
        .orange,
        .green,
        .blue,
        .purple,
        .pink,
        .gray,
        .yellow,
        .teal
    ]
    
    // Store the unique, randomized color sequence in a @State property.
        @State private var assignedColors: [Color] = {
            // Shuffle the master list of colors and take only the required number (4 in this case)
            let neededColors = 4
            let baseColors: [Color] = [
                .red,
                .orange,
                .green,
                .blue,
                .purple,
                .pink,
                .gray,
                .yellow,
                .teal
            ]
            return Array(baseColors.shuffled().prefix(neededColors))
        }()
    
    // Defines the proportion dedicated to blending (e.g., 20% for blending = 80% solid)
    let blendProportion: Double = 0.55
    
    var body: some View {
        ScrollView([.horizontal, .vertical]) {
            ZStack {
                GridBackground()
                    .opacity(0.5)
                
                GeometryReader { geo in
                    let width = geo.size.width
                    let height = geo.size.height
                    let radius = min(width, height) * 0.4
                    let center = CGPoint(x: width / 2, y: height / 2)
                    
                    Circle()
                        .fill(continuousAngularGradient(colors: assignedColors, center: center))
                        .frame(width: radius * 2, height: radius * 2)
                        .position(center)
                    
                    drawLabels(notes: categories, center: center, radius: radius)
                }
                .frame(width: 400, height: 400)
            }
            .scaleEffect(zoomLevel)
            .gesture(magnificationGesture)
        }
        .defaultScrollAnchor(.center)
        .background(Color(.systemBackground))
        .ignoresSafeArea()
    }
    
    // ... Magnification Gesture
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
    
    // Properly places stops to define the blend on both sides of the core.
    func continuousAngularGradient(colors: [Color], center: CGPoint) -> AngularGradient {
        let n = categories.count
        let sectorStep = 2 * .pi / Double(n)
        
        var gradientStops: [Gradient.Stop] = []
        let fullPalette = colors + colors
        
        // The angle dedicated to the blend on ONE side (e.g., 10% of the sector)
        let blendAngle = sectorStep * (blendProportion / 2.0)
        
        for index in 0..<n {
            // Get angles based on the 3 o'clock start (0 radians)
            let rawStart = Double(index) * sectorStep
            let sectorColor = fullPalette[index]
            
            // 1. Blend Start Stop (Transition FROM previous color)
            // This color is placed at the start angle + the blend zone size.
            let coreStartAngle = rawStart + blendAngle
            let coreStartLocation = Angle(radians: coreStartAngle).normalizedDegrees / 360.0
            
            // 2. Blend End Stop (Transition INTO next color)
            // This color is placed at the end angle - the blend zone size.
            let coreEndAngle = rawStart + sectorStep - blendAngle
            let coreEndLocation = Angle(radians: coreEndAngle).normalizedDegrees / 360.0
            
            // Add stops for the solid core color
            gradientStops.append(Gradient.Stop(color: sectorColor, location: coreStartLocation.clamped(to: 0...1)))
            gradientStops.append(Gradient.Stop(color: sectorColor, location: coreEndLocation.clamped(to: 0...1)))
            
            // The blend occurs naturally in the space between the coreEndLocation (1)
            // and the coreStartLocation of the next sector (2).
        }
        
        // Sorting is crucial as locations wrap around 0/360
        gradientStops.sort { $0.location < $1.location }
        
        // Add a final stop to ensure the smooth wrap-around to the first color
        let firstColor = fullPalette[0]
        let finalStop = Gradient.Stop(color: firstColor, location: 1.0)
        
        // We use the stops and a 0-360 range for the AngularGradient
        let finalStops = gradientStops + [finalStop]
        
        return AngularGradient(
            gradient: Gradient(stops: finalStops),
            center: .center,
            startAngle: Angle(degrees: 0),
            endAngle: Angle(degrees: 360)
        )
    }
}

// MARK: - Sector Labels

func drawLabels(notes: [String], center: CGPoint, radius: CGFloat) -> some View {
    let n = notes.count
    
    return ForEach(0..<n, id: \.self) { k in
        let (_, _, mid) = anglesForSector(index: k + 1, total: n)
        
        let labelPoint = point(on: center, radius: radius * 0.5, angle: mid)
        Text(notes[k])
            .font(.title3)
            .bold()
            .foregroundColor(.black)
            .shadow(radius: 2)
            .position(labelPoint)
    }
}

// MARK: - Helper Functions & Extensions

// This function keeps the visual layout aligned to 12 o'clock (top)
func anglesForSector(index: Int, total: Int) -> (Double,Double, Double) {
    let step = 2 * .pi / Double(total)
    let rawStart = Double(index - 1) * step
    let rawEnd = rawStart + step
    let rawMid = (rawStart + rawEnd) / 2
    
    let rotationOffset = -Double.pi / 2
    
    let start = rawStart + rotationOffset
    let end = rawEnd + rotationOffset
    let mid = rawMid + rotationOffset
    
    return (start, end, mid)
}

func point(on center: CGPoint, radius: CGFloat, angle:Double) -> CGPoint {
    CGPoint(
        x: center.x + radius * CGFloat(cos(angle)),
        y: center.y + radius * CGFloat(sin(angle))
    )
}

extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        return min(max(self, limits.lowerBound), limits.upperBound)
    }
}

extension Angle {
    var normalizedDegrees: Double {
        var degrees = self.degrees.truncatingRemainder(dividingBy: 360)
        if degrees < 0 {
            degrees += 360
        }
        return degrees
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

#Preview {
    VisualizationView()
}
