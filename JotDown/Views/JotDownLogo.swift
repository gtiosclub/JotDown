//
//  JotDownLogo.swift
//  JotDown
//
//  Created by Drew Mendelow on 10/16/25.
//
import SwiftUI

struct JotDownLogo: View {
    var body: some View {
        VStack(alignment: .leading, spacing: -12) {
            Text("jot")
            Text("down")
        }
        .font(
             Font.custom("SF Pro", size: 48)
         )
        .shadow(color: .black.opacity(0.04), radius: 4.8, x: 0, y: 4)
        .foregroundStyle(.white.opacity(0.82))
    }
}
