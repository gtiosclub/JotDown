//
//  JotDownWidgetBundle.swift
//  JotDownWidget
//
//  Created by Shreyas Shrestha on 10/23/25.
//

import WidgetKit
import SwiftUI

struct JotDownWidgetBundle: WidgetBundle {
    var body: some Widget {
        JotDownWidget()
        JotDownWidgetControl()
        JotDownWidgetLiveActivity()
    }
}
