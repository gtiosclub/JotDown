import SwiftUI

struct StatDisplay: View {
    let value: String
    let label: String

    var body: some View {
        VStack(alignment: .leading) {
            Text(value)
                .statLabelStyle()
            Text(label)
                .statDescriptionStyle()
        }
    }
}
