//
//  Thought.swift
//  JotDown
//
//  Created by Sankaet Cheemalamarri on 9/22/25.
//

import Foundation
import SwiftData

enum Emotion: String, Codable {
    case anger
    case fear
    case sadness
    case calm
    case strong
    case happiness
    case unknown
}

@Model
class Thought {
    var dateCreated: Date
    var content: String
    var category: Category
    var vectorEmbedding: [Double]
    var emotion: Emotion?

    init(content: String) {
        self.dateCreated = Date()
        self.content = content
        self.category = Category(name: "Dummy", categoryDescription: "Dummy Description")
        self.vectorEmbedding = RAGSystem().getEmbedding(for: content)
        self.emotion = .unknown
    }
}
