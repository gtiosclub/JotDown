//
//  FoundationModelSearchService.swift
//  JotDown
//
//  Created by Drew Mendelow on 10/13/25.
//
import FoundationModels
import Foundation

class FoundationModelSearchService {
    @MainActor
    static func getRelevantThoughts(query: String, in thoughts: [Thought]) async -> [Thought] {
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
    
    static func queryResponseGenerator(query: String, in relevantThoughts: [Thought]) async -> String {
        let instructions: String = """
                You are a personal search assistant meant to find answers to queries based on user notes.
                Given the search query and the list of relevant notes:
                Infer the information in the notes to respond to the query. Try not to use the exact text from the notes unless necessary. 
                DO NOT include information that is irrelevant to the query. 
                DO NOT mention the 'user' 
                Summarize in one short sentence.
                """
        let session = LanguageModelSession(instructions: instructions)
        var relevantThoughtsContent: [String] = []
        do  {
            for thought in relevantThoughts {
                relevantThoughtsContent.append(thought.content)
            }
            let queryResponsePrompt = """
                Search query: "\(query)" 
                Notes: ["\(relevantThoughtsContent.joined(separator: ", "))"]
                """
            let queryResponse = try await session.respond(to: queryResponsePrompt, generating: GeneratedResponse.self)
            
            return queryResponse.content.response
        } catch {
            print("Error in Foundation Models search: \(error)")
            return ""
        }
    }
}



//Generated Response Type
@Generable
struct GeneratedResponse {
    @Guide(description: "Clear, concise one sentence answer to the query, without any text related to how you found the answer.")
    var response: String
}

// Foundation Models session return type
@Generable
struct QueryResponse {
    @Guide(description: "The category selected from the category list")
    var category: String
    
    @Guide(description: "List of the most relevant keywords, each one word exactly with no white space, that are relevant to the query")
    var keywords: [String]
}
