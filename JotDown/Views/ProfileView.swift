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
                        if category.name == "Other" {
                            Text(category.name)
                                .foregroundColor(.gray)
                        } else {
                            Text(category.name)
                                .swipeActions(allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        withAnimation {
                                            category.isActive.toggle()
                                        }
                                    } label: {
                                        Text("Archive")
                                    }
                                }
                        }
                    }
                    NavigationLink(destination: ArchivedCategoriesView(cateogries: inactiveCategories)) {
                        Text("\(inactiveCategories.count) inactive \(inactiveCategories.count == 1 ? "category" : "categories")")
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
                    Button("Generate Categories"){
                        Task{
                            do {
                                if let user = user {
                                    let generator = CategoryGenerator()
                                    let newCategories = try await generator.generateCategories(using: user.bio)
                                    
                                    for category in categories {
                                        if category.name != "Other" {
                                            category.isActive = false
                                        }
                                    }
                                    
                                    let hasOther = categories.contains {$0.name == "Other"}
                                    for newCategory in newCategories {
                                        if (newCategory.name == "Other" && hasOther){
                                            continue
                                        }
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
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: User.self, configurations: config)
        let context = container.mainContext
        let previewUser = User(name: "Preview User", bio: "Loves iOS dev")
        context.insert(previewUser)

        return ProfileView()
            .modelContainer(container)
}

