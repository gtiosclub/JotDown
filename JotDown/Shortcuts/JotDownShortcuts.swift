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
                    "New thought in \(.applicationName)",
                    "\(.applicationName) New thought"
                ],
                shortTitle: "New Thought",
                systemImageName: "square.and.pencil"
            ),
            AppShortcut(
                intent: ReadNotesInCategoryShortcut(),
                phrases: [
                    "Read thoughts from \(.applicationName)",
                    "\(.applicationName) Read thoughts"
                ],
                shortTitle: "Read Thoughts",
                systemImageName: "text.bubble"
            )
        ]
    }
}
