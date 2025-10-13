//
//  FoundationModelSearchService.swift
//  JotDown
//
//  Created by Drew Mendelow on 10/13/25.
//
import FoundationModels
import Foundation

class FoundationModelSearchService {
    public static func getRelevantThoughts(query: String, in thoughts: [Thought]) async -> [Thought] {
        let session = FoundationModels.LanguageModelSession()
        
        //1. First try to identify the category of the query
        var uniqueCategories: [String] = []
        
        for thought in thoughts {
            let name = thought.category.name
            if (!uniqueCategories.contains(name)) {
                uniqueCategories.append(name)
            }
        }
        
        
        //Makes sure array is not empty
        if uniqueCategories.isEmpty {
            return []
        }
        
        do {
            //2. Determine the cateogry of the query
            let categoryPrompt = """
            Given the search query: "\(query)"
            And these available categories: [\(uniqueCategories.joined(separator: ", "))]
            
            Which category is most likely to contain thoughts related to this search query?
            Also, make a list of keywords from the query that can be used to find the most relevant thoguhts.
            Return only the exact category name from the list of categories above, a list of keywords from the query, and nothing else.
            """
            
            let queryResponse: QueryResponse = try await session.respond(to: categoryPrompt, generating: QueryResponse.self).content
            
            let selectedCategory = queryResponse.category.trimmingCharacters(in: .whitespacesAndNewlines)
            
            let categoryFilteredThoughts = thoughts.filter { $0.category.name.lowercased() == selectedCategory.lowercased() }
            
            
            //3. Filter thoughts based on queries
            var relevantThoughts: [Thought] = []
            
            for thought in categoryFilteredThoughts {
                for keyword in queryResponse.keywords {
                    if thought.content.lowercased().contains(keyword.lowercased()) {
                        relevantThoughts.append(thought)
                        break
                    }
                }
            }
            return relevantThoughts
            
        } catch {
            print("Error in Foundation Models search: \(error)")
            return []
        }
    }
}
