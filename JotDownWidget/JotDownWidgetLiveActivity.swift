//
//  JotDownWidgetLiveActivity.swift
//  JotDownWidget
//
//  Created by Shreyas Shrestha on 10/23/25.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct JotDownWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct JotDownWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: JotDownWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension JotDownWidgetAttributes {
    fileprivate static var preview: JotDownWidgetAttributes {
        JotDownWidgetAttributes(name: "World")
    }
}

extension JotDownWidgetAttributes.ContentState {
    fileprivate static var smiley: JotDownWidgetAttributes.ContentState {
        JotDownWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: JotDownWidgetAttributes.ContentState {
         JotDownWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: JotDownWidgetAttributes.preview) {
   JotDownWidgetLiveActivity()
} contentStates: {
    JotDownWidgetAttributes.ContentState.smiley
    JotDownWidgetAttributes.ContentState.starEyes
}
