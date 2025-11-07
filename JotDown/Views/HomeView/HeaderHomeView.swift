//
//  HeaderHomeView.swift
//  JotDown
//
//  Created by Drew Mendelow on 10/14/25.
//

import SwiftUI
import SwiftData

struct HeaderHomeView: View {
    @Binding var thoughtInput: String
    @Binding var selectedIndex: Int?
    @Binding var isSubmitting: Bool
    @Binding var showWritableThought: Bool
    @FocusState var isFocused: Bool
    let addThought: () async throws -> Void
    
    var body: some View {
        HStack {
            JotDownLogo()
            
            Spacer()
            
            VStack {
                Spacer()
                HStack(spacing: 0) {
                    Button {
                        //Implement funcitonality
                        isFocused = false
                    } label: {
                        Text("edit")
                            .font(Font.custom("SF Pro", size: 15))
                            .foregroundColor(Color(red: 0.42, green: 0.56, blue: 0.75))
                            .padding(.horizontal, 4)
                    }
                    .buttonBorderShape(.capsule)
                    .buttonStyle(.glass)
                    .padding(.vertical, 7)
                    .padding(.trailing, 13)
                    
                    if isSubmitting {
                        ProgressView()
                    } else {
                        Button {
                            isFocused = false
                            if selectedIndex != nil && selectedIndex != 0 {
                                showWritableThought = true
                                selectedIndex = 0;
                            } else {
                                Task {
                                    try await addThought()
                                }
                            }
                        } label: {
                            Image(systemName: selectedIndex != 0 ? "plus" : "checkmark")
                                .fontWeight(.light)
                                .font(.system(size: 30))
                                .foregroundStyle(Color(red: 109/255, green: 134/255, blue: 166/255))
                                .padding(.vertical, 10)
                        }
                    }
                }
            }
            
            
        }
        .padding(.horizontal, 30)
        .padding(.vertical, 0)
        .frame(height: 100)
    }
}
