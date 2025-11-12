import SwiftUI

struct ThoughtBubbleView: View {
    let thought: Thought
    let color: Color
    let zoomLevel: CGFloat

    private let bubbleSize: CGFloat = 70

    private var textOpacity: Double {
        let fadeStart: CGFloat = 0.75
        let fadeEnd: CGFloat = 1.0

        let progress = (zoomLevel - fadeStart) / (fadeEnd - fadeStart)
        return max(0.0, min(1.0, progress))
    }

    var body: some View {
        Text(thought.content)
            .font(.system(size: 12, weight: .medium))
            .multilineTextAlignment(.center)
            .lineLimit(3)
            .foregroundColor(.primaryText)
            .opacity(textOpacity)
            .animation(.easeInOut(duration: 0.2), value: textOpacity)
            .padding(.vertical, 10)
            .padding(.horizontal, 10)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(.ultraThinMaterial)
                    .fill(color.opacity(0.5))
            )
            .cornerRadius(10)
            .shadow(color: .black.opacity(0.15), radius: 5, x: 0, y: 4)
            .frame(maxWidth: 120, maxHeight: 35)
    }
}

func colorForCategory(_ categoryName: String) -> Color {
    let hash = abs(categoryName.hashValue)
    let hue = Double(hash % 360) / 360.0
    let saturation = 0.7
    let brightness = 0.85

    return Color(hue: hue, saturation: saturation, brightness: brightness)
}

func colorForEmotion(_ emotion: Emotion) -> Color {
    switch emotion {
    case .anger:
        return Color(red: 0.9, green: 0.3, blue: 0.3) // Red
    case .fear:
        return Color(red: 0.6, green: 0.4, blue: 0.8) // Purple
    case .sadness:
        return Color(red: 0.4, green: 0.6, blue: 0.9) // Blue
    case .calm:
        return Color(red: 0.5, green: 0.8, blue: 0.7) // Teal/Green
    case .strong:
        return Color(red: 0.9, green: 0.6, blue: 0.2) // Orange
    case .happiness:
        return Color(red: 0.95, green: 0.85, blue: 0.3) // Yellow
    case .unknown:
        return Color.gray
    }
}
