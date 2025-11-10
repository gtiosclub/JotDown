//
//  JotDownLogo.swift
//  JotDown
//
//  Created by Drew Mendelow on 10/16/25.
//
import SwiftUI

struct JotDownLogo: View {
    var style: JotDownLogoStyle = .regular
    var color: Color = .white

    var body: some View {
        if (style == .regular) {
            VStack(alignment: .leading, spacing: -12) {
                Text("jot")
                Text("down")
            }
            .font(
                Font.custom("SF Pro", size: 48)
            )
            .shadow(color: .black.opacity(0.04), radius: 4.8, x: 0, y: 4)
            .foregroundStyle(color.opacity(0.82))
        } else if (style == .heavy) {
            VStack(alignment: .leading, spacing: -12) {
                Text("jot")
                Text("down")
            }
            .font(.system(size: 48, weight: .medium, design: .default))
            .shadow(color: .black.opacity(0.04), radius: 4.8, x: 0, y: 4)
            .foregroundStyle(
                LinearGradient(
                    stops: [
                        Gradient.Stop(color: Color(red: 0.63, green: 0.63, blue: 0.87), location: 0.00),
                        Gradient.Stop(color: Color(red: 107/255, green: 107/255, blue: 138/255), location: 1.0),
                    ],
                    startPoint: UnitPoint(x: 0.5, y: 0),
                    endPoint: UnitPoint(x: 0.5, y: 1)
                )
            )
        }
    }
}

enum JotDownLogoStyle {
    case regular
    case heavy
}
