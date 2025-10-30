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

// No clue what preconcurrency does but accessing the layout key dosen't work without it...
struct RadialLayout: @preconcurrency Layout {
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) -> CGSize {
        // accept the full proposed space, replacing any nil values with a sensible default
        proposal.replacingUnspecifiedDimensions()
    }

    @MainActor func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) {
        guard !subviews.isEmpty else { return }
        
        let totalSubviewCount = subviews.count
        
        //creates a dict, the key is the category, value is list of subviews
        let categories = Dictionary(grouping: subviews) { subview in
            subview[CategoryLayoutKey.self] ?? "Other"
        }
        
        let sortedCategories = categories.keys.sorted()
        
        let initialRadius = min(bounds.size.width, bounds.size.height) / 1.75
        let fullCircle = Angle.degrees(360).radians
        
        //start from theta=pi/2
        var sectorStartAngle: Double = -.pi / 2
        
        for categoryName: String in sortedCategories {
            guard let categoryViews = categories[categoryName] else { continue }
            
            var currentRing = 0
            var capacity = 2
            //The number of views added so far for the current ring
            var viewsAdded = 0
            
            let sectorAngle =  fullCircle / Double(categories.keys.count)
            
            
            for (_, subview) in categoryViews.enumerated() {
                let angleStep = sectorAngle / Double(capacity + 1)
                let viewAngle = sectorStartAngle + (angleStep * Double(viewsAdded + 1))
                
                let viewSize = subview.sizeThatFits(.unspecified)
                let radius = initialRadius + (80 * Double(currentRing))
                
                let xPos = cos(viewAngle) * (radius - viewSize.width / 2)
                let yPos = sin(viewAngle) * (radius - viewSize.height / 2)
                
                let point = CGPoint(x: bounds.midX + xPos, y: bounds.midY + yPos)
                subview.place(at: point, anchor: .center, proposal: .unspecified)
                
                viewsAdded += 1
                
                if(viewsAdded == capacity) {
                    currentRing += 1
                    capacity += 2
                    viewsAdded = 0
                }
            }
            
            //shift currentAngle past the sectorangle to prepare for the next sector
            sectorStartAngle += sectorAngle
            
        }
        
        
        
    }
}

