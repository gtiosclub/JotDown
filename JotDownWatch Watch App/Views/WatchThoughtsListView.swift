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
    var title: String = ""
    var dataSource: [[String: Any]] {
        if title == "Thoughts" {
            return watchSession.thoughts
        } else {
            return watchSession.searchResults
        }
    }
    
    var body: some View {
        List {
            if dataSource.isEmpty {
                Text("No thoughts yet")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(Array(dataSource.enumerated()), id: \.offset) { _, item in
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
        .navigationTitle(title)
        .onAppear {
            if (title == "Thoughts") {
                watchSession.requestThoughts()
            }
        }
        
    }
}

#Preview {
    WatchThoughtsListView()
}
