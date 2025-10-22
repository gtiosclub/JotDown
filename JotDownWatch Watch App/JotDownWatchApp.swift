//
//  JotDownWatchApp.swift
//  JotDownWatch Watch App
//
//  Created by Joseph Masson on 9/30/25.
//

import SwiftUI

@main
struct JotDownWatch_Watch_AppApp: App {
    // start the WC as soon as the app starts
    init() {
        _ = WatchSessionManager.shared
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
