//
//  CategoryDashboardView.swift
//  JotDown
//
//  Created by Vamsi Putti on 10/14/25.
//

import SwiftUI
import SwiftData

// TO DO: IMPLEMENT THE CATEGORY DASHBOARD SCREEN HERE

struct CategoryDashboardView: View {
    
    let category: Category
    
    @Query private var thoughts: [Thought]
    
    init(category: Category) {
        self.category = category
        let categoryName = category.name
        self._thoughts = Query(filter: #Predicate<Thought> { thought in
            thought.category.name == categoryName
        })
    }
    
    private let columns: [GridItem] = [ GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
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
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 16){
                        ForEach(thoughts) { thought in
                            CategoryItemView(thought: thought)
                                .aspectRatio(1.0, contentMode: .fit)
                        }
                    }
                    .padding()
                }
            }
        }
    }
    private var headerView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: -6) {
                    Text("jot")
                        .font(.system(size: 36, weight: .semibold))
                        .foregroundColor(.black)
                    Text("down")
                        .font(.system(size: 36, weight: .regular))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 8) {
                    Button("edit") {}
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.black)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 6)
                        .background(Color.white)
                        .clipShape(Capsule())
                        .shadow(color: .black.opacity(0.1), radius: 2, y: 1)
                        .alignmentGuide(.bottom) {d in d[.bottom] }
                }
            }
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(thoughts.count)")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.black)
                    Text("notes")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.gray)
                }
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text(Date.now.formatted(
                        Date.FormatStyle()
                            .month(.abbreviated)
                            .weekday(.abbreviated)
                            .day()
                    ))
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.gray)
                }
            }
            
            Text(category.name)
                .font(.system(size: 48, weight: .semibold))
                .foregroundColor(.black)
                .padding(.top, 12)
                .frame(maxWidth: .infinity, alignment: .center)
            
        }
    }
}



//#Preview {
//    let config = ModelConfiguration(isStoredInMemoryOnly: true)
//    let container = try! ModelContainer(for: Thought.self, configurations: config)
//    DashboardView()
//}

// Setup preview container
let previewContainer: ModelContainer = {
    let container = try! ModelContainer(
        for: Thought.self,
             Category.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )

    // Create and insert a category into the managed context
    let managedCategory = Category(name: "Recipes")
    container.mainContext.insert(managedCategory)

    // Create thoughts and assign the relationship after init
    let seedContents = [
        "Try mango sticky rice mochi",
        "Test a chocolate chip cookie recipe",
        "Finish ISyE homework"
    ]

    for content in seedContents {
        let t = Thought(content: content)
        t.category = managedCategory
        container.mainContext.insert(t)
    }

    try? container.mainContext.save()

    return container
}()

// Fetch the managed category for preview
private func fetchPreviewCategory(from container: ModelContainer) -> Category {
    let context = container.mainContext
    let descriptor = FetchDescriptor<Category>()
    if let found = try? context.fetch(descriptor).first {
        return found
    } else {
        // Fallback: create one if fetch fails
        let fallback = Category(name: "Recipes")
        context.insert(fallback)
        try? context.save()
        return fallback
    }
}

// Preview block
#Preview {
    let category = fetchPreviewCategory(from: previewContainer)
    return NavigationStack {
        CategoryDashboardView(category: category)
    }
    .modelContainer(previewContainer)
}
