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
                        .font(.custom("SF Pro", size: 48))
                        .fontWeight(.medium)
                        .lineSpacing(48 * 0.5)
                        .tracking(-48 * 0.011)
                        .foregroundColor(Color(red: 55/255, green: 55/255, blue: 55/255));
                    
                    Text("down")
                           .font(.custom("SF Pro", size: 48))
                           .fontWeight(.medium)
                           .tracking(-48 * 0.011)
                           .lineSpacing(48 * 0.5)
                           .foregroundColor(Color(red: 197/255, green: 197/255, blue: 197/255));
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

#Preview {
    // Make SwiftData container to test visualization
    let container = try! ModelContainer(
        for: Thought.self, Category.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    
    // Create a fake category
    let category = Category(name: "Recipes")
    container.mainContext.insert(category)
    
    // Add sample thoughts, and assign them to the fake category
    let thoughts = [
        "Try mango sticky rice mochi",
        "Test a chocolate chip cookie recipe",
        "Finish ISyE homework",
        "Play some video games"
    ].map { content -> Thought in
        let thought = Thought(content: content)
        thought.category = category
        container.mainContext.insert(thought)
        return thought
    }
    
    try? container.mainContext.save()
    
    // Return the preview view
    return NavigationStack {
        CategoryDashboardView(category: category)
    }
    .modelContainer(container)
}
