//
//  JotDownShortcuts.swift
//  JotDown
//
//  Created by Rahul on 9/30/25.
//

import AppIntents

struct JotDownShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        return [
            AppShortcut(
                intent: NewThoughtShortcut(),
                phrases: [
                    "New thought in \(.applicationName)"
                ],
                shortTitle: "New Thought",
                systemImageName: "square.and.pencil"
            ),
            AppShortcut(
                intent: RecategorizeThoughtShortcut(),
                phrases: [
                    "Recategorize thought in \(.applicationName)",
                    "Change category in \(.applicationName)",
                    "Move note in \(.applicationName)"
                ],
                shortTitle: "Recategorize Thought",
                systemImageName: "arrow.triangle.branch"
            )
        ]
    }
}

