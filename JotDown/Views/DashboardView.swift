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
    @State private var isSelecting = false
    @State private var selectedThoughts: Set<Thought> = []
    
    // two-column grid layout.
    let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 0),
        GridItem(.flexible(), spacing: 0)
    ]
    
    // Categories sorted by number of notes (descending)
    private var sortedCategories: [Category] {
        // Find "Other" category
        let otherCategory = categories.first { $0.name.lowercased() == "other" }
        
        // Get all other categories, filtering out "Other"
        let remainingCategories = categories.filter {
            let name = $0.name.lowercased()
            return name != "other"
        }
        
        // Sort the remaining categories by note count
        let sortedRemaining = remainingCategories.sorted { lhs, rhs in
            let leftCount = thoughts.filter { $0.category == lhs }.count
            let rightCount = thoughts.filter { $0.category == rhs }.count
            return leftCount > rightCount // Sort descending by count
        }
        
        // Combine the lists, putting "Other" first if it exists
        if let other = otherCategory {
            return [other] + sortedRemaining
        } else {
            return sortedRemaining
        }
    }

    // Consistent gradient background
    private var backgroundGradient: some View {
        EllipticalGradient(
            stops: [
                Gradient.Stop(color: Color(red: 0.94, green: 0.87, blue: 0.94), location: 0.00),
                Gradient.Stop(color: Color(red: 0.78, green: 0.85, blue: 0.93), location: 1.00),
            ],
            center: UnitPoint(x: 0.67, y: 0.46)
        )
        .ignoresSafeArea()
    }
    
    // Define the dark text color from the visual
    private var textColor: Color {
         Color(red: 0.35, green: 0.35, blue: 0.45)
    }

    var body: some View {
        ZStack {
            backgroundGradient
            
            // Main dashboard content when no category is selected
            if selectedCategory == nil {
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // MARK: - Header Content
                        HStack {
                            Text("dashboard")
                                .font(.system(size: 40, weight: .bold))
                                .foregroundColor(textColor)
                                .matchedGeometryEffect(id: "logo", in: dashboardNamespace)
                        }
                        .padding(.horizontal)

                        // MARK: - Stats Content
                        HStack(spacing: 24) {
                            VStack(alignment: .leading) {
                                Text("\(thoughts.count)")
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(textColor)
                                Text("notes")
                                    .font(.system(size: 15, weight: .regular))
                                    .foregroundColor(textColor.opacity(0.8))
                            }
                            .matchedGeometryEffect(id: "notes-stat", in: dashboardNamespace)
                            
                            VStack(alignment: .leading) {
                                Text("\(categories.count)")
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(textColor)
                                Text("categories")
                                    .font(.system(size: 15, weight: .regular))
                                    .foregroundColor(textColor.opacity(0.8))
                            }
                            .matchedGeometryEffect(id: "categories-stat", in: dashboardNamespace)
                        }
                        .padding(.horizontal)

                        // MARK: - Note Categories
                        
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
                        .padding(.horizontal)
                        .padding(.top, 40)
                        
                    }
                    .padding(.top, 40)
                    .padding(.horizontal)
                    .transition(.opacity)
                }
                
            }

            // Selected category overlay
            if let selectedCategory {
                CategoryDashboardView(
                    category: selectedCategory,
                    namespace: dashboardNamespace,
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
    }
}
