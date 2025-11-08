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
    @State private var isShowingEditCategoriesSheet: Bool = false
    @State private var newCategoryName: String = ""
    @State private var newCategoryDescription: String = ""
    @State private var selectedCategory: Category? = nil
    
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
            VStack {
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
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    isShowingEditCategoriesSheet = true
                                    selectedCategory = category
                                }
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
                //Presents the sheet to the user allowing them to add their custom categories
                .sheet(isPresented: $isShowingAddCategoriesSheet) {
                    CategorySheet(
                        isAddCategory: true,
                        newCategoryName: $newCategoryName,
                        newCategoryDescription: $newCategoryDescription,
                        isPresented: $isShowingAddCategoriesSheet,
                        activeCategories: activeCategories,
                        inactiveCategories: inactiveCategories
                    )
                }
                .sheet(isPresented: $isShowingEditCategoriesSheet) {
                    if let binding = Binding($selectedCategory) {
                        CategorySheet(
                            isAddCategory: false,
                            category: binding,
                            isPresented: $isShowingEditCategoriesSheet)
                    }
                }
            }
        }
    }
}

// Struct to present the add category sheet to users
private struct CategorySheet: View {
    @Environment(\.modelContext) private var context
    var isAddCategory: Bool

    @Binding var category: Category
    @Binding var newCategoryName: String
    @Binding var newCategoryDescription: String
    @Binding var isPresented: Bool
    
    // These are passed in from ProfileView so the logic can mirror existing behavior
    var activeCategories: [Category]
    var inactiveCategories: [Category]
    
    @State private var editCategoryDescription: String

    init(
        isAddCategory: Bool,
        category: Binding<Category>,
        isPresented: Binding<Bool>
    ) {
        self.isAddCategory = isAddCategory
        self._category = category
        self._isPresented = isPresented
        
        // These are unused in edit mode
        self._newCategoryName = .constant(category.wrappedValue.name)
        self._newCategoryDescription = .constant(category.wrappedValue.categoryDescription)
        self.activeCategories = []
        self.inactiveCategories = []
        
        // Default state
        self._editCategoryDescription = State(initialValue: category.wrappedValue.categoryDescription)
    }
    
    init(
        isAddCategory: Bool,
        newCategoryName: Binding<String>,
        newCategoryDescription: Binding<String>,
        isPresented: Binding<Bool>,
        activeCategories: [Category],
        inactiveCategories: [Category]
    ) {
        self.isAddCategory = isAddCategory
        self._newCategoryName = newCategoryName
        self._newCategoryDescription = newCategoryDescription
        self._isPresented = isPresented
        self.activeCategories = activeCategories
        self.inactiveCategories = inactiveCategories
        
        // These are unused in add mode
        self._category = .constant(Category(name: "", categoryDescription: ""))
        self._editCategoryDescription = State(initialValue: "")
    }

    var body: some View {
        NavigationStack {
            Form {
                if isAddCategory {
                    Section("Category Name") {
                        TextField("i.e. Sports", text: $newCategoryName, axis: .vertical)
                            .submitLabel(.done)
                            .lineLimit(1...3)
                            .multilineTextAlignment(.leading)
                    }
                }
                Section(isAddCategory ? "Category Description" : "Edit Description") {
                    TextField("i.e. Sports activities, events, and fitness tasks.", text: isAddCategory ? $newCategoryDescription : $editCategoryDescription, axis: .vertical)
                        .submitLabel(.done)
                        .lineLimit(1...3)
                        .multilineTextAlignment(.leading)
                }
            }
            .navigationTitle(isAddCategory ? "New Category" : category.name)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        newCategoryName = ""
                        newCategoryDescription = ""
                        isPresented = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    let isSaveDisabled = isAddCategory ? newCategoryName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty : editCategoryDescription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || editCategoryDescription.trimmingCharacters(in: .whitespacesAndNewlines) == category.categoryDescription.trimmingCharacters(in: .whitespacesAndNewlines)
                    Button("Save") {
                        if isAddCategory {
                            let trimmedName = newCategoryName.trimmingCharacters(in: .whitespacesAndNewlines)
                            let trimmedDescription = newCategoryDescription.trimmingCharacters(in: .whitespacesAndNewlines)
                            guard !trimmedName.isEmpty else { return }
                            guard !trimmedDescription.isEmpty else { return }
                            
                            // If the category exists in inactive, activate it
                            if let matching = inactiveCategories.first(where: { category in
                                category.name.compare(trimmedName, options: .caseInsensitive) == .orderedSame
                            }) {
                                matching.isActive = true
                            }
                            // If it's a new unique category, insert it as active
                            else if !activeCategories.contains(where: { category in
                                category.name.lowercased() == trimmedName.lowercased()
                            }) {
                                let category = Category(name: trimmedName, categoryDescription: trimmedDescription, isActive: true)
                                context.insert(category)
                            }
                            
                            newCategoryName = ""
                            newCategoryDescription = ""
                        } else {
                            guard !editCategoryDescription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
                            
                            category.categoryDescription = editCategoryDescription.trimmingCharacters(in: .whitespacesAndNewlines)
                            
                            editCategoryDescription = ""
                        }
                        
                        isPresented = false
                    }
                    .tint(isSaveDisabled ? .secondary : .blue)
                    .disabled(isSaveDisabled)
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

