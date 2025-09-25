//
//  ThoughtsEntryView.swift
//  JotDown
//
//  Created by Sankaet Cheemalamarri on 9/22/25.
//

import SwiftData
import SwiftUI

struct ThoughtsEntryView: View {
    @State private var thought: String = ""
    @Environment(\.dismiss) private var dismiss: DismissAction
    @Query var thoughts: [Thought]
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        VStack {
            VStack {
                TextField("What's on your mind?", text: $thought)
                    .padding()
                    .background()
                    .font(.title)
                    .cornerRadius(10)
                Button("Submit") {
                    let thought = Thought(content: thought)
                    modelContext.insert(thought)
                    dismiss()
                }
                .padding()
                .buttonStyle(.borderedProminent)
            }
        }
    }
}
