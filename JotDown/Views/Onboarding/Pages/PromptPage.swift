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
            Rectangle()
                .foregroundStyle(Color.clear)
                .onTapGesture {
                    //isFocused = false;
                    //Potential error when user changes input and doesnt hit submit.
                }
            
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
                    
                    // Placeholder
                    if userInput.isEmpty {
                        Text("Type here")
                            .font(Font.custom("SF Pro", size: 15))
                            .foregroundColor(.gray.opacity(0.5))
                            .padding(.leading, 20)
                            .padding(.top, 23)
                            .allowsHitTesting(false)
                    }
                    
                    TextEditor(text: $userInput)
                        .font(Font.custom("SF Pro", size: 15))
                        .foregroundColor(Constants.TextDarkText)
                        .scrollContentBackground(.hidden)
                        .background(Color.clear)
                        .frame(width: 260, height: 285)
                        .padding(.leading, 16)
                        .padding(.top, 15)
                        .focused($isFocused)
                }
                
                Spacer()
            }
        }
        .ignoresSafeArea(.keyboard)
    }
}
