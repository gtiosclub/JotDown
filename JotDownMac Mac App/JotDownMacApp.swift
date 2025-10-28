//
//  JotDownMacApp.swift
//  JotDownMac Mac App
//
//  Created by Jeet Ajmani on 2025-10-23.
//

import SwiftUI

@main
struct JotDownMacApp: App {
    var body: some Scene {
        MenuBarExtra("JotDown", systemImage: "book.pages.fill") {
            ContentView()
        }.menuBarExtraStyle(.window)
    }
}
