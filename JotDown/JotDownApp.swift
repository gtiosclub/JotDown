//
//  JotDownApp.swift
//  JotDown
//
//  Created by Rahul on 9/22/25.
//

import AppIntents
import SwiftData
import SwiftUI
import WatchConnectivity

@main
struct JotDownApp: App {
    
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    let container: ModelContainer

    init() {
        let modelContainer = try! ModelContainer(
            for: User.self,
            Thought.self,
            Category.self,
            configurations: .init()
        )

        AppDependencyManager.shared.add(dependency: modelContainer)
        
        WatchSessionManager.shared.setup(context: ModelContext(modelContainer))

        self.container = modelContainer
    }

    var body: some Scene {
        WindowGroup {
            if hasCompletedOnboarding {
                ContentView()
                    .modelContainer(container)
            } else {
                OnboardingView()
            }
        }
    }
}
