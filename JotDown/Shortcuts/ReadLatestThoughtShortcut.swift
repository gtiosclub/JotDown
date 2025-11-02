//
//  ReadLatestThoughtShortcut.swift
//  JotDown
//
//  Created by Neel Maddu on 10/24/25.
//

import AppIntents
import SwiftData

struct ReadLatestThoughtShortcut: AppIntent {
    @AppDependency var modelContainer: ModelContainer

    static var title: LocalizedStringResource = "Read Latest Thought"
    static var description = IntentDescription("Reads your most recent thought from JotDown.")

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let context = ModelContext(modelContainer)

        let thoughtDescriptor = FetchDescriptor<Thought>(
            sortBy: [SortDescriptor(\.dateCreated, order: .reverse)]
        )

        do {
            let thoughts = try context.fetch(thoughtDescriptor)

            guard let latest = thoughts.first else {
                return .result(
                    dialog: IntentDialog("You don’t have any thoughts yet.")
                )
            }

            let date = formattedDate(latest.dateCreated)
            let spoken = "Your most recent thought, created on \(date), says: \(latest.content)"

            return .result(
                dialog: IntentDialog(stringLiteral: spoken)
            )
        } catch {
            return .result(
                dialog: IntentDialog("I couldn’t read your latest thought.")
            )
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
