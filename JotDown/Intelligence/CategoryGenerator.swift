//
//  CategoryGenerator.swift
//  JotDown
//
//  Created by Sankaet Cheemalamarri on 9/22/25.
//

import Playgrounds
import FoundationModels

class CategoryGenerator {
    let session = LanguageModelSession(instructions: """
        Generate catagories for a user depending on their interests in their bio. 
        """)
    func generateCategories(using bioText: String) async throws -> String{
        let prompt = """
            You are an intelligent categorization assistant.  
            The user will provide a short bio or sample notes about themselves, including their interests, daily activities, or things they jot down.  
            Your task is to carefully analyze this text and output exactly 5 broad but meaningful categories that best represent the themes or topics from the input.  
            The categories should be short, clear, and general enough to group multiple notes, but still personalized to the user’s context.  
            Avoid repeating the same idea in multiple categories.  

            Input (User Bio/Notes):
            """ + bioText + """
            Output (5 Categories):
            1.
            2.
            3.
            4.
            5.
            """
        let response =  try await session.respond(to: prompt).content
        print(response)
        return response
    }
}

#Playground {
    let gen = CategoryGenerator()
    let response = try await gen.generateCategories(using: "Anika is the founder of a popular chain of fusion restaurants blending Indian and Mediterranean flavors. With a background in culinary arts and business management, she has turned her passion for cooking into a thriving enterprise. In her free time, she teaches cooking classes and writes a blog on global cuisines.")
}
