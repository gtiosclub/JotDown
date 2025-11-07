//
//  JotDownWidget.swift
//  JotDownWidget
//
//  Created by Shreyas Shrestha on 10/23/25.
//

import WidgetKit
import SwiftUI
import SwiftData

// MARK: - Shared Gradient
struct AppGradient: View {
    var body: some View {
        EllipticalGradient(
            stops: [
                Gradient.Stop(color: Color(red: 0.94, green: 0.87, blue: 0.94), location: 0.00),
                Gradient.Stop(color: Color(red: 0.78, green: 0.85, blue: 0.93), location: 1.00),
            ],
            center: UnitPoint(x: 0.67, y: 0.46)
        )
    }
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), thoughts: [])
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let thoughts = fetchRecentThoughts()
        let entry = SimpleEntry(date: Date(), thoughts: thoughts)
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let thoughts = fetchRecentThoughts()
        let entry = SimpleEntry(date: Date(), thoughts: thoughts)
        
        // Reload every 15 minutes
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
    
    private func fetchRecentThoughts() -> [ThoughtEntry] {
        guard let container = createModelContainer() else {
            print("❌ Widget: Failed to create model container")
            return []
        }
        
        print("✅ Widget: Model container created")
        
        let context = ModelContext(container)
        var descriptor = FetchDescriptor<Thought>(
            sortBy: [SortDescriptor(\.dateCreated, order: .reverse)]
        )
        descriptor.fetchLimit = 7
        
        do {
            let thoughts = try context.fetch(descriptor)
            print("✅ Widget: Fetched \(thoughts.count) thoughts")
            return thoughts.map { thought in
                ThoughtEntry(
                    content: thought.content,
                    dateCreated: thought.dateCreated,
                    categoryName: thought.category.name
                )
            }
        } catch {
            print("❌ Widget: Error fetching thoughts: \(error)")
            return []
        }
    }
    
    private func createModelContainer() -> ModelContainer? {
        do {
            let container = try ModelContainer(
                for: User.self,
                Thought.self,
                Category.self,
                configurations: ModelConfiguration()
            )
            print("✅ Widget: Container created successfully")
            return container
        } catch {
            print("❌ Widget: Error creating container: \(error)")
            return nil
        }
    }
}

struct ThoughtEntry: Codable {
    let content: String
    let dateCreated: Date
    let categoryName: String
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let thoughts: [ThoughtEntry]
}

struct RecentNotesWidgetEntryView: View {
    var entry: Provider.Entry
    
    var body: some View {
        RecentNotesView(thoughts: entry.thoughts)
    }
}

struct NewThoughtWidgetView: View {
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "note.text.badge.plus")
                .font(.system(size: 28))
                .foregroundColor(Color(red: 0.49, green: 0.58, blue: 0.70))
            
            Text("New Thought")
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(Color(red: 0.49, green: 0.58, blue: 0.70))
            
            Text("Tap to jot down")
                .font(.system(size: 10, weight: .regular))
                .italic()
                .foregroundColor(Color(red: 0.49, green: 0.58, blue: 0.70))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .containerBackground(for: .widget) {
            AppGradient()
        }
        .widgetURL(URL(string: "jotdown://new")!)
    }
}

struct RecentNotesView: View {
    let thoughts: [ThoughtEntry]
    
    var body: some View {
        Group {
            if thoughts.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "note.text")
                        .font(.system(size: 28))
                        .foregroundColor(Color(red: 0.49, green: 0.58, blue: 0.70))
                    
                    Text("No thoughts yet")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(Color(red: 0.49, green: 0.58, blue: 0.70))
                    
                    Text("Create your first")
                        .font(.system(size: 9, weight: .regular))
                        .italic()
                        .foregroundColor(Color(red: 0.49, green: 0.58, blue: 0.70))
                }
            } else {
                VStack(spacing: 0) {
                    Spacer()
                    
                    if let firstThought = thoughts.first {
                        Text(firstThought.content)
                            .font(.system(size: 16, weight: .regular))
                            .lineLimit(4)
                            .foregroundColor(Color(red: 0.49, green: 0.58, blue: 0.70))
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                    }
                    
                    Spacer()
                    
                    if let firstThought = thoughts.first {
                        ThoughtTimeView(thought: firstThought)
                            .padding(.bottom, 8)
                    }
                }
                .padding(.horizontal, 14)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .containerBackground(for: .widget) {
            AppGradient()
        }
        .widgetURL(URL(string: "jotdown://home")!)
    }
}

struct ThoughtRowView: View {
    let thought: ThoughtEntry
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: thought.dateCreated)
    }
    
    var body: some View {
        VStack(spacing: 4) {
            Text(thought.content)
                .font(.system(size: 14, weight: .regular))
                .lineLimit(3)
                .foregroundColor(Color(red: 0.49, green: 0.58, blue: 0.70))
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
            
            HStack(spacing: 4) {
                Text(formattedDate)
                    .font(.system(size: 10, weight: .regular))
                    .italic()
                    .foregroundColor(Color(red: 0.49, green: 0.58, blue: 0.70))
                
                if !thought.categoryName.isEmpty && thought.categoryName != "Dummy" {
                    Text("•")
                        .font(.system(size: 10, weight: .regular))
                        .italic()
                        .foregroundColor(Color(red: 0.49, green: 0.58, blue: 0.70))
                    
                    Text(thought.categoryName)
                        .font(.system(size: 10, weight: .regular))
                        .italic()
                        .foregroundColor(Color(red: 0.49, green: 0.58, blue: 0.70))
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
}

struct ThoughtTimeView: View {
    let thought: ThoughtEntry
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: thought.dateCreated)
    }
    
    var body: some View {
        HStack(spacing: 4) {
            Text(formattedDate)
                .font(.system(size: 10, weight: .regular))
                .italic()
                .foregroundColor(Color(red: 0.49, green: 0.58, blue: 0.70))
            
            if !thought.categoryName.isEmpty && thought.categoryName != "Dummy" {
                Text("•")
                    .font(.system(size: 10, weight: .regular))
                    .italic()
                    .foregroundColor(Color(red: 0.49, green: 0.58, blue: 0.70))
                
                Text(thought.categoryName)
                    .font(.system(size: 10, weight: .regular))
                    .italic()
                    .foregroundColor(Color(red: 0.49, green: 0.58, blue: 0.70))
            }
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - New Thought Widget
struct NewThoughtWidget: Widget {
    let kind: String = "NewThoughtWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            NewThoughtWidgetView()
                .containerBackground(for: .widget) {
                    AppGradient()
                }
        }
        .configurationDisplayName("New Thought")
        .description("Quickly create a new thought.")
        .supportedFamilies([.systemSmall])
        .contentMarginsDisabled()
    }
}

// MARK: - Recent Notes Widget
struct RecentNotesWidget: Widget {
    let kind: String = "RecentNotesWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            RecentNotesWidgetEntryView(entry: entry)
                .containerBackground(for: .widget) {
                    AppGradient()
                }
        }
        .configurationDisplayName("Recent Notes")
        .description("View your most recent thoughts.")
        .supportedFamilies([.systemSmall])
        .contentMarginsDisabled()
    }
}

#Preview(as: .systemSmall) {
    NewThoughtWidget()
} timeline: {
    SimpleEntry(date: .now, thoughts: [])
}

#Preview(as: .systemSmall) {
    RecentNotesWidget()
} timeline: {
    SimpleEntry(date: .now, thoughts: [
        ThoughtEntry(content: "This is a sample thought that shows how the widget displays recent notes.", dateCreated: Date(), categoryName: "Personal"),
        ThoughtEntry(content: "Another thought demonstrates the widget functionality.", dateCreated: Date().addingTimeInterval(-3600), categoryName: "Work"),
        ThoughtEntry(content: "Short note example", dateCreated: Date().addingTimeInterval(-7200), categoryName: "Music")
    ])
}
