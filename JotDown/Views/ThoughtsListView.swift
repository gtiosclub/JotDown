//
//  ThoughtsListView.swift
//  JotDown
//
//  Created by Sankaet Cheemalamarri on 9/22/25.
//

import SwiftData
import SwiftUI

struct ThoughtsListView: View {
    @Query(sort: \Thought.dateCreated, order: .reverse) var thoughts: [Thought]
    
    var body: some View {
        List {
            ForEach(thoughts) { thought in
                Text(thought.content)
            }
        }
        .navigationTitle("Thoughts")
    }
}
