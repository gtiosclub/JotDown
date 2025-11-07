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
    @Query private var allCategories: [Category]
    @Environment(\.modelContext) private var context
    
    // Selection logic
    @State private var isSelecting: Bool = false
    @State private var selectedThoughtIDs: Set<Thought.ID> = []
    
    init(category: Category, namespace: Namespace.ID, onDismiss: @escaping () -> Void = {}) {
        self.category = category
        self.namespace = namespace
        self.onDismiss = onDismiss
        
        let localCategoryName = category.name
        let localCategoryID = category.id
        
        self._thoughts = Query(filter: #Predicate<Thought> { thought in
            thought.category.name == localCategoryName
        })
        
        self._allCategories = Query(filter: #Predicate<Category> {
            $0.isActive && $0.id != localCategoryID
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
    
    // Text color
    private var textColor: Color {
         Color(red: 0.35, green: 0.35, blue: 0.45)
    }
    
    // Sort thoughts by date
    private var sortedThoughts: [Thought] {
            thoughts.sorted { $0.dateCreated > $1.dateCreated }
    }
    
    // Other active categories for the "Move" menu
    private var otherActiveCategories: [Category] {
        allCategories.filter { $0.id != category.id && $0.isActive }
    }
    
    var body: some View {
        ZStack {
            backgroundGradient
            
            ScrollView {
                VStack(alignment: .leading, spacing: 0){

                    // MARK: - Back Button / Title
                    Button(action: {
                        onDismiss()
                        isSelecting = false
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundStyle(textColor)
                            .contentShape(Rectangle())
                        Text(category.name.lowercased())
                            .font(.system(size: 40, weight: .bold))
                            .foregroundStyle(textColor)
                            .matchedGeometryEffect(id: "\(category.id)-title", in: namespace)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 40)
                    
                    // MARK: - Stats & Select / Cancel & Controls
                    HStack(alignment: .center) {
                        if isSelecting {
                            // --- Selection Mode ---
                            Button(action: {
                                withAnimation(.spring) {
                                    isSelecting = false
                                    selectedThoughtIDs.removeAll()
                                }
                            }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "chevron.left")
                                    Text("cancel")
                                }
                                .font(.system(size: 20, weight: .light))
                                .foregroundStyle(textColor)
                            }
                            
                            Spacer()
                            
                            selectionControls
                            
                        } else {
                            // --- Normal Mode ---
                            VStack(alignment: .center) {
                                 Text("\(thoughts.count)")
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundStyle(textColor)
                                Text("notes")
                                    .font(.system(size: 15, weight: .regular))
                                    .foregroundStyle(textColor.opacity(0.8))
                            }
                            .padding(.leading, 4)
                            .padding(.top, 10)
                            .matchedGeometryEffect(id: "\(category.id)-count", in: namespace)
                            
                            Spacer()
                            
                            Button {
                                withAnimation(.spring) {
                                    isSelecting = true
                                }
                            } label: {
                                Text("select")
                                    .font(.system(size: 12, weight: .regular))
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 12)
                                    .background(Color(red: 0.75, green: 0.75, blue: 0.9))
                                    .clipShape(Capsule())
                            }
                            .transaction { $0.animation = .spring }
                            .matchedGeometryEffect(id: "select-move-button", in: namespace)
                            .matchedGeometryEffect(id: "select-delete-button", in: namespace)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 8)
                    .frame(height: 40)

                    
                    // MARK: - Notes Grid
                    LazyVGrid(columns: columns, spacing: 16){
                        ForEach(sortedThoughts, id: \.id) { thought in
                            let isSelected = selectedThoughtIDs.contains(thought.id)
                            
                            CategoryItemView(
                                thought: thought,
                                isSelecting: isSelecting,
                                isSelected: isSelected
                            )
                            .aspectRatio(1.0, contentMode: .fit)
                            .opacity(isSelecting && !isSelected ? 0.6 : 1.0)
                            .matchedGeometryEffect(id: thought.id, in: namespace)
                            .onTapGesture {
                                if isSelecting {
                                    withAnimation(.bouncy) {
                                        if isSelected {
                                            selectedThoughtIDs.remove(thought.id)
                                        } else {
                                            selectedThoughtIDs.insert(thought.id)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                    .padding(.top, 16)
                }
            }
            .padding(.horizontal)
        
        }
    }
    
    // MARK: - Selection Controls View
    @ViewBuilder
    private var selectionControls: some View {
        let hasSelection = !selectedThoughtIDs.isEmpty
        let buttonOpacity = hasSelection ? 1.0 : 0.5
        
        HStack(spacing: 6) {
            // --- MOVE BUTTON ---
            Menu {
                ForEach(otherActiveCategories) { newCategory in
                    Button(newCategory.name) {
                        moveSelectedThoughts(to: newCategory)
                    }
                }
            } label: {
                HStack(spacing: 4) {
                    Text("move")
                    Image(systemName: "arrow.right")
                }
                .font(.system(size: 12, weight: .regular))
                .foregroundStyle(.white.opacity(buttonOpacity))
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Color(red: 0.75, green: 0.75, blue: 0.9).opacity(buttonOpacity))
                .clipShape(Capsule())
            }
            .disabled(!hasSelection)
            .matchedGeometryEffect(id: "select-move-button", in: namespace)
        
            // --- DELETE BUTTON ---
            Button {
                deleteSelectedThoughts()
            } label: {
                HStack(spacing: 4) {
                    Text("delete")
                    Image(systemName: "trash")
                }
                .font(.system(size: 12, weight: .regular))
                .foregroundStyle(.white.opacity(buttonOpacity))
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Color(red: 0.75, green: 0.75, blue: 0.9).opacity(buttonOpacity))
                .clipShape(Capsule())
            }
            .disabled(!hasSelection)
            .matchedGeometryEffect(id: "select-delete-button", in: namespace)
        }
        .transaction { $0.animation = .spring }
    }
    
    // MARK: - Helper Functions
    
    private func moveSelectedThoughts(to newCategory: Category) {
        let thoughtsToMove = thoughts.filter { selectedThoughtIDs.contains($0.id) }
        
        for thought in thoughtsToMove {
            thought.category = newCategory
        }
        
        withAnimation(.spring) {
            isSelecting = false
            selectedThoughtIDs.removeAll()
        }
    }
    
    private func deleteSelectedThoughts() {
        let thoughtsToDelete = thoughts.filter { selectedThoughtIDs.contains($0.id) }
        
        for thought in thoughtsToDelete {
            context.delete(thought)
        }
        
        withAnimation(.spring) {
            isSelecting = false
            selectedThoughtIDs.removeAll()
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

#Preview {
    let container = try! ModelContainer(
        for: Thought.self, Category.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    
    let category = Category(name: "Recipes", categoryDescription: "test", isActive: true)
    let category2 = Category(name: "Adventure", categoryDescription: "test", isActive: true)
    container.mainContext.insert(category)
    container.mainContext.insert(category2)
    
    let thoughts = [
        "i just realized i could make ice cream mochi but with mango sticky rice inside!!! First I need to figure out how to find good...",
        "sriracha + tuna + miso soup??",
        "lemon cake with matcha icing sounds so yummmmmm",
        "Gochujang butter cookies..."
    ].map { content -> Thought in
        let thought = Thought(content: content)
        thought.category = category
        container.mainContext.insert(thought)
        return thought
    }
    
    try? container.mainContext.save()
    
    return NavigationStack {
        NamespaceReader { ns in
            CategoryDashboardView(category: category, namespace: ns, onDismiss: {})
        }
    }
    .modelContainer(container)
}
