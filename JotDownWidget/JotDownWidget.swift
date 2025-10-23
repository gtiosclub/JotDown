//
//  JotDownWidget.swift
//  JotDownWidget
//
//  Created by Shreyas Shrestha on 10/23/25.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date())
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let entry = SimpleEntry(date: Date())
        let timeline = Timeline(entries: [entry], policy: .never)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
}

struct JotDownWidgetEntryView: View {
    var entry: Provider.Entry

    var body: some View {
        ZStack {
            Color(.systemBackground)
            
            VStack(spacing: 12) {
                Image(systemName: "note.text.badge.plus")
                    .font(.system(size: 40))
                    .foregroundColor(.blue)
                
                Text("New Thought")
                    .font(.headline)
                
                Text("Tap to jot down")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
        }
        .widgetURL(URL(string: "jotdown://new")!)
    }
}

@main
struct JotDownWidget: Widget {
    let kind: String = "JotDownWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            JotDownWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("JotDown")
        .description("Create a new thought.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

#Preview(as: .systemSmall) {
    JotDownWidget()
} timeline: {
    SimpleEntry(date: .now)
}
