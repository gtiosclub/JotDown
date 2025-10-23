//
//  DashboardView.swift
//  JotDown
//
//  Created by Vamsi Putti on 10/14/25.
//

import SwiftUI
import SwiftData

struct DashboardView: View {
    @Query(filter: #Predicate<Category> { $0.isActive == true }) private var categories: [Category]
    @Query var thoughts: [Thought]
    @Binding var selectedTab: Int

    // two-column grid layout.
    let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 0),
        GridItem(.flexible(), spacing: 0)
    ]
    
    // Categories sorted by number of notes (descending)
    private var sortedCategories: [Category] {
        categories.sorted { lhs, rhs in
            let leftCount = thoughts.filter { $0.category == lhs }.count
            let rightCount = thoughts.filter { $0.category == rhs }.count
            return leftCount > rightCount
        }
    }

    // Formatter for the live date display
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM, E d"
        return formatter.string(from: Date.now)
    }

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 24) {
                // MARK: - Header Content
                HStack {
                    VStack(alignment: .leading) {
                        Text("jot")
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(.black.opacity(0.9))
                        Text("down")
                            .font(.system(size: 40, weight: .regular))
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    Button("edit") { }
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.black.opacity(0.7))
                        .font(.body.weight(.medium))
                        .padding(.horizontal, 15)
                        .padding(.vertical, 8)
                        .background(Color.gray.opacity(0.15))
                        .clipShape(Capsule())
                        .alignmentGuide(.bottom) {d in d[.bottom] }
                }
                .padding(.horizontal)

                // MARK: - Stats Content
                HStack {
                    VStack(alignment: .leading) {
                        Text("\(thoughts.count)")
                            .font(.title)
                            .fontWeight(.bold)
                        Text("notes")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    VStack(alignment: .leading) {
                        Text("\(categories.count)")
                            .font(.title)
                            .fontWeight(.bold)
                        Text("categories")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    Spacer()
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text(formattedDate)
                            .font(.subheadline)
                            .fontWeight(.bold)
                        Text("date")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal)

                // MARK: - Scrollable Grid
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 24) {
                        ForEach(sortedCategories) { category in
                            NavigationLink(destination: CategoryDashboardView(category: category)) {
                                NoteCategoryView(category: category)
                                    .scaleEffect(0.8)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 40)
                }
            }
            .padding(.top, 40)
        }
        CustomTabBar(selectedTab: $selectedTab)
    }
}

