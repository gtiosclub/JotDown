//
//  CategoryItemView.swift
//  JotDown
//
//  Created by Neel Maddu on 10/14/25.
//

import SwiftUI

struct CategoryItemView: View {
    let thought: Thought
    var onPin : (Thought) -> Void = { _ in }
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(thought.content)
                .font(.system(size: 15, weight: .regular))
                .kerning(-0.011 * 15)
                .lineSpacing(-1)
                .foregroundColor(.black)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 8)
            Spacer()
            
//            Text(thought.dateCreated.formatted(date: .abbreviated, time: .shortened))
//                .font(.caption)
            HStack(alignment: .top){
                Text("Last Edited")
                    .font(.system(size: 7, weight: .regular))
                    .kerning(-0.011 * 7)
                    .lineSpacing(0.14 * 7)
                    .foregroundColor(.gray)
                    .alignmentGuide(.top) { d in d[.top]}
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 1){
                    Text(thought.dateCreated.formatted(
                        Date.FormatStyle()
                            .month(.abbreviated)
                            .weekday(.abbreviated)
                            .day()
                        ))
                        .font(.system(size: 7, weight: .regular))
                        .kerning(-0.011 * 7)
                        .lineSpacing(0.14 * 7)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.trailing)
                    
                    Text(thought.dateCreated.formatted(
                        Date.FormatStyle()
                            .hour(.defaultDigits(amPM: .abbreviated))
                            .minute()
                        ))
                        .font(.system(size: 7, weight: .regular))
                        .kerning(-0.011 * 7)
                        .lineSpacing(0.14 * 7)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.trailing)
                }
            }
            
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(25)
        .shadow(color:.black.opacity(0.1), radius: 5, x: 0, y: 2)
        .overlay(alignment: .topTrailing) {
            if thought.isPinned {
                Image(systemName: "pin.fill")
                    .foregroundColor(.gray)
                    .padding(6)
            }
        }
        .contextMenu {
            Button {
                onPin(thought)
                UINotificationFeedbackGenerator().notificationOccurred(.success)
            } label: {
                Label(thought.isPinned ? "Unpin Note" : "Pin Note", systemImage: "pin")
            }
            
            Button {
                UIPasteboard.general.string = thought.content
                UINotificationFeedbackGenerator().notificationOccurred(.success)
            } label: {
                Label("Copy Note", systemImage: "doc.on.doc")
            }
            
            Button {
                // TODO: Share stuff
            } label: {
                Label("Share Note", systemImage: "square.and.arrow.up")
            }
        }
    }
}

//#Preview {
//    IndividualNotecardView()
//}

#Preview {
    // Sample instance of Thought for previewing
    let sampleThought = Thought(content: "I just realized i could make ice cream mochi but with mango sticky rice inside!!!")
    return CategoryItemView(thought: sampleThought)
}
