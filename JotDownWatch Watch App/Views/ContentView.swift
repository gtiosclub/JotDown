//
//  ContentView.swift
//  JotDownWatch Watch App
//
//  Created by Joseph Masson on 9/30/25.
//

import SwiftData
import SwiftUI

struct ContentView: View {
    
    @ObservedObject private var session = WatchSessionManager.shared
    
    var body: some View {
        NavigationStack {
            VStack() {
                Text("JotDown")
                    .font(Font.title.bold())
                Spacer(minLength: 20)
                NavigationLink() {
                    WatchThoughtsEntryView()
                } label: {
                    Label("Add Thought", systemImage: "plus.circle.fill")
                }.foregroundStyle(Color(.blue))
                
                
                HStack() {
                    NavigationLink() {
                        WatchThoughtsListView(title: "Thoughts")
                    } label: {
                        Label("Thoughts", systemImage: "list.bullet")
                    }
                    .frame(maxWidth: .infinity)

                    
                    NavigationLink() {
                        WatchSearchView()
                    } label: {
                        Image(systemName: "sparkle.magnifyingglass")
                            .font(Font.title3)
                    }.frame(width: 50)
                        .foregroundStyle(Color(.yellow))
                        .clipShape(Capsule())
                }
                
            }.padding()
                
        }.onAppear {
            session.requestThoughts()
        }
    }
}



#Preview {
    ContentView()
}
