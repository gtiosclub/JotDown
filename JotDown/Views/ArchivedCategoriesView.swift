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
        }
    }
}

