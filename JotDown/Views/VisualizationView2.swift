//
//  VisualizationView2.swift
//  JotDown
//
//  Created by Siddharth Palanivel on 10/23/25.
//

import SwiftUI
import SwiftData

struct VisualizationView2: View {
    @Environment(\.modelContext) private var context
    @Query var thoughts: [Thought]
    
    var body: some View {
        ScrollView([.horizontal, .vertical]) {
            RadialLayout {
                ForEach(thoughts.indices, id: \.self) { index in
                    Text(thoughts[index].content)
                        .layoutValue(key: CategoryLayoutKey.self, value: thoughts[index].category.name)
                }
            } .frame(width: 400, height: 400)
        }
        .defaultScrollAnchor(.center)

        
        
    }
}




#Preview {
    VisualizationView2()
        .modelContainer(for: [Thought.self, Category.self], inMemory: false)
    
}

