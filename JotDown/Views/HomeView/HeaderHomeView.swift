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
                                selectedIndex = 0;
                            } else if thoughtInput.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
                                Task {
                                    try await addThought()
                                }
                            }
                        } label: {
                            Image(systemName: "plus")
                                .fontWeight(.light)
                                .font(.system(size: 30))
                                .foregroundStyle(thoughtInput.trimmingCharacters(in: .whitespacesAndNewlines) != "" || selectedIndex != 0 ? Color(red: 109/255, green: 134/255, blue: 166/255) : Color.gray.opacity(0.4))
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
