//
//  ReadThoughtsByCategoryShortcut.swift
//  JotDown
//
//  Created by Charles on 10/09/25.
//

import AppIntents
import SwiftData

struct ReadThoughtsByCategoryShortcut: AppIntent {

    @Parameter(title: "Category Name")
    var categoryName: String

    static var title: LocalizedStringResource = "Read Thoughts by Category"
    static var description: IntentDescription? = IntentDescription("Reads all thoughts from a specific category.")

    @MainActor
    func perform() async throws -> some ReturnsValue<String> {
        let configuration = ModelConfiguration(groupContainer: .identifier("group.com.gtiosclub.JotDown"))
        
        guard let modelContainer = try? ModelContainer(for: User.self, Thought.self, Category.self, configurations: configuration) else {
            return .result(value: "Error: Could not access the app's data.")
        }
        
        let modelContext = ModelContext(modelContainer)
        
        do {
            let predicate = #Predicate<Thought> { thought in
                thought.category.name.localizedStandardContains(categoryName)
            }
            
            let descriptor = FetchDescriptor<Thought>(predicate: predicate, sortBy: [SortDescriptor(\.dateCreated, order: .reverse)])
            let thoughts = try modelContext.fetch(descriptor)
            
            if thoughts.isEmpty {
                return .result(value: "No thoughts found in the category '\(categoryName)'.")
            }

            let thoughtContents = thoughts.map { $0.content }
            let combinedString = "Here are your thoughts for '\(categoryName)':\n- " + thoughtContents.joined(separator: "\n- ")
            
            return .result(value: combinedString)
        } catch {
            return .result(value: "Sorry, I couldn't fetch your thoughts. Please try again.")
        }
    }
}
