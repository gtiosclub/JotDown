//
//  ContentView.swift
//  JotDownWatch Watch App
//
//  Created by Jeet Ajmani on 10/14/25.
//

import SwiftData
import SwiftUI

struct WatchThoughtsEntryView: View {

    @State private var thoughtInput: String = ""
    @State private var characterLimit: Int = 250
    @ObservedObject private var session = WatchSessionManager.shared
    @Environment(\.dismiss) private var dismiss
    
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
                    .cornerRadius(10)
                Text("\(thoughtInput.count)/\(characterLimit)")
                    .foregroundStyle(calculateColor())
                HStack {
                    Button("Clear") {
                        thoughtInput = ""
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.red)
                    
                    Button("Add") {
                        session.sendThought(thoughtInput)
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(thoughtInput.count > characterLimit)
                }.padding()

            }.padding()
        }.navigationTitle("Add Thought")
    }
}

#Preview {
    WatchThoughtsEntryView()
}
