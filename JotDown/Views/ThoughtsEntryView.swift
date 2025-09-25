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
    @State private var characterLimit: Int = 250
    
    func calculateColor() -> Color {
        if thought.count > characterLimit {
            return Color.red
        } else if thought.isEmpty {
            return Color.gray
        } else {
            return Color.blue
        }
    }
    
    var body: some View {
        VStack {
            VStack {
                TextField("What's on your mind?", text: $thought)
                    .padding()
                    .background()
                    .font(.title)
                    .cornerRadius(10)
                Button("Submit") {
                    // TODO: Implement Submit Functionality
                }
                .padding()
                .buttonStyle(.borderedProminent)
                .disabled(thought.count > characterLimit)
                
                Text("\(thought.count)/\(characterLimit)")
                    .foregroundStyle(calculateColor())
            }
        }
    }
}


#Preview {
    ThoughtsEntryView()
}
