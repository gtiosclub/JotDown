//
//  CategorySelectionPage.swift
//  JotDown
//
//  Created by Adam Ress on 10/30/25.
//

import SwiftUI

struct CategorySelectionPage: View {
    
    @Binding var selectedCategories: [Category]
    @Binding var suggestedCategories: [Category]
    
    var body: some View {
        VStack {
            
            Spacer()
            
            // Note Text
            Text("What categories would you jot down?")
                .font(Font.custom("SF Pro", size: 24))
                .foregroundColor(Constants.TextLightText)
                .frame(maxWidth: .infinity, alignment: .topLeading)
                .padding(.bottom, 12)
            
            CategoryFlowLayout(selectedCategories: $selectedCategories, suggestedCategories: $suggestedCategories, textColor: .white, backgroundColor: Constants.TextDarkText, categories: selectedCategories)
                .frame(maxHeight: 120, alignment: .top)
                .padding(.bottom, 81)
                .animation(nil, value: suggestedCategories)
            
            // Subtext
            Text("Suggested")
              .font(
                Font.custom("SF Pro", size: 15)
              )
              .foregroundColor(Constants.TextLightText)
              .frame(maxWidth: .infinity, alignment: .topLeading)
    
            CategoryFlowLayout(selectedCategories: $selectedCategories, suggestedCategories: $suggestedCategories, textColor: Color(red: 0.49, green: 0.58, blue: 0.7), backgroundColor: .white.opacity(1), categories: suggestedCategories)
                .frame(maxHeight: 160, alignment: .top)
                .animation(nil, value: suggestedCategories)
            
            Spacer()
        }
        .padding(.horizontal, 38)
    }
}


//Custom Category flow layout
struct CategoryFlowLayout: View {
    
    @Binding var selectedCategories: [Category]
    @Binding var suggestedCategories: [Category]
    
    let textColor: Color
    let backgroundColor: Color
    let categories: [Category]
    
    let maxCharactersPerRow: Int = 30
    let horizontalSpacing: CGFloat = 8
    let verticalSpacing: CGFloat = 8
    
    var body: some View {
        VStack(alignment: .leading, spacing: verticalSpacing) {
            ForEach(groupedRows(), id: \.self) { row in
                HStack(spacing: horizontalSpacing) {
                    ForEach(row, id: \.self) { category in
                        Text(category.name)
                            .font(
                                Font.custom("SF Pro", size: 12)
                            )
                            .foregroundColor(textColor)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(backgroundColor)
                                    .shadow(color: .black.opacity(0.25), radius: 2, x: 0, y: 3)
                            )
                            .onTapGesture {
                                if selectedCategories.contains(category) {
                                    suggestedCategories.append(category)
                                    if let index = selectedCategories.firstIndex(of: category) {
                                        selectedCategories.remove(at: index)
                                    }
                                } else {
                                    selectedCategories.append(category)
                                    if let index = suggestedCategories.firstIndex(of: category) {
                                        suggestedCategories.remove(at: index)
                                    }
                                }
                            }
                    }
                    Spacer()
                }
            }
        }
    }
    
    private func groupedRows() -> [[Category]] {
        var rows: [[Category]] = []
        var currentRow: [Category] = []
        var currentCharacterCount = 0
        
        for category in categories {
            let nameLength = category.name.count
            
            // Check if new category would exceed the limit
            if currentCharacterCount + nameLength <= maxCharactersPerRow {
                currentRow.append(category)
                currentCharacterCount += nameLength
            } else {
                // Make new row
                if !currentRow.isEmpty {
                    rows.append(currentRow)
                }
                currentRow = [category]
                currentCharacterCount = nameLength
            }
        }
        
        // Add final row.
        if !currentRow.isEmpty {
            rows.append(currentRow)
        }
        
        return rows
    }
}
