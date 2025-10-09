//
//  Thought.swift
//  JotDown
//
//  Created by Sankaet Cheemalamarri on 9/22/25.
//

import Foundation
import SwiftData
import NaturalLanguage

@Model
class Thought {
    var dateCreated: Date
    var content: String
    var category: Category
    var vectorEmbedding: [Double]
        
    init(content: String) {
        self.dateCreated = Date()
        self.content = content
        self.category = Category(name: "Dummy")
        guard let model = NLEmbedding.wordEmbedding(for: .english) else {
                    fatalError("Unable to load embedding model")
        }
        let words = content.components(separatedBy: .whitespacesAndNewlines)
        let embeddings = words.compactMap { model.vector(for: $0) }
        let averageEmbedding = average(embeddings)
        self.vectorEmbedding = averageEmbedding
    }
}
