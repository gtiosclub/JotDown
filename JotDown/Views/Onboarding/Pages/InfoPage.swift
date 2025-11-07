//
//  InfoPage.swift
//  JotDown
//
//  Created by Adam Ress on 10/30/25.
//

import SwiftUI

struct InfoPage: View {
    
    @Binding var currentPage: Int
    @Binding var pageHeight: Int
    
    var body: some View {
        VStack {
            
            Spacer()
            
            // Note Text
            Text("We suggest categories based on your interests")
              .font(Font.custom("SF Pro", size: 24))
              .multilineTextAlignment(.center)
              .foregroundStyle(
                Color(red: 132/255, green: 133/255, blue: 177/255)
              )
              .frame(width: 264, alignment: .top)
            
            Spacer()
            
            VStack {
                ZStack {
                    HStack {
                        Spacer()
                        CategoryCardExample(title: "Dog", scale: 1, opacity: 0.4, rotation:10, width: 230)
                        
                    }
                    .padding(.trailing, 95)
                    HStack {
                        Spacer()
                        CategoryCardExample(title: "Adventures", scale: 1, opacity: 0.6, rotation: 6, width: 260)
                            .padding(.top, 60)
                        
                    }
                    .padding(.trailing, 75)
                    HStack {
                        Spacer()
                        CategoryCardExample(title: "Volunteering", scale: 1, opacity: 0.8, rotation: 3, width: 295)
                            .padding(.top, 130)
                    }
                    .padding(.trailing, 55)
                    CategoryCardExample(title: "Greek Life", scale: 1, opacity: 1, rotation: 0)
                        .padding(.top, 200)
                    
                }
            }
            //To counteract excess padding.
            .padding(.top, -80)
            
            Spacer()
        
        }
        .padding(.top, 50)
    }
}

private struct CategoryCardExample: View {
    var title: String
    var scale: Double = 1.0
    var opacity: Double = 1.0
    var rotation: Double = 0
    var width: Int = 328
    
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Text(title)
                .font(
                    Font.custom("SF Pro", size: 24)
                )
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
                .padding(.top, 7)
                .padding(.leading, 5)
        }
        .padding(12)
        .frame(width: CGFloat(width), height: 300, alignment: .topLeading)
        .background(
            LinearGradient(
                stops: [
                    Gradient.Stop(color: Constants.TextLightText, location: 0.00),
                    Gradient.Stop(color: Constants.TextDarkText, location: 1.00),
                ],
                startPoint: UnitPoint(x: 1.22, y: -1.12),
                endPoint: UnitPoint(x: 0.34, y: 2.12)
            )
            .opacity(opacity)
        )
        .cornerRadius(17)
        .shadow(color: .black.opacity(0.25), radius: 2, x: 0, y: 4)
        .scaleEffect(scale)
        .rotationEffect(Angle(degrees: rotation))
    }
}

struct Constants {
  static let TextLightText: Color = Color(red: 0.52, green: 0.52, blue: 0.69)
  static let TextDarkText: Color = Color(red: 0.42, green: 0.42, blue: 0.54)
}
