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
        let prompt = "Using this array of categories: [\(categories.enumerated().map { $0.element.name }.joined(separator: ", "))], which category do you think the thought '\(thought.content)' fits best in? If unsure of which category it fits in, please return 'Other'. Return only the name of the best category of fit and nothing else."
        
        let categoryName = try await session.respond(to: prompt)
        var categoryIndex: Int?
        for (index, category) in categories.enumerated() where category.name.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) == categoryName.content.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) {
            categoryIndex = index
        }
        guard let index = categoryIndex else {
            return
        }
        
        thought.category = categories[index]
    }
}
