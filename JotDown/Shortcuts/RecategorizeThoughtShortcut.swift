//
//  RecategorizeThoughtShortcut.swift
//  JotDown
//
//  Created by Aadharsh Rajkumar on 9/30/25.
//

import AppIntents
import SwiftData

struct RecategorizeThoughtShortcut: AppIntent {
    static var title: LocalizedStringResource = "Recategorize Thought"

    @Parameter(title: "Thought")
    var thoughtContent: String

    @Parameter(title: "New Category")
    var newCategory: String

    @MainActor
    func perform() async throws -> some IntentResult {
        let container: ModelContainer
        if let shared = JotDownApp.sharedContainer {
            container = shared
        } else {
            container = try ModelContainer(for: User.self, Thought.self, Category.self)
        }

        let context = ModelContext(container)

        let fetchDescriptor = FetchDescriptor<Thought>(
            predicate: #Predicate { $0.content.localizedStandardContains(thoughtContent) }
        )

        let fetched = try context.fetch(fetchDescriptor)
        guard let thought = fetched.first else {
            return .result(value: "⚠️ Thought not found")
        }

        let categoryFetch = FetchDescriptor<Category>(
            predicate: #Predicate { $0.name == newCategory }
        )

        let category: Category
        if let existing = try context.fetch(categoryFetch).first {
            category = existing
        } else {
            category = Category(name: newCategory)
            context.insert(category)
        }

        thought.category = category

        do {
            try context.save()
        } catch {
            return .result(value: "⚠️ Failed to save: \(error.localizedDescription)")
        }

        return .result(value: "✅ Moved '\(thought.content)' to '\(category.name)'")
    }
}
