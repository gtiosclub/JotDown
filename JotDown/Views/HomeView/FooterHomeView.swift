//
//  FooterHomeView.swift
//  JotDown
//
//  Created by Drew Mendelow on 10/14/25.
//

import SwiftUI

struct FooterHomeView: View {
    var body: some View {
        HStack(alignment: .bottom) {
          
            VStack(spacing: 0) {
                Text("31")
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
                Text("Sun, Oct 12")
                  .font(Font.custom("SF Pro", size: 36))
                  .multilineTextAlignment(.center)
                  .foregroundColor(.white)
                
                Text("date")
                  .font(Font.custom("SF Pro", size: 15))
                  .multilineTextAlignment(.center)
                  .foregroundColor(.white)
            }
          
        }
        .padding(.horizontal, 30)
        .padding(.vertical, 0)
        .frame(alignment: .bottom)
    }
}
