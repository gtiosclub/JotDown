//
//  CategoryDashboardView.swift
//  JotDown
//
//  Created by Vamsi Putti on 10/14/25.
//

import SwiftUI
import SwiftData

struct CategoryDashboardView: View {
    let category: Category
    let namespace: Namespace.ID
    var onDismiss: () -> Void
    
    @Query private var thoughts: [Thought]
    
    init(category: Category, namespace: Namespace.ID, onDismiss: @escaping () -> Void = {}) {
        self.category = category
        self.namespace = namespace
        self.onDismiss = onDismiss
        let categoryName = category.name
        self._thoughts = Query(filter: #Predicate<Thought> { thought in
            thought.category.name == categoryName
        })
    }
    
    // Grid layout for notes
    private let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
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
    
    // Sort thoughts by date
    private var sortedThoughts: [Thought] {
            thoughts.sorted { $0.dateCreated > $1.dateCreated }
    }
    
    var body: some View {
        ZStack {
            backgroundGradient
            
            ScrollView {
                VStack(alignment: .leading, spacing: 0){
                    
                    // MARK: - Header / Navigation
                    Button(action: onDismiss) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 32, weight: .bold))
                            
                            Text(category.name.lowercased())
                                .font(.system(size: 40, weight: .bold))
                                .matchedGeometryEffect(id: "\(category.id)-title", in: namespace)
                        }
                        .foregroundColor(textColor)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 40)

                    
                    // MARK: - Stats & Select Button
                    HStack(alignment: .bottom) {
                        VStack(alignment: .leading) {
                             Text("\(thoughts.count)")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(textColor)
                            Text("notes")
                                .font(.system(size: 15, weight: .regular))
                                .foregroundColor(textColor.opacity(0.8))
                        }
                        .padding(.leading, 4)
                        .matchedGeometryEffect(id: "\(category.id)-count", in: namespace)
                        
                        Spacer()
                        
                        Button("select") {
                            // TODO: Implement Select functionality
                        }
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color(red: 0.75, green: 0.75, blue: 0.9))
                        .clipShape(Capsule())
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 8)

                    
                    // MARK: - Notes Grid
                    LazyVGrid(columns: columns, spacing: 16){
                        ForEach(sortedThoughts) { thought in
                            CategoryItemView(thought: thought)
                                .aspectRatio(1.0, contentMode: .fit)
                                .matchedGeometryEffect(id: thought.id, in: namespace)
                        }
                    }
                    .padding()
                    .padding(.top, 16)
                }
            }
            .padding(.horizontal)
        }
    }
}

struct NamespaceReader<Content: View>: View {
    @Namespace private var ns
    let content: (Namespace.ID) -> Content
    init(@ViewBuilder content: @escaping (Namespace.ID) -> Content) {
        self.content = content
    }
    var body: some View { content(ns) }
}
