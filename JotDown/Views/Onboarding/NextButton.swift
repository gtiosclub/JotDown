//
//  NextButton.swift
//  JotDown
//
//  Created by Adam Ress on 10/28/25.
//

import SwiftUI

struct ContinueButton: View {
    
    @Binding var currentPage: Int
    @Binding var pageHeight: Int
    
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    
    var generateCategories: () async -> Void
    var onFinishOnboarding: () -> Void
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                currentPage += 1

                if currentPage >= 1 {
                    pageHeight = 800
                } else {
                    pageHeight = 437
                }
            }
            
            Task {
                //Finished prompt page
                if (currentPage == 4) {
                    await generateCategories()
                }
                
                //End onboarding
                if (currentPage == 5) {
                    hasCompletedOnboarding = true
                    onFinishOnboarding()
                    print("Onboarding ended")
                }
            }
            
        }) {
            Image(systemName: "chevron.right")
                .bold()
                .foregroundColor(.white)
                .font(.system(size: 20, weight: .medium))
                .frame(width: 68, height: 68)
                .background(
                    Circle()
                        .fill(
                            //Was gradient. Now just one color, but could be gradient in future.
                            LinearGradient(
                                stops: [
                                    Gradient.Stop(color: Color(red: 0.61, green: 0.63, blue: 1), location: 0.00),
                                ],
                              startPoint: UnitPoint(x: 0.5, y: 0),
                              endPoint: UnitPoint(x: 0.5, y: 1)
                            )
                        )
                )
        }
        .shadow(color: .black.opacity(0.25), radius: 5.25, x: 0, y: 4)
        .overlay(
            RoundedRectangle(cornerRadius: 46)
            .inset(by: 0.5)
            .stroke(Color(red: 0.78, green: 0.78, blue: 0.97).opacity(0.11), lineWidth: 1)
        )

    }
}

struct BackButton: View {
    
    @Binding var currentPage: Int
    @Binding var pageHeight: Int
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                if (currentPage > 0) {
                    currentPage -= 1
                }

                if currentPage >= 1 {
                    pageHeight = 800
                } else {
                    pageHeight = 437
                }
            }
        }) {
            Image(systemName: "chevron.left")
                .bold()
                .foregroundColor(.white)
                .font(.system(size: 20, weight: .medium))
                .frame(width: 68, height: 68)
                .background(
                    Circle()
                        .fill(
                            //Was gradient. Now just one color, but could be gradient in future.
                            LinearGradient(
                                stops: [
                                    Gradient.Stop(color: Color(red: 0.61, green: 0.63, blue: 1), location: 0.00),
                                ],
                              startPoint: UnitPoint(x: 0.5, y: 0),
                              endPoint: UnitPoint(x: 0.5, y: 1)
                            )
                        )
                )
        }
        .shadow(color: .black.opacity(0.25), radius: 5.25, x: 0, y: 4)

    }
}
