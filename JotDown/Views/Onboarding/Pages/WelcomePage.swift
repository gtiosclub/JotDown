//
//  WelcomePage.swift
//  JotDown
//
//  Created by Adam Ress on 10/30/25.
//

import SwiftUI

struct WelcomePage: View {
    
    @Binding var currentPage: Int
    @Binding var pageHeight: Int
    
    var body: some View {
        VStack {
            
            Spacer()
            
            JotDownLogoHeavy()
                .padding(.bottom, 48)
            
            // Subtext
            Text("Have all your thoughts organized in one place.")
              .font(
                Font.custom("SF Pro", size: 15)
              )
              .multilineTextAlignment(.center)
              .foregroundColor(Color(red: 0.49, green: 0.58, blue: 0.7))
              .frame(maxWidth: .infinity, alignment: .top)
              .padding(.bottom, 48)
            
            Spacer()

        }
        .padding(.horizontal, 102)
    }
}
