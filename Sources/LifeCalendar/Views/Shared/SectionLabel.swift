import SwiftUI

/// Caption-style section header — uppercase, tracked, white at 50%.
struct SectionLabel: View {
    let text: String

    init(_ text: String) {
        self.text = text
    }

    var body: some View {
        // CSS spec: 10.5pt, 0.8pt tracking, uppercased, white 50%.
        Text(text.uppercased())
            .font(.system(size: 10.5))
            .tracking(0.8)
            .foregroundStyle(.white.opacity(0.5))
    }
}

#Preview {
    VStack(alignment: .leading, spacing: 8) {
        SectionLabel("Life span")
        SectionLabel("Wallpaper background")
    }
    .padding(20)
    .background(Color.black)
}
