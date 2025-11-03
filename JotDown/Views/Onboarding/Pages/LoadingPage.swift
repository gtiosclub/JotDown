//
//  LoadingPage.swift
//  JotDown
//
//  Created by Adam Ress on 11/2/25.
//

import SwiftUI

struct LoadingPage: View {
    var body: some View {
        VStack {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
                .scaleEffect(1.4)
            
            Text("Creating suggestions...")
                .font(.headline)
                .foregroundStyle(Constants.TextLightText)
        }
    }
}

#Preview {
    LoadingPage()
}
