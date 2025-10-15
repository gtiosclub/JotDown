//
//  HeaderHomeView.swift
//  JotDown
//
//  Created by Drew Mendelow on 10/14/25.
//

import SwiftUI
import SwiftData

struct HeaderHomeView: View {
    @Query private var categories: [Category]
    @Binding var thoughtInput: String
    @State private var isSubmitting: Bool = false
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: -12) {
                Text("jot")
                    .font(
                        Font.custom("SF Pro", size: 48)
                    )
                Text("down")
                  .font(
                    Font.custom("SF Pro", size: 48)
                  )
            }
            .shadow(color: .black.opacity(0.04), radius: 4.8, x: 0, y: 4)
            .foregroundStyle(.white.opacity(0.82))
            
            Spacer()
            
            VStack {
                Spacer()
                HStack(spacing: 0) {
                    Button {
                        //Implement funcitonality
                    } label: {
                        Text("edit")
                            .font(Font.custom("SF Pro", size: 15))
                            .foregroundColor(Color(red: 0.42, green: 0.56, blue: 0.75))
                            .padding(.horizontal, 17)
                            .padding(.vertical, 8)
                            .background {
                                RoundedRectangle(cornerRadius: 15)
                                    
                                    .glassEffect()
                                    .foregroundStyle(Color.white.opacity(0.39))
                            }
                    }
                    .padding(.vertical, 7)
                    .padding(.trailing, 13)
                    
                    if isSubmitting {
                        ProgressView()
                    }
                    else {
                        Button {
                            Task {
                                await MainActor.run { isSubmitting = true }
                                defer {
                                    Task { await MainActor.run { isSubmitting = false } }
                                }

                                let thought = Thought(content: thoughtInput)

                                try? await Categorizer()
                                    .categorizeThought(thought, categories: categories)

                                modelContext.insert(thought)
                                dismiss()
                                
                                thoughtInput = ""
                            }
                        } label: {
                            Image(systemName: "plus")
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
