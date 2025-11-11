import SwiftUI

extension ShapeStyle where Self == Color {
    static var primaryText: Color { Color(red: 0.35, green: 0.35, blue: 0.45) }

    static var secondaryText: Color { Color(red: 0.52, green: 0.52, blue: 0.69) }

    static var mediumText: Color { Color(red: 107/255, green: 107/255, blue: 138/255) }

    static var placeholderText: Color { Color(red: 191/255, green: 191/255, blue: 213/255) }

    static var selectionAccent: Color { Color(red: 0.75, green: 0.75, blue: 0.9) }

    static var buttonGradientStart: Color { Color(red: 0.61, green: 0.63, blue: 1) }

    static var buttonGradientEnd: Color { Color(red: 0.43, green: 0.44, blue: 0.81) }

    static var backgroundGradientStart: Color { Color(red: 0.94, green: 0.87, blue: 0.94) }

    static var backgroundGradientEnd: Color { Color(red: 0.78, green: 0.85, blue: 0.93) }
}

extension EllipticalGradient {
    static var primaryBackground: EllipticalGradient {
        EllipticalGradient(
            stops: [
                Gradient.Stop(color: .backgroundGradientStart, location: 0.00),
                Gradient.Stop(color: .backgroundGradientEnd, location: 1.00),
            ],
            center: UnitPoint(x: 0.67, y: 0.46)
        )
    }
}

extension LinearGradient {
    static var primaryButton: LinearGradient {
        LinearGradient(
            stops: [
                Gradient.Stop(color: .buttonGradientStart, location: 0.00),
                Gradient.Stop(color: .buttonGradientEnd, location: 1.00),
            ],
            startPoint: UnitPoint(x: 0.5, y: 0),
            endPoint: UnitPoint(x: 0.5, y: 1)
        )
    }
}
