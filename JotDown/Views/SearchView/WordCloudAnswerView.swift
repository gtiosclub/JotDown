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
                if controller.phase == .thinking || controller.phase == .merging {
                     OrbView()
                         .frame(
                            width: min(geo.size.width, geo.size.height) * 0.35 * controller.orbScale,
                            height: min(geo.size.width, geo.size.height) * 0.35 * controller.orbScale
                         )
                         .animation(.spring(response: 0.6, dampingFraction: 0.75), value: controller.orbScale)
                }
                
                // Morphing phase - orb transforms to rectangle
//                if controller.phase == .morphing {
//                    let purpledark = Color(.sRGB, red: 107/255.0, green: 107/255.0, blue: 138/255.0)
//                    let gradient = LinearGradient(
//                        colors: [purpledark],
//                        startPoint: .topLeading,
//                        endPoint: .bottomTrailing
//                    )
//                    
//                    MorphableShape(progress: morphProgress)
//                        .fill(.ultraThinMaterial)
//                        .overlay(
//                            MorphableShape(progress: morphProgress)
//                                .fill(gradient.opacity(0.23))
//                        )
//                        .overlay(
//                            MorphableShape(progress: morphProgress)
//                                .strokeBorder(Color.white.opacity(0.25), lineWidth: 0.5)
//                        )
//                        .shadow(color: .black.opacity(0.1), radius: 28, y: 12)
//                        .frame(width: geo.size.width, height: geo.size.height)
//                        .onAppear {
//                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
//                                morphProgress = 1.0
//                            }
//                        }
//                }

                if controller.phase == .streaming {
                    ZStack {
                        let purpledark = Color(.sRGB, red: 107/255.0, green: 107/255.0, blue: 138/255.0)
                        let gradient = LinearGradient(
                            colors: [purpledark],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        
                        // Text on top
                        Text(controller.streamed)
                            .font(.system(size: 17, weight: .regular, design: .rounded))
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.leading)
                            .padding(24)
                            .opacity(min(morphProgress * 1.5, 1.0)) // Fade in with morph
                            .frame(width: geo.size.width * morphProgress)
                            .background(
                                MorphableShape(progress: morphProgress)
                                    .fill(.ultraThinMaterial)
                                    .overlay(
                                        MorphableShape(progress: morphProgress)
                                            .fill(gradient.opacity(0.23))
                                    )
                                    .overlay(
                                            MorphableShape(progress: morphProgress)
                                            .strokeBorder(Color.white.opacity(0.25), lineWidth: 0.5)
                                    )
                                    .shadow(color: .black.opacity(0.1), radius: 28, y: 12)
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
        .ignoresSafeArea(.keyboard)
        .allowsHitTesting(false)
    }
}

