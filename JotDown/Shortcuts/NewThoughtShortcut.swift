//
//  NewThoughtShortcut.swift
//  JotDown
//
//  Created by Rahul on 9/30/25.
//

import AppIntents
import SwiftData

struct NewThoughtShortcut: AppIntent {
    @AppDependency var modelContainer: ModelContainer
        
    @Parameter(title: "Thought Content")
    var thoughtContent: String
    
    static var title: LocalizedStringResource = "New Thought"
    static var description: IntentDescription? = IntentDescription("Creates a new thought in JotDown")

    @MainActor
    func perform() async throws -> some IntentResult {
        let newThought = Thought(content: thoughtContent)
        let modelContext = ModelContext(modelContainer)
        
        do {
            let descriptor = FetchDescriptor<Category>()
            let categories = try modelContext.fetch(descriptor)
            
            try? await Categorizer()
                .categorizeThought(newThought, categories: categories)

            try? await EmotionClassifier()
                .classifyEmotion(newThought)

            modelContext.insert(newThought)
            return .result()
        } catch {
            print(error.localizedDescription)
            return .result()
        }
    }
}
