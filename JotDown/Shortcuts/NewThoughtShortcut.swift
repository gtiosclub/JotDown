//
//  NewThoughtShortcut.swift
//  JotDown
//
//  Created by Rahul on 9/30/25.
//

import AppIntents

struct NewThoughtShortcut: AppIntent {
    static var title: LocalizedStringResource = "New Thought"
    static var description: IntentDescription? = IntentDescription("Creates a new thought in JotDown")

    @MainActor
    func perform() async throws -> some IntentResult {
        // TODO: Prompts the user and creates a new Thought
        return .result()
    }
}
