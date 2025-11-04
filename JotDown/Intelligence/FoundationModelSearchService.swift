//
//  FoundationModelSearchService.swift
//  JotDown
//
//  Created by Drew Mendelow on 10/13/25.
//
import FoundationModels
import Foundation

class FoundationModelSearchService {
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
            let session = LanguageModelSession()
            var relevantThoughtsContent: [String] = []
            var i: Int = 1
            do  {
                for thought in relevantThoughts{
                    let contents = "Thought \(i):\(thought.content)"
                    i+=1
                    relevantThoughtsContent.append(contents)
                }
                let queryResponsePrompt = """
                Given the search query "\(query)" and these are the available relevant thoughts ["\(relevantThoughtsContent.joined(separator: ", "))"]
                Infer the information in the thoughts to respond to the query. Try not to use the exact text from the toughts unless necessary.
                Summarize in one short sentence.

                Eg:
                Relevant thoughts: Dogs are cool, Cats are mid, Mouse are bad
                Query: Which animal is the best?
                Response: Dogs are the best animal.
                """
                let queryResponse = try await session.respond(to: queryResponsePrompt, generating: GeneratedResponse.self )
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
