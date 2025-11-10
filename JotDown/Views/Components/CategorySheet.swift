import SwiftUI
import SwiftData

struct CategorySheet: View {
    @Environment(\.modelContext) private var context
    var isAddCategory: Bool

    @Binding var category: Category
    @Binding var newCategoryName: String
    @Binding var newCategoryDescription: String
    @Binding var isPresented: Bool

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

        self._newCategoryName = .constant(category.wrappedValue.name)
        self._newCategoryDescription = .constant(category.wrappedValue.categoryDescription)
        self.activeCategories = []
        self.inactiveCategories = []

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

                            if let matching = inactiveCategories.first(where: { category in
                                category.name.compare(trimmedName, options: .caseInsensitive) == .orderedSame
                            }) {
                                matching.isActive = true
                            } else if !activeCategories.contains(where: { category in
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
