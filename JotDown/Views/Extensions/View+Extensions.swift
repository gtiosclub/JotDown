import SwiftUI

extension View {
    func primaryBackground() -> some View {
        self.background {
            EllipticalGradient.primaryBackground
                .ignoresSafeArea()
        }
    }

    func cardShadow() -> some View {
        self.shadow(color: .black.opacity(0.05), radius: 7.7, x: 0, y: 2)
    }

    func elevatedShadow() -> some View {
        self.shadow(color: .black.opacity(0.1), radius: 10, y: 5)
    }

    func subtleShadow() -> some View {
        self.shadow(color: .black.opacity(0.04), radius: 4.8, x: 0, y: 4)
    }

    func thoughtCardStyle() -> some View {
        self
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 30))
            .cardShadow()
    }

    func pillStyle() -> some View {
        self
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.black.opacity(0.04))
            .clipShape(Capsule())
    }

    func pageTitle() -> some View {
        self
            .font(.system(size: 40, weight: .bold))
            .foregroundColor(.primaryText)
    }
}

extension Text {
    func titleStyle() -> some View {
        self.font(.system(size: 40, weight: .bold))
            .foregroundColor(.primaryText)
    }

    func largeTitleStyle() -> some View {
        self.font(.system(size: 28, weight: .bold))
            .foregroundColor(.primaryText)
    }

    func bodyTextStyle() -> some View {
        self.font(.system(size: 24, weight: .regular))
            .foregroundColor(.primaryText)
    }

    func mediumTextStyle() -> some View {
        self.font(.system(size: 20, weight: .regular))
            .foregroundColor(.primaryText)
    }

    func captionStyle() -> some View {
        self.font(.system(size: 15, weight: .regular))
            .foregroundColor(.primaryText.opacity(0.8))
    }

    func smallCaptionStyle() -> some View {
        self.font(.system(size: 12, weight: .regular))
            .foregroundColor(.primaryText)
    }

    func statLabelStyle() -> some View {
        self.font(.system(size: 28, weight: .bold))
            .foregroundColor(.primaryText)
    }

    func statDescriptionStyle() -> some View {
        self.font(.system(size: 15, weight: .regular))
            .foregroundColor(.primaryText.opacity(0.8))
    }
}
