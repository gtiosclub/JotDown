//
//  DashboardView.swift
//  JotDown
//
//  Created by Vamsi Putti on 10/14/25.
//

import SwiftUI
import SwiftData

struct DashboardView: View {
    @Query var thoughts: [Thought]
    @Query(filter: #Predicate<Category> { $0.isActive == true }) private var categories: [Category]
    @Environment(\.modelContext) private var modelContext

    @State private var selectedCategory: Category?
    @Namespace private var dashboardNamespace
    @State private var isSelecting = false
    @State private var selectedThoughts: Set<Thought> = []
    @State private var showVisualization = false

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

    var body: some View {
        ZStack {
            EllipticalGradient.primaryBackground
                .ignoresSafeArea()
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Main dashboard content when no category is selected
            if selectedCategory == nil {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // MARK: - Header Content
                        HStack {
                            Text("dashboard")
                                .titleStyle()
                                .matchedGeometryEffect(id: "logo", in: dashboardNamespace)
                        }
                        .padding(.horizontal)

                        // MARK: - Stats Content
                        HStack(spacing: 24) {
                            StatDisplay(value: "\(thoughts.count)", label: "notes")
                                .matchedGeometryEffect(id: "notes-stat", in: dashboardNamespace)

                            StatDisplay(value: "\(categories.count)", label: "categories")
                                .matchedGeometryEffect(id: "categories-stat", in: dashboardNamespace)

                            Spacer()

                            Button {
                                withAnimation(.spring) {
                                    showVisualization = true
                                }
                            } label: {
                                Label("Visualization", systemImage: "map")
                                    .imageScale(.large)
                                    .fontWeight(.semibold)
                                    .padding(6)
                            }
                            .labelStyle(.iconOnly)
                            .buttonStyle(.glassProminent)
                            .buttonBorderShape(.circle)
                            .tint(Color.buttonGradientStart)
                            .matchedTransitionSource(
                                id: "vis_button",
                                in: dashboardNamespace
                            )
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
                    .zIndex(1)
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
                .zIndex(1)
            }
        }
        .animation(.spring(response: 0.45, dampingFraction: 0.8), value: selectedCategory)
        .sheet(isPresented: $showVisualization) {
            NavigationStack {
                VisualizationView()
            }
            .navigationTransition(
                .zoom(sourceID: "vis_button", in: dashboardNamespace)
            )
            .interactiveDismissDisabled()
        }
        .onReceive(NotificationCenter.default.publisher(for: .openCategory)) { note in
                    guard
                        let id = note.object as? PersistentIdentifier,
                        let category = modelContext.model(for: id) as? Category
                    else {
                        return
                    }

                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        selectedCategory = category
                    }
                }
    }
}
