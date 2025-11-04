//
//  MorphableShape.swift
//  JotDown
//
//  Created by Karishma Kamalahasan on 11/4/25.
//

import SwiftUI

struct MorphableShape: InsettableShape {
    var progress: CGFloat  // 0 = circle, 1 = rounded rectangle
    var insetAmount: CGFloat = 0
    
    var animatableData: AnimatablePair<CGFloat, CGFloat> {
        get { AnimatablePair(progress, insetAmount) }
        set {
            progress = newValue.first
            insetAmount = newValue.second
        }
    }
    
    func path(in rect: CGRect) -> Path {
        let insetRect = rect.insetBy(dx: insetAmount, dy: insetAmount)
        let width = insetRect.width
        let height = insetRect.height
        let centerX = insetRect.midX
        let centerY = insetRect.midY
        
        // At progress = 0, we want a circle
        // At progress = 1, we want a rounded rectangle
        
        // Interpolate between circle radius and rectangle dimensions
        let circleRadius = min(width, height) / 2
        let targetWidth = width * 0.85  // Final rectangle width
        let targetHeight = height * 0.4  // Final rectangle height
        
        let currentWidth = circleRadius * 2 + (targetWidth - circleRadius * 2) * progress
        let currentHeight = circleRadius * 2 + (targetHeight - circleRadius * 2) * progress
        
        // Corner radius interpolates from circle (full radius) to rounded rect
        let cornerRadius = circleRadius * (1 - progress) + 28 * progress
        
        let frame = CGRect(
            x: centerX - currentWidth / 2,
            y: centerY - currentHeight / 2,
            width: currentWidth,
            height: currentHeight
        )
        
        return RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .path(in: frame)
    }
    
    func inset(by amount: CGFloat) -> MorphableShape {
        var shape = self
        shape.insetAmount += amount
        return shape
    }
}
