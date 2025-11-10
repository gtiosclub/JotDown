//
//  CategoriesExamplePage.swift
//  JotDown
//
//  Created by Adam Ress on 10/30/25.
//

import SwiftUI

struct CategoriesExamplePage: View {
    
    @Binding var currentPage: Int
    @Binding var pageHeight: Int
    
    var body: some View {
        VStack {
            
            Spacer()
            
            // Note Text
            Text("Organize all your thoughts")
              .font(Font.custom("SF Pro", size: 22))
              .foregroundColor(Constants.TextLightText)
              .padding(.horizontal)
            
            Spacer()
            
            VStack(spacing: 20) {
                HStack(spacing: 20) {
                    VStack {
                        ZStack {
                            NotecardExample(title: "Crush part, disco theme!", opacity: 0.9, rotation: 10, width: 100, paddingLeading: -3, paddingTop: 3)

                                .padding(.leading, 20)
                            NotecardExample(title: "Big Little day was sooooo fun my little was so suprised!", opacity: 0.95, rotation: -10, width: 90, paddingLeading: -3, paddingTop: 3)
                                .padding(.trailing, 30)
                            NotecardExample(title: "Initiation on Sunday!")
                                .padding(.top, 70)
                        }
                        // Subtext
                        Text("Greek Life")
                            .font(
                                Font.custom("SF Pro", size: 15)
                            )
                            .foregroundColor(Color(red: 0.52, green: 0.52, blue: 0.69))
                            .padding(.top, 5)
                            .padding(.bottom, -7)
                        
                        Text("10 notes")
                          .font(Font.custom("SF Pro", size: 8))
                          .multilineTextAlignment(.center)
                          .foregroundColor(Constants.TextDarkText)
                          .frame(width: 37, height: 15, alignment: .center)
                    }
                    
                    Spacer()
                    
                    VStack {
                        ZStack {
                            NotecardExample(title: "I need to make more food for next wednesday four our nursing home event", opacity: 0.9, rotation: 10, width: 100, paddingLeading: -3, paddingTop: 3)

                                .padding(.leading, 20)
                            NotecardExample(title: "Show up early on Saturday for more training", opacity: 0.95, rotation: -10, width: 90, paddingLeading: -3, paddingTop: 3)
                                .padding(.trailing, 30)
                            NotecardExample(title: "Today I met the sweetest elderly lady and she gave me such good life advise and so much wisdom, I hope she’s doing well")
                                .padding(.top, 70)
                        }
                        // Subtext
                        Text("Volunteering")
                            .font(
                                Font.custom("SF Pro", size: 15)
                            )
                            .foregroundColor(Color(red: 0.52, green: 0.52, blue: 0.69))
                            .padding(.top, 5)
                            .padding(.bottom, -7)
                        
                        Text("11 notes")
                          .font(Font.custom("SF Pro", size: 8))
                          .multilineTextAlignment(.center)
                          .foregroundColor(Constants.TextDarkText)
                          .frame(width: 37, height: 15, alignment: .center)
                    }
                }
                .padding(.horizontal, 30)
                
                
                HStack(spacing: 20) {
                    VStack {
                        ZStack {
                            NotecardExample(title: "Swimming in the Atlantic is so much better than the pacific in my option the water feels clearer", opacity: 0.9, rotation: 10, width: 100, paddingLeading: -3, paddingTop: 3)

                                .padding(.leading, 20)
                            NotecardExample(title: "Dad wants to go on a hike sometime this month,", opacity: 0.95, rotation: -10, width: 90, paddingLeading: -3, paddingTop: 3)
                                .padding(.trailing, 30)
                            NotecardExample(title: "Bucket List\n- Grand Canyon\n- Seattle\n- Go to all 50 states\n- Visit all national parks")
                                .padding(.top, 70)
                        }
                        // Subtext
                        Text("Adventures")
                            .font(
                                Font.custom("SF Pro", size: 15)
                            )
                            .foregroundColor(Color(red: 0.52, green: 0.52, blue: 0.69))
                            .padding(.top, 5)
                            .padding(.bottom, -7)
                        
                        Text("13 notes")
                          .font(Font.custom("SF Pro", size: 8))
                          .multilineTextAlignment(.center)
                          .foregroundColor(Constants.TextDarkText)
                          .frame(width: 37, height: 15, alignment: .center)
                    }
                    
                    Spacer()
                    
                    VStack {
                        ZStack {
                            NotecardExample(title: "Pet sit neighbor’s dog next Tuesday from 4 - 7pm", opacity: 0.9, rotation: 10, width: 100, paddingLeading: -3, paddingTop: 3)

                                .padding(.leading, 20)
                            NotecardExample(title: "I think Bud is running low on dog food", opacity: 0.95, rotation: -10, width: 90, paddingLeading: -3, paddingTop: 3)
                                .padding(.trailing, 30)
                            NotecardExample(title: "Take Bud to the vet 5/12")
                                .padding(.top, 70)
                        }
                        // Subtext
                        Text("Dog")
                            .font(
                                Font.custom("SF Pro", size: 15)
                            )
                            .foregroundColor(Color(red: 0.52, green: 0.52, blue: 0.69))
                            .padding(.top, 5)
                            .padding(.bottom, -7)
                        
                        Text("8 notes")
                          .font(Font.custom("SF Pro", size: 8))
                          .multilineTextAlignment(.center)
                          .foregroundColor(Constants.TextDarkText)
                          .frame(width: 37, height: 15, alignment: .center)
                    }
                }
                .padding(.horizontal, 30)
            }
            .padding()
            .padding(.top, -40)
            
            Spacer()
        }
        .padding(.top, 50)
    }
}

struct NotecardExample: View {
    var title: String
    var scale: Double = 1.0
    var opacity: Double = 1.0
    var rotation: Double = 0
    var width: Int = 117
    var paddingLeading: Int = 5
    var paddingTop: Int = 7
    
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Text(title)
                .font(
                    Font.custom("SF Pro", size: 8)
                )
                .multilineTextAlignment(.leading)
                .foregroundColor(Constants.TextDarkText)
                .padding(.top, CGFloat(paddingTop))
                .padding(.leading, CGFloat(paddingLeading))
        }
        .padding([.leading, .top], 12)
        .padding(.trailing, 3)
        .frame(width: CGFloat(width), height: 119, alignment: .topLeading)
        .background(
            Color.white
            .opacity(opacity)
        )
        .cornerRadius(17)
        .shadow(color: .black.opacity(0.25), radius: 2, x: 0, y: 4)
        .scaleEffect(scale)
        .rotationEffect(Angle(degrees: rotation))
    }
}
