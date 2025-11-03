//
//  WordCloudController.swift
//  JotDown
//
//  Created by Karishma Kamalahasan on 11/2/25.
//

import SwiftUI
import SwiftData
import Combine
import UIKit

final class WordCloudController: ObservableObject {
    enum Phase { case idle, thinking, merging, streaming }

    @Published  var bubbles: [WordBubble] = []
    @Published  var phase: Phase = .idle
    @Published  var streamed: String = ""

    private var pulseTasks: [UUID: Task<Void, Never>] = [:]

    func reset() {
        cancelPulses()
        phase = .idle
        bubbles.removeAll()
        streamed = ""
    }

    func startThinking(words: [String], in size: CGSize) {
        cancelPulses()
        phase = .thinking
        streamed = ""
        bubbles = spawnBubbles(words: words, in: size)

        // fade in
        withAnimation(.easeInOut(duration: 0.25)) {
            for i in bubbles.indices { bubbles[i].opacity = 1 }
        }

        // start individual pulse loops
        for b in bubbles {
            pulseTasks[b.id] = Task { [weak self] in
                guard let self else { return }
                try? await Task.sleep(nanoseconds: UInt64(b.stagger * 1_000_000_000))
                while !Task.isCancelled && self.phase == .thinking {
                    await MainActor.run {
                        if let i = self.bubbles.firstIndex(where: { $0.id == b.id }) {
                            withAnimation(.easeInOut(duration: self.bubbles[i].pulseSpeed)) {
                                self.bubbles[i].popped.toggle()
                            }
                        }
                    }
                    try? await Task.sleep(nanoseconds: UInt64(b.pulseSpeed * 1_000_000_000))
                }
            }
        }
    }

    func finishWith(answer: String, size: CGSize) {
        // merge to center + fade
        phase = .merging
        let c = CGPoint(x: size.width/2, y: size.height/2)
        for i in bubbles.indices {
            let delay = bubbles[i].stagger
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
                guard let self else { return }
                withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
                    self.bubbles[i].pos = c
                }
                withAnimation(.easeOut(duration: 1).delay(0.1)) {
                    self.bubbles[i].opacity = 0
                }
            }
        }

        // stop pulses shortly after
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.06 * Double(bubbles.count) + 0.3) {
            self.cancelPulses()
            self.stream(answer)
            
        }
    }

    // MARK: - Internals
    private func cancelPulses() {
        pulseTasks.values.forEach { $0.cancel() }
        pulseTasks.removeAll()
    }

    private func stream(_ text: String) {
        phase = .streaming
        streamed = ""
        Task { @MainActor in
            for ch in text {
                streamed.append(ch)
                try? await Task.sleep(nanoseconds: 12_000_000) // 12ms per char
            }
        }
    }
    
    private func textSize(_ text: String, fontSize: CGFloat, fontName: String = "AvenirNext-Regular") -> CGSize {
        let font = UIFont(name: fontName, size: fontSize) ?? UIFont.systemFont(ofSize: fontSize, weight: .regular)
        let attrs: [NSAttributedString.Key: Any] = [.font: font]
        // + horizontal padding similar to your capsule pill
        let w = (text as NSString).size(withAttributes: attrs).width + 20
        let h = font.lineHeight + 12
        return CGSize(width: ceil(w), height: ceil(h))
    }
    
    private func placeRectsSpiral(sizes: [CGSize], canvas: CGSize, margin: CGFloat = 8) -> [CGPoint] {
        guard canvas.width > 0, canvas.height > 0 else { return Array(repeating: .zero, count: sizes.count) }

        // Safe region (keep a little margin to edges)
        let minX = margin, minY = margin
        let maxX = canvas.width  - margin
        let maxY = canvas.height - margin

        var rects: [CGRect] = []
        var centers: [CGPoint] = []
        let C = CGPoint(x: canvas.width/2, y: canvas.height/2)

        // Spiral params
        let a: CGFloat = 2.0
        let b: CGFloat = 6.0
        let dθ: CGFloat = 0.20 // radians

        for sz in sizes {
            var θ: CGFloat = 0
            var placed = false
            var candidate = CGRect(origin: .zero, size: sz)

            while !placed {
                let r = a + b * θ
                let x = C.x + r * cos(θ) - sz.width/2
                let y = C.y + r * sin(θ) - sz.height/2
                candidate.origin = CGPoint(x: x, y: y)

                let inBounds = (candidate.minX >= minX) &&
                               (candidate.maxX <= maxX) &&
                               (candidate.minY >= minY) &&
                               (candidate.maxY <= maxY)

                if inBounds && !rects.contains(where: { $0.intersects(candidate) }) {
                    rects.append(candidate)
                    centers.append(CGPoint(x: candidate.midX, y: candidate.midY))
                    placed = true
                } else {
                    θ += dθ
                    // very defensive: stop trying after many steps and clamp
                    if θ > 200 { // ~ 10k steps
                        let clamped = candidate.integral
                        rects.append(clamped)
                        centers.append(CGPoint(x: clamped.midX, y: clamped.midY))
                        break
                    }
                }
            }
        }
        return centers
    }
    
    private func spawnBubbles(words: [String], in size: CGSize) -> [WordBubble] {
        // Rank → size (bigger first)
           let baseSizes: [CGFloat] = words.enumerated().map { idx, _ in max(18 - CGFloat(idx) * 2.5, 12) }
           let measured = zip(words, baseSizes).map { (w, s) in textSize(w, fontSize: s) }

           // Compute non-overlapping centers, filling the whole available canvas
           let centers = placeRectsSpiral(sizes: measured, canvas: size, margin: 12)

           // Build bubbles
           return words.enumerated().map { idx, w in
               WordBubble(
                   text: w,
                   baseSize: baseSizes[idx],
                   pos: centers[idx],
                   popped: Bool.random(),
                   pulseSpeed: Double.random(in: 0.55...0.9),
                   opacity: 0,
                   stagger: Double(idx) * 0.06
               )
           }
    }
}
