//
//  EmotionClassifier.swift
//  JotDown
//
//  AI-based emotion classification for thoughts
//

import FoundationModels
import Foundation
import SwiftUI
import SwiftData

class EmotionClassifier {
    let session = FoundationModels.LanguageModelSession()

    func classifyEmotion(_ thought: Thought) async throws {
        do {
            let prompt = """
                You are an expert emotion classifier whose task is to identify the primary emotion conveyed in a given thought or note.

                Emotions (choose exactly one):
                - anger: Feelings of frustration, irritation, annoyance, or rage
                - fear: Feelings of anxiety, worry, nervousness, or dread
                - sadness: Feelings of sorrow, melancholy, disappointment, or grief
                - calm: Feelings of peace, relaxation, contentment, or serenity
                - strong: Feelings of confidence, determination, power, or motivation
                - happiness: Feelings of joy, excitement, gratitude, or delight

                Thought: "\(thought.content)"

                Task:
                - Analyze the emotional tone and content of the thought.
                - Choose the single most dominant emotion that best represents the thought.
                - If the thought is neutral or unclear, choose "calm" as the default.

                Output rule:
                Respond only with the exact emotion name (anger, fear, sadness, calm, strong, or happiness) — no explanations or extra text.
                """

            let emotionResponse = try await session.respond(to: prompt)

            let emotionName = emotionResponse.content.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)

            switch emotionName {
            case "anger":
                thought.emotion = .anger
            case "fear":
                thought.emotion = .fear
            case "sadness":
                thought.emotion = .sadness
            case "calm":
                thought.emotion = .calm
            case "strong":
                thought.emotion = .strong
            case "happiness":
                thought.emotion = .happiness
            default:
                print("EmotionClassifier: Unknown emotion '\(emotionName)', defaulting to calm")
                thought.emotion = .calm
            }

        } catch {
            print("EmotionClassifier failed with error: \(error). Assigning 'unknown'.")
            thought.emotion = .unknown
        }
    }
}
