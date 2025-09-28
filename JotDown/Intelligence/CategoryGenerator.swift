//
//  CategoryGenerator.swift
//  JotDown
//
//  Created by Sankaet Cheemalamarri on 9/22/25.
//

import FoundationModels

class CategoryGenerator {
    let session = LanguageModelSession(instructions: "Generate categories for a user depending on their interests in their bio.")
    
    let instructionPrompt = "Generate an appropriate, general interest categories array based on the following bio text. The categories should be clear and general enough to group multiple notes, but still personalized to the user’s context. Crucially avoid repeating the same idea in multiple categories. Here is the bio:"
    
    
    
    func generateCategories(using bioText: String) async throws -> [Category] {
        
        let prompt =  instructionPrompt + "\"\(bioText)\"."
        let response =  try await session.respond(
            to: prompt,
            generating: GeneratedCategoryArray.self
        )
        
        
        //iterate through response
        
        var categoryArray: [Category] = []
        
        for category in response.content.categories {
            let newCategory = Category(name: category.name, isActive: true)
            categoryArray.append(newCategory)
        }
        
        return categoryArray
    }
    
    
    //guarantees formatting to be proper structure.
    @Generable
    struct GeneratedCategoryArray {
        @Guide(description: "Array of categories that best represent the themes or topics from the input.")
        var categories: [GeneratedCategory]
    }
    
    @Generable
    struct GeneratedCategory {
        @Guide(description: "Clear, concise one word category name")
        var name: String
    }
}
