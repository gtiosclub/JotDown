//
//  ContentView.swift
//  JotDownWatch Watch App
//
//  Created by Jeet Ajmani on 10/14/25.
//

import SwiftData
import SwiftUI

struct WatchThoughtsListView: View {
    
    @ObservedObject private var watchSession = WatchSessionManager.shared
    
    var body: some View {
        // TODO: Add functionality to display thoughts from iOS app
        List {
            if watchSession.thoughts.isEmpty {
                Text("No thoughts yet")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(Array(watchSession.thoughts.enumerated()), id: \.offset) { _, item in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(item["content"] as? String ?? "Unknown Thought")
                            .font(.body)
                            .truncationMode(.tail)
                        
//                        if let dateStr = item["dateCreated"] as? String {
//                            Text(Self.formatDate(dateStr))
//                                .font(.caption2)
//                                .foregroundStyle(.gray)
//                        }
                    }
                    .padding(.vertical, 2)
                }
            }
        }
        .navigationTitle("Thoughts")
        .onAppear {
            watchSession.requestThoughts()
        }
    }
}

#Preview {
    WatchThoughtsListView()
}
