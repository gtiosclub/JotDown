//
//  FooterHomeView.swift
//  JotDown
//
//  Created by Drew Mendelow on 10/14/25.
//

import SwiftUI

struct FooterHomeView: View {
    var noteCount: Int
    var date: Date
    
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, MMM d"
        return formatter
    }()
    
    var body: some View {
        HStack(alignment: .bottom) {
          
            VStack(spacing: 0) {
                Text("\(noteCount)")
                  .font(Font.custom("SF Pro", size: 36))
                  .multilineTextAlignment(.center)
                  .foregroundColor(.white)
                Text("notes")
                  .font(Font.custom("SF Pro", size: 15))
                  .multilineTextAlignment(.center)
                  .foregroundColor(.white)
            }
          
            Spacer()
            
            VStack {
                Text(Calendar.current.isDateInToday(date) ? "Today" : FooterHomeView.dateFormatter.string(from: date))
                  .font(Font.custom("SF Pro", size: 36))
                  .multilineTextAlignment(.center)
                  .foregroundColor(.white)
                  .contentTransition(.numericText())

                Text("date")
                  .font(Font.custom("SF Pro", size: 15))
                  .multilineTextAlignment(.center)
                  .foregroundColor(.white)
            }
        }
        .animation(.default, value: date)
        .padding(.horizontal, 30)
        .padding(.vertical, 0)
        .frame(alignment: .bottom)
    }
}
