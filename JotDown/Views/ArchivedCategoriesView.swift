//
//  ArchivedCategoriesView.swift
//  JotDown
//
//  Created by Степан Кравцов on 9/25/25.
//

import SwiftUI

struct ArchivedCategoriesView: View {
    var cateogries: [Category]
    var body: some View {
        if cateogries.isEmpty {
            Text("No archived categories")
        }
        Form {
            Section {
                ForEach(cateogries) {category in
                    Text(category.name)
                        .foregroundStyle(.secondary)
                        .swipeActions(allowsFullSwipe: true) {
                            Button(action: {
                                withAnimation {
                                    category.isActive.toggle()
                                }
                            }) {
                                Text("Activate")
                            }
                        }
                }
            } footer: {
                Text("Swipe left to activate a category.")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
        }
        
    }
}

