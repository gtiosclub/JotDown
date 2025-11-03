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
    
    private let columns: [GridItem] = [ GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    private static var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM, E d" // Match DashboardView's format
        return formatter
    }()
    
    private var sortedThoughts: [Thought] {
            thoughts.sorted { $0.dateCreated > $1.dateCreated }
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.gray.opacity(0.15), Color.white],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 0){
                headerView
                    .padding(.horizontal, 24)
                    .padding(.top, 40)
                Text(category.name)
                    .font(.system(size: 48, weight: .semibold))
                    .foregroundColor(.black)
                    .padding(.top, 12)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .matchedGeometryEffect(id: "\(category.id)-title", in: namespace)
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 16){
                        ForEach(sortedThoughts) { thought in
                            CategoryItemView(thought: thought)
                                .aspectRatio(1.0, contentMode: .fit)
                                .matchedGeometryEffect(id: thought.id, in: namespace)
                        }
                    }
                    .padding()
                }
            }
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 24) {
            // --- Header Content (Logo & Button) ---
            HStack {
                VStack(alignment: .leading) {
                    Text("jot")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.black.opacity(0.9))
                    Text("down")
                        .font(.system(size: 40, weight: .regular))
                        .foregroundColor(.gray)
                }
                .matchedGeometryEffect(id: "logo", in: namespace)

                Spacer()

                Button("back") { onDismiss() }
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.black.opacity(0.7))
                    .font(.body.weight(.medium))
                    .padding(.horizontal, 15)
                    .padding(.vertical, 8)
                    .background(Color.gray.opacity(0.15))
                    .clipShape(Capsule())
                    .alignmentGuide(.bottom) {d in d[.bottom] }
                    .matchedGeometryEffect(id: "header-button", in: namespace)
            }
            
            // --- Stats Content (Notes, Category, Date) ---
            HStack {
                VStack(alignment: .leading) {
                    Text("\(thoughts.count)")
                        .font(.title)
                        .fontWeight(.bold)
                    Text("notes")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .matchedGeometryEffect(id: "notes-stat", in: namespace)

                Spacer()

                VStack {}
                    .matchedGeometryEffect(id: "categories-stat", in: namespace)
                    .opacity(0) // Make it invisible

                Spacer()
                Spacer()
                Spacer()

                VStack(alignment: .trailing) {
                    Text(Date.now, formatter: Self.dateFormatter)
                        .font(.subheadline)
                        .fontWeight(.bold)
                    Text("date")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .matchedGeometryEffect(id: "date-stat", in: namespace)
            }
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

//#Preview {
//    // Make SwiftData container to test visualization
//    let container = try! ModelContainer(
//        for: Thought.self, Category.self,
//        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
//    )
//    
//    // Create a fake category
//    let category = Category(name: "Recipes")
//    container.mainContext.insert(category)
//    
//    // Add sample thoughts, and assign them to the fake category
//    let thoughts = [
//        "Try mango sticky rice mochi",
//        "Test a chocolate chip cookie recipe",
//        "Finish ISyE homework",
//        "Play some video games"
//    ].map { content -> Thought in
//        let thought = Thought(content: content)
//        thought.category = category
//        container.mainContext.insert(thought)
//        return thought
//    }
//    
//    try? container.mainContext.save()
//    
//    // Return the preview view
//    return NavigationStack {
//        NamespaceReader { ns in
//            CategoryDashboardView(category: category, namespace: ns)
//        }
//    }
//    .modelContainer(container)
//}

