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
    let container: ModelContainer

    init() {
        let configuration = ModelConfiguration(groupContainer: .identifier("group.com.gtiosclub.JotDown"))
        
        do {
            let modelContainer = try ModelContainer(
                for: User.self, Thought.self, Category.self,
                configurations: configuration
            )

            AppDependencyManager.shared.add(dependency: modelContainer)
            self.container = modelContainer
            
        } catch {
            fatalError("Failed to initialize model container: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(container)
        }
    }
}
