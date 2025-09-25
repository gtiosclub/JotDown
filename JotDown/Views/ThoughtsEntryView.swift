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
            }
        }
    }
}
