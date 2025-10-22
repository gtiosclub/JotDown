//
//  ContentView.swift
//  JotDownWatch Watch App
//
//  Created by Joseph Masson on 9/30/25.
//

import SwiftData
import SwiftUI

struct ContentView: View {

    var body: some View {
        NavigationStack {
            VStack {
                Text("JotDown")
                    .font(Font.title.bold())
                Spacer(minLength: 20)
                NavigationLink() {
                    WatchThoughtsEntryView()
                } label: {
                    Label("Add Thought", systemImage: "plus.circle.fill")
                }.foregroundStyle(Color(.blue))
                
                NavigationLink() {
                    WatchThoughtsListView()
                } label: {
                    Label("View Thoughts", systemImage: "list.bullet")
                }
            }.padding()
        }
    }
}



#Preview {
    ContentView()
}
