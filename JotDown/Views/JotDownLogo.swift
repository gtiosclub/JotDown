//
//  JotDownLogo.swift
//  JotDown
//
//  Created by Drew Mendelow on 10/16/25.
//
import SwiftUI

struct JotDownLogo: View {
    var color = Color.white.opacity(0.82)
    var fontSize: CGFloat = 48
    
    var body: some View {
        VStack(alignment: .leading, spacing: -12) {
            Text("jot")
            Text("down")
        }
        .font(
             Font.custom("SF Pro", size: fontSize)
         )
        .shadow(color: .black.opacity(0.04), radius: 4.8, x: 0, y: 4)
        .foregroundStyle(color)
    }
}
