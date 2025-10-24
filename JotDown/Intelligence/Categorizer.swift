//
//  Categorizer.swift
//  JotDown
//
//  Created by Sankaet Cheemalamarri on 9/22/25.
//

import FoundationModels
import Foundation
import SwiftUI
import SwiftData

class Categorizer {
    let session = FoundationModels.LanguageModelSession()
    
    func categorizeThought(_ thought: Thought, categories: [Category]) async throws {
        let filteredCategories = categories.filter{ $0.isActive }
        
        let prompt = """
            You are an expert classifier whose task is to assign a given “thought” to exactly one category from a provided list.

            Categories:
            \(filteredCategories.map { "- \($0.name): \($0.categoryDescription)" }.joined(separator: "\n"))

            Thought: "\(thought.content)"

            Task:
            - Choose the single most relevant category that best fits the meaning or intent of the thought.
            - Base your choice only on the meaning and context of the thought.

            Output rule:
            Respond only with the exact name of the chosen category — no explanations or extra text.
            """
        
        print(prompt)
        
        let categoryName = try await session.respond(to: prompt)
        var categoryIndex: Int?
        for (index, category) in filteredCategories.enumerated() where category.name.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) == categoryName.content.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) {
            categoryIndex = index
        }
        guard let index = categoryIndex else {
            return
        }
        
        thought.category = categories[index]
    }
}
