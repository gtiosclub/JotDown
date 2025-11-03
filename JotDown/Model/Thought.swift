//
//  Thought.swift
//  JotDown
//
//  Created by Sankaet Cheemalamarri on 9/22/25.
//

import Foundation
import SwiftData

@Model
class Thought {
    var dateCreated: Date
    var content: String
    var category: Category
    var vectorEmbedding: [Double]
        
    init(content: String) {
        self.dateCreated = Date()
        self.content = content
        self.category = Category(name: "Dummy", categoryDescription: "Dummy Description")
        self.vectorEmbedding = RAGSystem().getEmbedding(for: content)
    }
}
