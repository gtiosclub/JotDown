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
    
    @Query private var users: [User]
    @Query private var categories: [Category]
    private var user: User? { users.first }
//    @Query var categories: [Category]
    
    @State private var bio: String = ""
    @State private var showArchivedCategories: Bool = false
    private var activeCategories: [Category] {
        Category.dummyCategories.filter{$0.isActive}
    }
    private var inactiveCategories: [Category] {
        Category.dummyCategories.filter{!$0.isActive}
    }
    
    var body: some View {
        NavigationStack {
            Form {
                if let user = user {
                    Section("Username") {
                        TextField("Username", text: Binding(
                            get: { user.name },
                            set: {user.bio = $0}
                        ))
                    }
                    Section("Bio") {
                        TextField("Describe yourself...", text: Binding(
                            get: { user.bio },
                            set: { user.bio = $0 }
                        ))
                    }
                    Button("Generate Categories"){
                        Task{
                            do{
                                let generator = CategoryGenerator()
                                try await generator.generateCategories(using: user.bio)
                            } catch {
                                print("Failed to generate categories: \(error)")
                            }
                        }
                    }
                    Section("Active Categories") {
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
                    }
                }
                
            }
            
            .navigationTitle("Profile")
            .toolbar {
                Button("Save") {
                    try? context.save()
                    dismiss()
                }
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
