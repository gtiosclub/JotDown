import SwiftUI

struct SelectionCheckbox: View {
    let isSelecting: Bool
    let isSelected: Bool

    var body: some View {
        if isSelecting {
            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 24))
                .foregroundStyle(isSelected ? .blue : .gray.opacity(0.6))
                .padding(8)
        }
    }
}
