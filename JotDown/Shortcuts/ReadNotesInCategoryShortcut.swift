//
//  ReadNotesInCategoryShortcut.swift
//  JotDown
//
//  Created by Neel Maddu on 10/23/25.
//

import AppIntents
import SwiftData

struct ReadNotesInCategoryShortcut: AppIntent {
    @AppDependency var modelContainer: ModelContainer

    static var title: LocalizedStringResource = "Read Notes in a Category"
    static var description = IntentDescription("Reads the notes from a selected active category.")

    @Parameter(
        title: "Category",
        optionsProvider: CategoryOptionsProvider()
    )
    var category: String

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let context = ModelContext(modelContainer)

        let thoughtDescriptor = FetchDescriptor<Thought>(
            predicate: #Predicate { $0.category.name == category }
        )

        do {
            let thoughts = try context.fetch(thoughtDescriptor)
            let noteContents = thoughts.map(\.content)

            guard !noteContents.isEmpty else {
                return .result(
                    dialog: IntentDialog("There are no notes in \(category).")
                )
            }

            let combined = noteContents.joined(separator: ", ")
            let spoken = "Here are your notes in \(category): \(combined)"

            return .result(
                dialog: IntentDialog(stringLiteral: spoken)
            )
        } catch {
            return .result(
                dialog: IntentDialog("I couldn’t read notes from \(category).")
            )
        }
    }
}

struct CategoryOptionsProvider: DynamicOptionsProvider {
    @AppDependency var modelContainer: ModelContainer

    func results() async throws -> [String] {
        let context = ModelContext(modelContainer)
        let descriptor = FetchDescriptor<Category>(
            predicate: #Predicate { $0.isActive == true }
        )

        do {
            let categories = try context.fetch(descriptor)
            return categories.map(\.name)
        } catch {
            return []
        }
    }
}
