//
//  NewNoteSwipableAction.swift
//  JotDown
//
//  Created by Drew Mendelow on 11/5/25.
//
import SwiftUI

struct NewNoteSwipableAction: View {
    var revealAmount: CGFloat // 0.0 to 1.0
    
    var body: some View {
        VStack {
            Spacer()
            Image(systemName: "plus")
                .font(.system(size: 10 + (20 * revealAmount))) // Scale from 40 to 60
                .foregroundColor(Color(red: 132/255, green: 133/255, blue: 177/255).opacity(0.6 + (0.4 * revealAmount)))
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 3, trailing: 0))
            Text("new note")
                .font(.custom("SF Pro", size: 14 + (4 * revealAmount))) // Scale from 14 to 18
                .foregroundColor(Color(red: 132/255, green: 133/255, blue: 177/255).opacity(0.6 + (0.4 * revealAmount)))
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
