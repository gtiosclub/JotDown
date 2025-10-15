//
//  ContentView.swift
//  JotDownWatch Watch App
//
//  Created by Jeet Ajmani on 10/14/25.
//

import SwiftData
import SwiftUI

struct WatchThoughtsListView: View {

    let thoughts: [String] = ["Thought 1", "Thought 2", "Thought 3"]
    
    var body: some View {
        // TODO: Add functionality to display thoughts from iOS app
        List {
            ForEach(thoughts, id: \.self) { thought in
                HStack {
                    Text(thought)
                }
            }
//            .onDelete(perform: deleteNote)
        }
        .navigationTitle("Thoughts")
    }
}

#Preview {
    WatchThoughtsListView()
}
