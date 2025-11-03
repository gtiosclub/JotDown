//
//  WordCloudAnswerView.swift
//  JotDown
//
//  Created by Karishma Kamalahasan on 11/2/25.
//
import SwiftUI
import SwiftData
import Orb

struct WordCloudAnswerView: View {
    @ObservedObject var controller: WordCloudController
    @State private var showOrb = true
    @State private var orbScale: CGFloat = 1.0
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                // bubbles (thinking / merging)
                ForEach(controller.bubbles) { b in
                    Text(b.text)
                        .font(.system(size: b.baseSize, weight: .semibold, design: .rounded))
                        .padding(.horizontal, 10).padding(.vertical, 6)
                        .background(.ultraThinMaterial, in: Capsule())
                        .overlay(Capsule().strokeBorder(.primary.opacity(0.12), lineWidth: 0.5))
                        .shadow(radius: 4, y: 2)
                        .scaleEffect(b.popped ? 1.18 : 0.92)
                        .opacity(b.opacity)
                        .position(b.pos)
                        .animation(.easeInOut(duration: b.pulseSpeed), value: b.popped)
                        .animation(.easeInOut(duration: 0.25), value: b.opacity)
                        .animation(.spring(response: 0.45, dampingFraction: 0.85), value: b.pos)
                }

                // streamed answer
                if showOrb && controller.phase != .streaming {
                     OrbView()
                         .frame(width: min(geo.size.width, geo.size.height) * 0.35,
                                height: min(geo.size.width, geo.size.height) * 0.35)
                }

                // --- Streaming answer in a glass card ---
                if controller.phase == .streaming {
                    let purplelight = Color(.sRGB, red: 132/255.0, green: 133/255.0, blue: 177/255.0)
                    let purpledark  = Color(.sRGB, red: 107/255.0, green: 107/255.0, blue: 138/255.0)
                    let gradient  =  LinearGradient(
                        colors: [ purpledark],           // aurora
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    VStack {
                        Text(controller.streamed)
                            .font(.system(size: 17, weight: .regular, design: .rounded))
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(18)
                    .background(
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .fill(.ultraThinMaterial)
                            .fill(gradient)
                            .opacity(0.23)
                            //.glassEffect()
                            .shadow(color: .black.opacity(0.1), radius: 28, y: 12)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .strokeBorder(.white.opacity(0.25), lineWidth: 0.5)
                    )
                    .padding(.horizontal, 24)
                    .transition(.asymmetric(insertion: .opacity.combined(with: .scale), removal: .opacity))
                }
            }
            .frame(width: geo.size.width, height: geo.size.height)
            .onReceive(NotificationCenter.default.publisher(for: .startCloud)) { note in
                let words = (note.object as? [String]) ?? []
                controller.startThinking(words: words, in: geo.size)
                showOrb = true
                orbScale = 1.0
            }
            .onReceive(NotificationCenter.default.publisher(for: .finishCloud)) { note in
                let answer = (note.object as? String) ?? ""
                // shrink the orb first, then stream
                withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
                    orbScale = 0.01
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    showOrb = false
                    controller.finishWith(answer: answer, size: geo.size)
                }
            }
        }
        .ignoresSafeArea(.keyboard)
        .allowsHitTesting(false)
    }
}
