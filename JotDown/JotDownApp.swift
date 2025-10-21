//
//  JotDownApp.swift
//  JotDown
//
//  Created by Rahul on 9/22/25.
//

import AppIntents
import SwiftData
import SwiftUI

@main
struct JotDownApp: App {
    static var sharedContainer: ModelContainer!

    let container: ModelContainer

    init() {
        let modelContainer = try! ModelContainer(
            for: User.self,
            Thought.self,
            Category.self,
            configurations: .init()
        )

        AppDependencyManager.shared.add(dependency: modelContainer)

        self.container = modelContainer
        Self.sharedContainer = modelContainer
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(container)
                .onAppear {
                    let testThought = Thought(content: "Finish homework")
                    testThought.category = Category(name: "Assignments")
                    print("Test thought created:", testThought.content, "with category:", testThought.category.name)
                }
        }
    }
}
