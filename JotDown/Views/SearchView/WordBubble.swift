//
//  WordBubble.swift
//  JotDown
//
//  Created by Karishma Kamalahasan on 11/2/25.
//
import SwiftUI
import SwiftData

struct WordBubble: Identifiable {
    let id = UUID()
    let text: String
    var baseSize: CGFloat
    var pos: CGPoint
    var popped: Bool
    var pulseSpeed: Double
    var opacity: Double
    var stagger: Double
}
