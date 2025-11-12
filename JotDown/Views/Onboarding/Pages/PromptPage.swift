//
//  PromptPage.swift
//  JotDown
//
//  Created by Adam Ress on 10/30/25.
//

import SwiftUI

struct PromptPage: View {
    
    @Binding var userInput: String
    @FocusState private var isFocused: Bool
    
    var onSubmit: () async -> Void
    
    var body: some View {
        ZStack {
            VStack {
                
                Spacer()
                
                // Note Text
                Text("Fill out at least one prompt")
                    .font(Font.custom("SF Pro", size: 24))
                    .multilineTextAlignment(.center)
                    .foregroundColor(Constants.TextLightText)
                    .frame(maxWidth: .infinity, alignment: .top)
                    .padding(.bottom, 32)
                
                // Subtext
                Text("If Jot Down could organize your brain, where would it start?")
                    .font(
                        Font.custom("SF Pro", size: 15)
                    )
                    .foregroundColor(Constants.TextLightText)
                    .frame(width: 294, alignment: .topLeading)
                    .padding(.bottom)
                
                ZStack(alignment: .topLeading) {
                    RoundedRectangle(cornerRadius: 10)
                        .frame(width: 300, height: 316)
                        .foregroundStyle(.white.opacity(0.6))
                        .shadow(color: .black.opacity(0.1), radius: 4.95, x: 0, y: 2)
                    
                    TextField("Type here", text: $userInput, axis: .vertical)
                        .font(Font.custom("SF Pro", size: 15))
                        .foregroundColor(Constants.TextDarkText)
                        .background(Color.clear)
                        .frame(width: 260, height: 285, alignment: .top)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 15)
                        .focused($isFocused)
                        .submitLabel(.done)
                        .onChange(of: userInput) {
                            // If user remove extra line and dismiss keyboard
                            if userInput.last == "\n" {
                                userInput.removeLast()
                                isFocused = false
                            }
                        }
                }
                
                Spacer()
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            isFocused = false
        }
        .ignoresSafeArea(.keyboard)
    }
}
