import SwiftUI

struct ThoughtBubbleView: View {
    let thought: Thought
    let color: Color
    let zoomLevel: CGFloat

    private let bubbleSize: CGFloat = 70

    private var opacity: Double {
        let fadeStart: CGFloat = 0.75
        let fadeEnd: CGFloat = 1.0

        let progress = (zoomLevel - fadeStart) / (fadeEnd - fadeStart)
        return max(0.4, min(1.0, progress))
    }

    var body: some View {
        VStack {
            if zoomLevel <= 0.8 {
                Text(thought.content)
                    .redacted(reason: .placeholder)
            } else {
                Text(thought.content)
            }
        }
        .bubbleStyle(color: color)
        .opacity(opacity)
    }
}

extension View {
    func bubbleStyle(color: Color, size: CGFloat = 18) -> some View {
        self
            .font(.system(size: size, weight: .medium))
            .foregroundStyle(Color(red: 0.3, green: 0.3, blue: 0.3))
            .lineLimit(5)
            .multilineTextAlignment(.leading)
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .frame(maxWidth: 200)
            .glassEffect(.clear.tint(color), in: .rect(cornerRadius: 24))
    }
}

func colorForCategory(_ categoryName: String) -> Color {
    let colors: [Color] = [
        Color(red: 1.00, green: 0.94, blue: 0.96),
        Color(red: 1.00, green: 0.95, blue: 0.97),
        Color(red: 1.00, green: 0.95, blue: 0.99),
        Color(red: 0.95, green: 0.99, blue: 1.00),
        Color(red: 0.94, green: 0.97, blue: 1.00),
        Color(red: 0.90, green: 0.96, blue: 1.00),
        Color(red: 0.91, green: 0.86, blue: 1.00),
        Color(red: 0.91, green: 0.87, blue: 0.99),
        Color(red: 1.00, green: 0.95, blue: 0.93),
        Color(red: 1.00, green: 1.00,  blue: 1.00)
    ]
    
    let index = abs(categoryName.hashValue) % colors.count
    return colors[index]
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
