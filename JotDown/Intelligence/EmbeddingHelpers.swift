//
//  EmbeddingHelpers.swift
//  JotDown
//
//  Created by Stepan Kravtsov on 9/30/25.
//

import Foundation
import NaturalLanguage

public class RAGSystem {
    private let embeddingModel: NLEmbedding
    init() {
        guard let model = NLEmbedding.wordEmbedding(for: .english) else {
            fatalError("Unable to load embedding model")
        }
        self.embeddingModel = model
    }
    func getEmbedding(for text: String) -> [Double] {
        let words = text.lowercased().components(separatedBy: .whitespacesAndNewlines)
        let embeddings = words.compactMap { embeddingModel.vector(for: $0) }
        return average(embeddings)
    }
    
    private func cosineSimilarity(_ v1: [Double], _ v2: [Double]) -> Double {
        guard v1.count == v2.count else { return 0 }
        let dotProduct = zip(v1, v2).map(*).reduce(0, +)
        let magnitude1 = sqrt(v1.map { $0 * $0 }.reduce(0, +))
        let magnitude2 = sqrt(v2.map { $0 * $0 }.reduce(0, +))
        return dotProduct / (magnitude1 * magnitude2)
    }
    private func average(_ vectors: [[Double]]) -> [Double] {
        guard !vectors.isEmpty else { return [] }
        let sum = vectors.reduce(into: Array(repeating: 0.0, count: vectors[0].count)) { result, vector in
            for (index, value) in vector.enumerated() {
                result[index] += value
            }
        }
        return sum.map { $0 / Double(vectors.count) }
    }
    func sortThoughts(thoughts: [Thought], query: String, limit: Int = 5) -> [Thought] {
        let queryEmbedding = getEmbedding(for: query)
        let sortedThoughts =  thoughts.sorted {
            cosineSimilarity($0.vectorEmbedding, queryEmbedding) > cosineSimilarity($1.vectorEmbedding, queryEmbedding)
        }.prefix(limit)
        return Array(sortedThoughts)
    }
    
}
