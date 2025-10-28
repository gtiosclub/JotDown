//
//  CategoryItemView.swift
//  JotDown
//
//  Created by Neel Maddu on 10/14/25.
//

import SwiftUI

struct CategoryItemView: View {
    let thought: Thought
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
    }
}

//#Preview {
//    IndividualNotecardView()
//}

#Preview {
    // Sample instance of Thought for previewing
    let sampleThought = Thought(content: "i just realized i could make ice cream mochi but with mango sticky rice inside!!!")
    return CategoryItemView(thought: sampleThought)
}
