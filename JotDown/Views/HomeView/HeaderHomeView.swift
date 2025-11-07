//
//  HeaderHomeView.swift
//  JotDown
//
//  Created by Drew Mendelow on 10/14/25.
//

import SwiftUI
import SwiftData

struct HeaderHomeView: View {
    @Binding var thoughtInput: String
    @Binding var selectedIndex: Int?
    @Binding var isSubmitting: Bool
    @Binding var isSelecting: Bool
    @FocusState var isFocused: Bool
    
    let addThought: () async throws -> Void
    
    var body: some View {
        if (!isSelecting) {
            HStack {
                JotDownLogo()
                
                Spacer()
                
                VStack {
                    Spacer()
                    
                    HStack(spacing: 13) {
                        Button {
                            isSelecting = true
                            isFocused = false
                        } label: {
                            Text("select")
                                .font(Font.custom("SF Pro", size: 15)
                                    .weight(.medium))
                                .foregroundColor(.white)
                        }
                        //                    .buttonBorderShape(.capsule)
                        //                    .buttonStyle(.glass)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(
                            LinearGradient(
                                stops: [
                                    Gradient.Stop(color: Color(red: 0.61, green: 0.63, blue: 1), location: 0.00),
                                    Gradient.Stop(color: Color(red: 0.43, green: 0.44, blue: 0.81), location: 1.00),
                                ],
                                startPoint: UnitPoint(x: 0.5, y: 0),
                                endPoint: UnitPoint(x: 0.5, y: 1)
                            )
                        )
                        .disabled(selectedIndex == 0)
                        .opacity(selectedIndex == 0 ? 0.6 : 1.0)
                        .cornerRadius(25)
                        
                        if isSubmitting {
                            ProgressView()
                        } else {
                            Button {
                                isFocused = false
                                if selectedIndex != nil && selectedIndex != 0 {
                                    selectedIndex = 0;
                                } else {
                                    Task {
                                        try await addThought()
                                    }
                                }
                            } label: {
                                Image(systemName: selectedIndex != 0 ? "plus" : "checkmark")
                                    .fontWeight(.light)
                                    .font(.system(size: 30))
                                    .foregroundStyle(Color(red: 109/255, green: 134/255, blue: 166/255))
                                    .padding(.vertical, 10)
                                    .frame(width: 30, height: 30)
                            }
                        }
                    }
                }
                
                
            }
            .padding(.horizontal, 30)
            .padding(.vertical, 0)
            .frame(height: 100)
            .onChange(of: selectedIndex) {
                if selectedIndex == 0 {
                    isSelecting = false
                }
            }
        } else {
            HStack {
                VStack {
                    Spacer()
                    
                    HStack(spacing: 13) {
                        Button {
                            isSelecting = false
                        } label: {
                            Image(systemName: "chevron.left")
                            Text("cancel")
                        }
                        .font(Font.custom("SF Pro", size: 20))
                        .foregroundColor(Constants.TextLightText)
                        .padding(0)
                        .frame(maxWidth: .infinity, alignment: .center)
                        
                        Spacer()
                        
                        Button {
                            // todo
                        } label: {
                            Text("edit")
                                .font(Font.custom("SF Pro", size: 15)
                                    .weight(.medium))
                                .foregroundColor(.white)
                            Image(systemName: "pencil")
                                .foregroundColor(.white)
                                .font(.system(size: 15, weight: .medium))
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(
                            LinearGradient(
                                stops: [
                                    Gradient.Stop(color: Color(red: 0.61, green: 0.63, blue: 1), location: 0.00),
                                    Gradient.Stop(color: Color(red: 0.43, green: 0.44, blue: 0.81), location: 1.00),
                                ],
                                startPoint: UnitPoint(x: 0.5, y: 0),
                                endPoint: UnitPoint(x: 0.5, y: 1)
                            )
                        )
                        //                    .disabled(selectedIndex == 0)
                        //                    .opacity(selectedIndex == 0 ? 0.6 : 1.0)
                        .cornerRadius(25)
                        
                        Button {
                            // todo
                        } label: {
                            Text("delete")
                                .font(Font.custom("SF Pro", size: 15)
                                    .weight(.medium))
                                .foregroundColor(.white)
                            Image(systemName: "trash")
                                .foregroundColor(.white)
                                .font(.system(size: 15, weight: .medium))
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(
                            LinearGradient(
                                stops: [
                                    Gradient.Stop(color: Color(red: 0.61, green: 0.63, blue: 1), location: 0.00),
                                    Gradient.Stop(color: Color(red: 0.43, green: 0.44, blue: 0.81), location: 1.00),
                                ],
                                startPoint: UnitPoint(x: 0.5, y: 0),
                                endPoint: UnitPoint(x: 0.5, y: 1)
                            )
                        )
                        //                    .disabled(selectedIndex == 0)
                        //                    .opacity(selectedIndex == 0 ? 0.6 : 1.0)
                        .cornerRadius(25)
                    }
                }
                
                
            }
            .padding(.horizontal, 30)
            .padding(.vertical, 0)
            .frame(height: 100)
            .onChange(of: selectedIndex) {
                if selectedIndex == 0 {
                    isSelecting = false
                }
            }
        }
    }
}

struct Constants {
    static let TextLightText: Color = Color(red: 0.52, green: 0.52, blue: 0.69)
}
