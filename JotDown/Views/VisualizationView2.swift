//
//  VisualizationView2.swift
//  JotDown
//
//  Created by Siddharth Palanivel on 10/23/25.
//

import SwiftUI

struct VisualizationView2: View {
    var body: some View {
        ScrollView([.horizontal, .vertical]) {
            RadialLayout {
                Text("test")
                    .layoutValue(key: CategoryLayoutKey.self, value: "test")
                Text("test")
                    .layoutValue(key: CategoryLayoutKey.self, value: "test")
            } .frame(width: 1000, height: 1000)
        }
        .defaultScrollAnchor(.center)

        
        
    }
}




#Preview {
    VisualizationView2()
}
