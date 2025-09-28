//
//  ThoughtsEntryView.swift
//  JotDown
//
//  Created by Sankaet Cheemalamarri on 9/22/25.
//

import SwiftData
import SwiftUI

struct ThoughtsEntryView: View {
    @State private var thoughtInput: String = ""
    @State private var characterLimit: Int = 250
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    func calculateColor() -> Color {
        if thoughtInput.count > characterLimit {
            return Color.red
        } else if thoughtInput.isEmpty {
            return Color.gray
        } else {
            return Color.blue
        }
    }
    
    var body: some View {
        VStack {
            VStack {
                TextField("What's on your mind?", text: $thoughtInput)
                    .padding()
                    .background()
                    .font(.title)
                    .cornerRadius(10)
                Button("Submit") {
                    let thought = Thought(content: thoughtInput)
                    modelContext.insert(thought)
                    dismiss()
                }
                .padding()
                .buttonStyle(.borderedProminent)
                .disabled(thoughtInput.count > characterLimit)
                
                Text("\(thoughtInput.count)/\(characterLimit)")
                    .foregroundStyle(calculateColor())
                Button("Cancel") {
                    thoughtInput = ""
                    dismiss()
                }
                .padding()
                .buttonStyle(.borderedProminent)
                .tint(.red)
            }
        }
    }
}


#Preview {
    ThoughtsEntryView()
}
