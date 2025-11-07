//
//  RecategorizeThoughtShortcut.swift
//  JotDown
//
//  Created by Aadharsh Rajkumar on 9/30/25.
//

import AppIntents
import SwiftData

struct RecategorizeThoughtShortcut: AppIntent {
    @AppDependency var modelContainer: ModelContainer

    static var title: LocalizedStringResource = "Recategorize Thought"
    static var description = IntentDescription("Moves an existing thought into a new category.")

    @Parameter(title: "Thought")
    var thoughtContent: String

    @Parameter(title: "New Category")
    var newCategory: String

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let context = ModelContext(modelContainer)

        let fetchDescriptor = FetchDescriptor<Thought>(
            predicate: #Predicate { $0.content.localizedStandardContains(thoughtContent) }
        )

        guard let thought = try context.fetch(fetchDescriptor).first else {
            return .result(dialog: "I couldn’t find any thought matching \(thoughtContent).")
        }

        let categoryFetch = FetchDescriptor<Category>(
            predicate: #Predicate { $0.name == newCategory }
        )

        guard let category = try context.fetch(categoryFetch).first else {
            return .result(
                dialog: IntentDialog("The category '\(newCategory)' does not exist.")
            )
        }

        thought.category = category

        do {
            try context.save()
            return .result(
                dialog: IntentDialog("Moved '\(thought.content)' to '\(category.name)'.")
            )
        } catch {
            return .result(
                dialog: IntentDialog("I couldn’t save the change — \(error.localizedDescription).")
            )
        }
    }
}

