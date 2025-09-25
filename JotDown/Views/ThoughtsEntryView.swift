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
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack {
            VStack {
                TextField("What's on your mind?", text: $thought)
                    .padding()
                    .background()
                    .font(.title)
                    .cornerRadius(10)
                Button("Submit") {
                    
                }
                .padding()
                .buttonStyle(.borderedProminent)
                Button("Cancel") {
                    thought = ""
                    dismiss()
                }
                .padding()
                .buttonStyle(.borderedProminent)
                .tint(.red)
            }
        }
    }
}
