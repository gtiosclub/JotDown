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

    @State private var selectedCategory: Category?
    @Namespace private var dashboardNamespace
    
    @Binding var categoryToSelect: Category? // <-- ADDED
    var onThoughtSelected: (Thought) -> Void
    
    // <-- ADDED INIT -->
    init(categoryToSelect: Binding<Category?>, onThoughtSelected: @escaping (Thought) -> Void = { _ in }) {
        self._categoryToSelect = categoryToSelect
        self.onThoughtSelected = onThoughtSelected
    }
    // <-- END ADDED INIT -->
    
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
        ZStack {
            // Main dashboard content when no category is selected
            if selectedCategory == nil {
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
                        .matchedGeometryEffect(id: "logo", in: dashboardNamespace) // <-- Tag logo
                        Spacer()
                        Button("edit") { }
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(.black.opacity(0.7))
                            .font(.body.weight(.medium))
                            .padding(.horizontal, 15)
                            .padding(.vertical, 8)
                            .background(Color.gray.opacity(0.15))
                            .clipShape(Capsule())
                            .alignmentGuide(.bottom) { d in d[.bottom] }
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
                        .matchedGeometryEffect(id: "notes-stat", in: dashboardNamespace)
                        Spacer()
                        VStack(alignment: .leading) {
                            Text("\(categories.count)")
                                .font(.title)
                                .fontWeight(.bold)
                            Text("categories")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .matchedGeometryEffect(id: "categories-stat", in: dashboardNamespace)
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
                        .matchedGeometryEffect(id: "date-stat", in: dashboardNamespace)
                    }
                    .padding(.horizontal)

                    // MARK: - Scrollable Grid
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 24) {
                            ForEach(sortedCategories) { category in
                                NoteCategoryView(category: category, namespace: dashboardNamespace)
                                    .scaleEffect(0.8)
                                    .onTapGesture {
                                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                            selectedCategory = category
                                        }
                                    }
                            }
                            .padding(.top, 25)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 40)
                }
                .padding(.top, 40)
                .transition(.opacity)
            }

            // Selected category overlay
            if let selectedCategory {
                CategoryDashboardView(
                    category: selectedCategory,
                    namespace: dashboardNamespace,
                    onThoughtTap: { thought in
                        onThoughtSelected(thought)
                    },
                    onDismiss: {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            self.selectedCategory = nil
                        }
                    }
                )
                .transition(.opacity)
            }
        }
        .animation(.spring(response: 0.45, dampingFraction: 0.8), value: selectedCategory)
        // <-- ADDED MODIFIER -->
        .onChange(of: categoryToSelect) { _, newCategory in
            if let newCategory {
                // Find the category instance from the query to ensure it's managed
                if let matchingCategory = categories.first(where: { $0.id == newCategory.id }) {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        selectedCategory = matchingCategory
                    }
                }
                // Reset the binding
                DispatchQueue.main.async {
                    categoryToSelect = nil
                }
            }
        }
        // <-- END ADDED MODIFIER -->
    }
}
