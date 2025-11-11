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
    @State private var morphProgress: CGFloat = 0
    @Environment(\.isSearching) var isSearching
    let orbConfig = OrbConfiguration(
        backgroundColors: [.purple, .primaryText],
        glowColor: .primaryText,
        coreGlowIntensity: 1.2
    )
    
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
                
                // Orb (thinking / merging) - now scales with animation
                if controller.phase != .streaming {
                    OrbView(configuration: orbConfig)
                        .frame(
                            width: min(geo.size.width, geo.size.height) * 0.5 * controller.orbScale,
                            height: min(geo.size.width, geo.size.height) * 0.5 * controller.orbScale
                        )
                    //                         .animation(.linear(duration: 4), value: controller.orbScale)
                }
                
                
                if controller.phase == .streaming {
                    ZStack {
                        
                        
                        // Text on top
                        Text(controller.streamed)
                            .font(.system(size: 22, weight: .regular, design: .rounded))
                            .foregroundColor(.primaryText)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: geo.size.width * 0.8)
                            .opacity(min(morphProgress * 1.5, 1.0)) // Fade in with morph
                        //                            .frame(width: min(geo.size.width * morphProgress)
                            .frame(alignment: .topLeading)
                        
                            .background(
                                MorphableShape(progress: morphProgress)
                                    .fill(cardBackgroundColor)
                                    .overlay(
                                        MorphableShape(progress: morphProgress)
                                            .strokeBorder(cardBorderColor, lineWidth: 1)
                                    )
                                    .shadow(color: .black.opacity(0.2), radius: 10, y: 2)
                                    .frame(width: geo.size.width, height: geo.size.height)
                                    .onAppear {
                                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                            morphProgress = 1.0
                                        }
                                    }
                            )
                        
                    }
                    .frame(width: geo.size.width, height: geo.size.height)
                    .onAppear {
                        withAnimation(.spring(response: 1.0, dampingFraction: 0.75)) {
                            morphProgress = 1.0
                        }
                    }
                    
                }
            }
            .frame(width: geo.size.width, height: geo.size.height)
            .onChange(of: geo.size) { oldSize, newSize in
                controller.updateCanvasSize(newSize)
            }
            .onReceive(NotificationCenter.default.publisher(for: .startCloud)) { note in
                let words = (note.object as? [String]) ?? []
                controller.startThinking(words: words, in: geo.size)
                morphProgress = 0
            }
            .onReceive(NotificationCenter.default.publisher(for: .finishCloud)) { note in
                let answer = (note.object as? String) ?? ""
                controller.finishWith(answer: answer, size: geo.size)
            }
        }
        .onChange(of: isSearching, initial: false) { _, newValue in
            if !newValue {
                withAnimation {
                    controller.reset()
                }
            }
        }
        .ignoresSafeArea(.keyboard)
        .allowsHitTesting(false)
    }

    private var cardBackgroundColor: Color {
        Color(red: 0.95, green: 0.94, blue: 0.97) // Soft lavender-white
    }
    
    private var cardBorderColor: Color {
        Color(red: 0.88, green: 0.87, blue: 0.92).opacity(0.6)
    }
}

