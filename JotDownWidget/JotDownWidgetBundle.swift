//
//  JotDownWidgetBundle.swift
//  JotDownWidget
//
//  Created by Shreyas Shrestha on 10/23/25.
//

import WidgetKit
import SwiftUI

@main
struct JotDownWidgetBundle: WidgetBundle {
    var body: some Widget {
        NewThoughtWidget()
        RecentNotesWidget()
        JotDownWidgetControl()
        JotDownWidgetLiveActivity()
    }
}
