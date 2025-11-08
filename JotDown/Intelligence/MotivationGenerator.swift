//
//  MotivationGenerator.swift
//  JotDown
//
//  Created by Aprameya Tirupati on 10/21/25.
//

import Foundation
import FoundationModels

class MotivationGenerator {
    private let session = LanguageModelSession(instructions: "You are a motivational coach. Generate a single short motivational prompt. Be friendly, brief and actionable.")

    static func generatePrompt(from recentThoughts: [Thought]) async -> String {
        let provider = MotivationGenerator()
        do {
            let sample = recentThoughts.prefix(5).map { $0.content.replacingOccurrences(of: "\n", with: " ") }

            let prompt: String
            if sample.isEmpty {
                prompt = "You are a motivational coach. Generate one short (<= 8 words) friendly and motivating prompt. Do not reference any specific prior notes. Return only the prompt, no explanation."
            } else {
                let context = sample.enumerated().map { "Thought \($0.offset + 1): \($0.element)" }.joined(separator: "\n")
                prompt = "You are a motivational coach. Given the following recent short notes:\n\n\(context)\n\nGenerate one short (<= 8 words) friendly and motivating prompt. Return only the prompt, no explanation. Do not ever return anything resembling a list or enumeration of ideas from the notes."
            }

            let response = try await provider.session.respond(to: prompt, generating: GeneratedPrompt.self)
            let trimmed = response.content.prompt.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmed.isEmpty {
                // if model fails
                return "Start writing — one idea can change your day!"
            }
            return trimmed
        } catch {
            print("MotivationGenerator error: \(error)")
            return "Start writing — one idea can change your day!"
        }
    }

    @Generable
    struct GeneratedPrompt {
        @Guide(description: "Short single-line motivational prompt (8 words or fewer)")
        var prompt: String
    }
}
