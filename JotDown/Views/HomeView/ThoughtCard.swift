//
//  ThoughtCard.swift
//  JotDown
//
//  Created by Drew Mendelow on 10/14/25.
//
import SwiftUI

struct ThoughtCard: View {
    var thought: Thought
    @Environment(\.modelContext) private var context
    @Namespace private var namespace
    
    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter
    }()
    
    var body: some View {
        ZStack(alignment: .top) {
           RoundedRectangle(cornerRadius: 30)
               .fill(Color.white.opacity(0.61))
               .frame(width: 251, height: 436)
//               .glassEffect()
               .shadow(color: Color.black.opacity(0.05), radius: 7.7, x: 0, y: 2)
           
           VStack(alignment: .leading) {
               Text(thought.content)
                   .frame(maxWidth: .infinity, alignment: .leading)
                   .foregroundColor(Color(red: 0.49, green: 0.58, blue: 0.70))
                   .font(.custom("SF Pro", size: 24))
                   .lineSpacing(12)
                   .fontWeight(.regular)
                   .truncationMode(.tail)

               Spacer()

               HStack {
                   Text(ThoughtCard.timeFormatter.string(from: thought.dateCreated))
                       .font(.system(size: 16, weight: .regular))
                       .italic()
                       .foregroundColor(Color(red: 0.49, green: 0.58, blue: 0.70))
                       .lineLimit(1)
                       .truncationMode(.tail)
                   Spacer()
                   
                   if (thought.category.isActive) {
                       NavigationLink(destination: CategoryDashboardView(category: thought.category, namespace: namespace)) {
                           HStack(spacing: 2) {
                               Text(thought.category.name)
                                   .font(.system(size: 16, weight: .regular))
                                   .italic()
                                   .foregroundColor(Color(red: 0.49, green: 0.58, blue: 0.70))
                                   .lineLimit(1)
                                   .truncationMode(.tail)
                               Text("→")
                                   .font(.system(size: 16, weight: .regular))
                                   .italic()
                                   .foregroundColor(Color(red: 0.49, green: 0.58, blue: 0.70))
                                   .padding(EdgeInsets(top: 0, leading: -2, bottom: 0, trailing: 0))
                           }
                       }
                       .buttonStyle(PlainButtonStyle())
                   } else {
                       Text(thought.category.name)
                           .font(.system(size: 16, weight: .regular))
                           .italic()
                           .foregroundColor(.gray.opacity(0.6))
                           .lineLimit(1)
                           .truncationMode(.tail)
                   }
               }
           }
           .padding(EdgeInsets(top: 23, leading: 14, bottom: 23, trailing: 14))
           .frame(width: 251, height: 436)
       }
    }
}

