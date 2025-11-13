//
//  RadialLayout.swift
//  JotDown
//
//  Created by Siddharth Palanivel on 10/23/25.
//

import SwiftUI

private struct ThoughtLayoutKey: LayoutValueKey {
    static var defaultValue: Thought? = nil
}

struct CategoryLayoutKey: LayoutValueKey {
    static var defaultValue: String? = nil
}

extension View {
    func layoutThought(_ thought: Thought) -> some View {
        layoutValue(key: ThoughtLayoutKey.self, value: thought)
    }

    func layoutCategory(_ categoryName: String) -> some View {
        layoutValue(key: CategoryLayoutKey.self, value: categoryName)
    }
}

struct RadialLayout: Layout {
    typealias Cache = LayoutCache

    static let maxBubbleSize: CGFloat = 150

    var scale: Double = 1.0

    struct SectorData {
        let startAngle: Angle
        let sectorWidth: Angle
        let thoughts: [Thought]
        let subviews: [LayoutSubview]
        let categoryName: String

        var positions: [CGPoint] = []
    }

    struct LayoutCache {
        var sectors: [SectorData] = []
        var categoryLabels: [(String, LayoutSubview)] = []
    }

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout Cache) -> CGSize {
        var center: CGPoint = .zero
        if let width = proposal.width {
            center.x = width / 2
        }
        if let height = proposal.height {
            center.y = height / 2
        }

        var maxX: CGFloat = 0, maxY: CGFloat = 0
        var minX: CGFloat = .greatestFiniteMagnitude, minY: CGFloat = .greatestFiniteMagnitude
        for sector in cache.sectors {
            for i in sector.positions.indices {
                let position = sector.positions[i]
                    .applying(.init(rotationAngle: sector.startAngle.radians))
                    .applying(.init(translationX: center.x, y: center.y))

                maxX = max(position.x, maxX)
                maxY = max(position.y, maxY)
                minX = min(position.x, minX)
                minY = min(position.y, minY)
            }
        }

        return .init(
            width: (maxX - minX + Self.maxBubbleSize + 100) * scale,
            height: (maxY - minY + Self.maxBubbleSize + 100) * scale
        )
    }

    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout Cache
    ) {
        let center = CGPoint(x: bounds.midX, y: bounds.midY)

        // Place thought bubbles
        for sector in cache.sectors {
            for i in sector.positions.indices {
                let position = sector.positions[i]
                    .applying(.init(rotationAngle: sector.startAngle.radians))
                    .applying(.init(translationX: center.x - 100, y: center.y))

                sector
                    .subviews[i]
                    .place(
                        at: position,
                        proposal: .init(
                            width: Self.maxBubbleSize,
                            height: nil
                        )
                    )
            }
        }

        // Place category labels
        for (categoryName, subview) in cache.categoryLabels {
            // Find the matching sector
            guard let sector = cache.sectors.first(where: { $0.categoryName == categoryName }) else {
                continue
            }

            // Calculate the average radius for this sector to center the label
            var totalRadius: CGFloat = 0
            var maxRadius: CGFloat = 0
            for position in sector.positions {
                let distance = sqrt(position.x * position.x + position.y * position.y)
                totalRadius += distance
                maxRadius = max(maxRadius, distance)
            }

            // Position label at the center of the sector (average of all thought positions)
            let labelRadius: CGFloat
            if sector.positions.isEmpty {
                labelRadius = Self.maxBubbleSize * 2
            } else if sector.positions.count == 1 {
                // For single thought, place label closer to center
                labelRadius = totalRadius / CGFloat(sector.positions.count) * 0.5
            } else {
                // For multiple thoughts, use average radius
                labelRadius = totalRadius / CGFloat(sector.positions.count)
            }

            let centerAngle = sector.startAngle + Angle.degrees(sector.sectorWidth.degrees / 2)

            let labelPosition = CGPoint(
                x: labelRadius * CGFloat(cos(centerAngle.radians)),
                y: labelRadius * CGFloat(sin(centerAngle.radians))
            )
            .applying(.init(translationX: center.x - 100, y: center.y))

            subview.place(
                at: labelPosition,
                anchor: .center,
                proposal: .init(width: 220, height: nil)
            )
        }
    }

    func makeCache(subviews: Subviews) -> Cache {
        makeSectors(subviews: subviews)
    }

    private func makeSectors(subviews: Subviews) -> LayoutCache {
        var sectors = [SectorData]()
        var categoryLabels: [(String, LayoutSubview)] = []

        let thoughts: [(Thought, LayoutSubview)] = subviews.compactMap {
            guard let thought = $0[ThoughtLayoutKey.self] else { return nil }
            return (thought, $0)
        }

        // Extract category labels
        categoryLabels = subviews.compactMap {
            guard let categoryName = $0[CategoryLayoutKey.self] else { return nil }
            return (categoryName, $0)
        }

        let mappedCategories = Dictionary(grouping: thoughts) { $0.0.category }

        var currAngle: Angle = .zero
        for (category, categoryThoughts) in mappedCategories
            .sorted(by: { $0.key.name < $1.key.name }) {
            let proportion = Double(categoryThoughts.count) / Double(thoughts.count)
            let sectorWidth = Angle.degrees(360 * CGFloat(proportion))

            var sectorData = SectorData(
                startAngle: currAngle,
                sectorWidth: sectorWidth,
                thoughts: categoryThoughts.map { $0.0 },
                subviews: categoryThoughts.map { $0.1 },
                categoryName: category.name
            )

            sectorData.positions = calculatePositions(for: sectorData)

            sectors.append(sectorData)

            currAngle = currAngle + sectorWidth
        }

        return LayoutCache(sectors: sectors, categoryLabels: categoryLabels)
    }

    private func calculatePositions(for sectorData: SectorData) -> [CGPoint] {
        let radiusStep: CGFloat = Self.maxBubbleSize * 0.89

        var positions: [CGPoint] = []
        var currRadius: CGFloat = 0
        while positions.count < sectorData.thoughts.count {
            let arcLength = sectorData.sectorWidth.radians * currRadius

            let availablePositionsOnArc = Int(arcLength / (Self.maxBubbleSize * 1.1))

            guard availablePositionsOnArc > 0 else {
                currRadius += radiusStep
                continue
            }

            let angleIncrement: Angle = .degrees(
                sectorData.sectorWidth.degrees / Double(availablePositionsOnArc)
            )

            let arcStartPosition: CGPoint = .init(
                x: currRadius * (sectorData.thoughts.count == 1 ? 0.7 : 1),
                y: 0
            )
            for i in 1...availablePositionsOnArc {
                let angleOffset: Angle = .degrees(
                    (Double(i) - 0.5) * angleIncrement.degrees
                )
                let positionOnArc = arcStartPosition
                    .applying(
                        .init(rotationAngle: angleOffset.radians)
                    )

                positions.append(positionOnArc)

                if positions.count >= sectorData.thoughts.count {
                    break
                }
            }

            currRadius += radiusStep
        }

        return positions
    }
}

