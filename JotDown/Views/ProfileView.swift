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
        categories
            .filter{$0.isActive}
            .sorted { lhs, rhs in
                if lhs.name == "Other" {return false}
                if rhs.name == "Other" {return true}
                return lhs.name < rhs.name
            }
    }
    private var inactiveCategories: [Category] {
        categories.filter{!$0.isActive}
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
                            .foregroundColor(category.name == "Other" ? .gray : .primary)
                            .swipeActions (allowsFullSwipe: true){
                                 if category.name != "Other" {
                                     Button(role: .destructive) {
                                         withAnimation {
                                             category.isActive.toggle()
                                         }
                                     } label: {
                                         Label("Archive", systemImage: "archivebox.fill")
                                     }
                                 }
                            }
                    }
                    NavigationLink(destination: ArchivedCategoriesView(cateogries: inactiveCategories)) {
                        Text("^[\(inactiveCategories.count) inactive category](inflect=true)")
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

