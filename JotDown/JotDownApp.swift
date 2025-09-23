//
//  JotDownApp.swift
//  JotDown
//
//  Created by Rahul on 9/22/25.
//

import SwiftData
import SwiftUI

@main
struct JotDownApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: [Thought.self, Category.self])
        }
    }
}
