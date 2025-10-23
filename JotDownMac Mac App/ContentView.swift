//
//  ContentView.swift
//  MenuBarTest
//
//  Created by Jeet Ajmani on 2025-10-21.
//

import SwiftUI

struct ContentView: View {
    
    @State private var thoughtInput: String = ""
    @State private var characterLimit: Int = 250
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isTextFieldFocused: Bool
    
    func calculateColor() -> Color {
        if thoughtInput.count > characterLimit {
            return Color.red
        } else if thoughtInput.isEmpty {
            return Color.gray
        } else {
            return Color.white
        }
    }
    
    var body: some View {
        VStack {
            HStack {
                TextField("What's on your mind?", text: $thoughtInput)
                    .focused($isTextFieldFocused)
                    .cornerRadius(10)
                    .frame(width: 200)
                    .textFieldStyle(.roundedBorder)
                    .onKeyPress(.return) {
                        // TODO: Implement logic to save thought
                        dismiss()
                        return .handled
                    }
                    .onKeyPress(.escape) {
                        if (thoughtInput == "") {
                            dismiss()
                        } else {
                            thoughtInput = ""
                        }
                        return .handled
                    }
                Text("\(thoughtInput.count)/\(characterLimit)")
                    .foregroundStyle(calculateColor())
                    .frame(width:60, alignment: .trailing)
            }
            
        }
        .padding()
        .onAppear {
            isTextFieldFocused = true
        }
        
    }
//        .background(.ultraThinMaterial)
//        .clipShape(RoundedRectangle(cornerRadius: 12))
}

#Preview {
    ContentView()
}
