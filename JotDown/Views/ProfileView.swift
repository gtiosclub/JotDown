//
//  ProfileView.swift
//  JotDown
//
//  Created by Sankaet Cheemalamarri on 9/22/25.
//

import SwiftUI
import SwiftData

struct ProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Query var users: [User]
    private var user: User? { users.first }
    @Query var categories: [Category]
    @State private var showArchivedCategories: Bool = false
    @State private var isShowingAddCategoriesSheet: Bool = false
    @State private var newCategoryName: String = ""
    private var activeCategories: [Category] {
        categories.filter{$0.isActive}
        //        Category.dummyCategories.filter{$0.isActive}
    }
    private var inactiveCategories: [Category] {
        categories.filter{!$0.isActive}
        //        Category.dummyCategories.filter{!$0.isActive}
    }
    
    var body: some View {
        NavigationStack {
            Form {
                if let user = user {
                    @Bindable var bindableUser = user
                    
                    Section("Name") {
                        TextField("What is your name?", text: $bindableUser.name)
                            .lineLimit(1)
                    }
                    Section("Bio") {
                        TextField("Describe yourself...",
                                  text: $bindableUser.bio,
                                  axis: .vertical)
                            .lineLimit(5...10)
                            .multilineTextAlignment(.leading)
                    }
                }
                
                Section {
                    ForEach(activeCategories) { category in
                        Text(category.name)
                            .swipeActions(allowsFullSwipe: true) {
                                Button(role: .destructive, action: {
                                    withAnimation {
                                        category.isActive.toggle()
                                    }
                                }) {
                                    Text("Archive")
                                }
                            }
                    }
                    NavigationLink(destination: ArchivedCategoriesView(cateogries: inactiveCategories)) {
                        Text("\(inactiveCategories.count) inactive \(String(inactiveCategories.count).last == "1" ? "category" : "categories")")
                    }
                    .disabled(inactiveCategories.count == 0)
                } header: {
                    Text("Active Categories")
                        .foregroundColor(.gray)
                } footer: {
                    Text("Swipe left to archive a category.")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                Section {
                    //Sets the sheet to true to open the screen to add category
                    Button ("Add Custom Category") {
                        isShowingAddCategoriesSheet = true
                    }
                }
                Section {
                    Button("Generate Categories"){
                        Task{
                            do {
                                if let user = user {
                                    let generator = CategoryGenerator()
                                    let newCategories = try await generator.generateCategories(using: user.bio)
                                    for category in categories {
                                        category.isActive = false
                                    }
                                    for newCategory in newCategories {
                                        context.insert(newCategory)
                                    }
                                    
                                } else {
                                    print("Failed to generate categories, no user found")
                                }
                            } catch {
                                print("Failed to generate categories: \(error)")
                            }
                        }
                    }
                }
                
                
                
            }
            
            .navigationTitle("Profile")
            .toolbar {
                Button(role: .close) {
                    dismiss()
                }
            }
            //Presents the sheet to the user
            .sheet(isPresented: $isShowingAddCategoriesSheet) {
                NavigationStack {
                    Form {
                        Section("Category Name") {
                            TextField("i.e. Sports", text: $newCategoryName, axis: .vertical)
                                .submitLabel(.done)
                                .lineLimit(1...3)
                                .multilineTextAlignment(.leading)
                        }
                    }
                    .navigationTitle("New Category")
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") {
                                newCategoryName = ""
                                isShowingAddCategoriesSheet = false
                            }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Save") {
                                let trimmed = newCategoryName.trimmingCharacters(in: .whitespacesAndNewlines)
                                if !trimmed.isEmpty {
                                    //If the category is already present in inactive categories, the category is made active
                                    if let matching = inactiveCategories.first(where: { category in category.name.compare(trimmed, options: .caseInsensitive) == .orderedSame }) {
                                        matching.isActive = true
                                    }
                                    //If the category is new, it will be added to the list of active categories
                                    else if !activeCategories.contains(where: { category in category.name.lowercased() == trimmed.lowercased() }) {
                                        let category = Category(name: trimmed, isActive: true)
                                        context.insert(category)
                                    }
                                    newCategoryName = ""
                                    isShowingAddCategoriesSheet = false
                                } else {
                                    return
                                }
                            }
                            .disabled(newCategoryName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: User.self, Category.self, configurations: config)
        let context = container.mainContext
        let previewUser = User(name: "Preview User", bio: "Loves iOS dev")
        context.insert(previewUser)

        return ProfileView()
            .modelContainer(container)
}

