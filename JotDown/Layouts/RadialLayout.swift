//
//  RadialLayout.swift
//  JotDown
//
//  Created by Siddharth Palanivel on 10/23/25.
//
import SwiftUI

struct CategoryLayoutKey: LayoutValueKey {
    // The default value for any view that doesn't specify a category
    static var defaultValue: String? = "Other"
}

struct RadialLayout: Layout {
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) -> CGSize {
        // accept the full proposed space, replacing any nil values with a sensible default
        proposal.replacingUnspecifiedDimensions()
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) {
        
        
    }
}
