//
//  ThoughtCardsList.swift
//  JotDown
//
//  Created by Drew Mendelow on 10/14/25.
//
import SwiftUI
import SwiftData

struct ThoughtCardsList: View {
    var thoughts: [Thought]
    @Environment(HomeViewModel.self) private var viewModel
    @FocusState var isFocused: Bool

    @State private var firstCardOffset: CGFloat = 0
    @GestureState private var isDragging = false
    @State private var sendHapticFeedback: Bool = true
    @Binding var selectedTab: Int
    @Binding var categoryToPresent: Category?

    private func handlePreferenceChange(offset: CGFloat, proxy: GeometryProxy, thoughtWidth: CGFloat) {
        if viewModel.selectedIndex == 1 && thoughts.count > 0 {
            let thoughtPadding = (proxy.size.width - thoughtWidth) / 2
            let expectedCardMinX = thoughtPadding
            let rightwardMovement = max(0, offset - expectedCardMinX)
            firstCardOffset = rightwardMovement
        } else {
            firstCardOffset = 0
        }
    }

    private func resetOffsets() {
        firstCardOffset = 0
    }

    var body: some View {
        @Bindable var viewModel = viewModel

        GeometryReader { proxy in
            let writableWidth: CGFloat = 337
            let thoughtWidth: CGFloat = 251

            let writablePadding: CGFloat = (proxy.size.width - writableWidth) / 2
            let thoughtPadding: CGFloat = (proxy.size.width - thoughtWidth) / 2
            let leadingPadding: CGFloat = viewModel.showWritableThought && viewModel.selectedIndex == 0 ? writablePadding : thoughtPadding
            let trailingPadding: CGFloat = thoughts.count > 0 ? thoughtPadding : 0

            let revealAmount: CGFloat = max(0, min(firstCardOffset / 80, 1.0))
            let shouldShowNewNote: Bool = !viewModel.showWritableThought && thoughts.count > 0 && viewModel.selectedIndex == 1 && firstCardOffset > 0

            ZStack(alignment: .leading) {
                if shouldShowNewNote {
                    NewNoteSwipableAction(revealAmount: revealAmount)
                        .frame(width: proxy.size.width * 0.3, height: 472)
                        .offset(x: 0)
                        .opacity(revealAmount)
                        .transition(.opacity.combined(with: .scale(scale: 0.8)))
                }

                ScrollViewReader { scrollProxy in
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(alignment: .center, spacing: 16) {

                            if viewModel.showWritableThought {
                                WritableThoughtCard(
                                    text: $viewModel.thoughtInput,
                                    isFocused: _isFocused,
                                    addThought: { try await viewModel.addThought() }
                                )
                                .id(0)
                                .transition(.move(edge: .leading).combined(with: .opacity))
                            }

                            ForEach(Array(thoughts.enumerated()), id: \.1.id) { index, thought in
                                let id = index + 1
                                ThoughtCardCell(
                                    thought: thought,
                                    isSelecting: viewModel.isSelecting,
                                    isSelected: viewModel.selectedThoughts.contains(thought),
                                    selectedTab: $selectedTab,
                                    categoryToPresent: $categoryToPresent
                                )
                                .background(FirstCardOffsetReporter(isFirst: index == 0))
                                .id(id)
                                .onTapGesture {
                                    if viewModel.isSelecting {
                                        viewModel.toggleSelection(for: thought)
                                    } else {
                                        viewModel.selectedIndex = id
                                    }
                                }
                            }
                        }
                        .scrollDisabled(viewModel.isSelecting)
                        .scrollTargetLayout()
                        .padding(.leading, leadingPadding)
                        .padding(.trailing, trailingPadding)
                    }
                    .frame(height: 472)
                    .coordinateSpace(name: "scroll")
                    .scrollTargetBehavior(.viewAligned)
                    .scrollPosition(id: $viewModel.selectedIndex)
                    .scrollClipDisabled()
                    .onPreferenceChange(FirstCardOffsetPreferenceKey.self) { offset in
                        if offset != FirstCardOffsetPreferenceKey.defaultValue {
                            handlePreferenceChange(offset: offset, proxy: proxy, thoughtWidth: thoughtWidth)
                        }

                        if !viewModel.showWritableThought && firstCardOffset >= 55.0 {
                            if sendHapticFeedback {
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                sendHapticFeedback = false
                            }
                            if !isDragging {
                                sendHapticFeedback = true
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                    viewModel.showWritableThought = true
                                }
                                isFocused = true
                            }
                        } else {
                            sendHapticFeedback = true
                        }
                    }
                    .onChange(of: viewModel.selectedIndex ?? -1) { oldIndex, newIndex in
                        if newIndex != 1 { resetOffsets() }
                        guard viewModel.showWritableThought && newIndex >= 1 else { return }

                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            viewModel.showWritableThought = false
                            scrollProxy.scrollTo(0, anchor: .leading)
                        }
                        isFocused = false
                        viewModel.thoughtInput = ""
                    }
                    .simultaneousGesture(
                        DragGesture(minimumDistance: 0)
                            .updating($isDragging) { _, state, _ in state = true }
                    )
                }
            }
            .animation(.spring(response: 0.35, dampingFraction: 0.8), value: shouldShowNewNote)
            .animation(.interactiveSpring(response: 0.25, dampingFraction: 0.9), value: revealAmount)
        }
        .frame(height: 472)
    }
}

private struct ThoughtCardCell: View {
    let thought: Thought
    let isSelecting: Bool
    let isSelected: Bool
    @Binding var selectedTab: Int
    @Binding var categoryToPresent: Category?
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            ThoughtCard(
                thought: thought,
                selectedTab: $selectedTab,
                categoryToPresent: $categoryToPresent
            )
                .opacity(isSelecting && !isSelected ? 0.6 : 1.0)

            if isSelecting {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 24))
                    .foregroundStyle(isSelected ? .blue : .gray.opacity(0.6))
                    .padding(8)
            }
        }
    }
}

private struct FirstCardOffsetReporter: View {
    let isFirst: Bool
    var body: some View {
        GeometryReader { geo in
            Color.clear.preference(
                key: FirstCardOffsetPreferenceKey.self,
                value: isFirst
                    ? geo.frame(in: .named("scroll")).minX
                    : FirstCardOffsetPreferenceKey.defaultValue
            )
        }
    }
}

private struct FirstCardOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        let next = nextValue()
        if next != defaultValue { value = next }
    }
}
