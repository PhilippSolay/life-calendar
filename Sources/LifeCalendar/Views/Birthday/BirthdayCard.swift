import SwiftUI

/// Uniform 600×480 glass card used by all three birthday screens. Centers its
/// children and applies the `.glass--lg` look (32pt radius).
struct BirthdayCard<Content: View>: View {
    @ViewBuilder let content: () -> Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        ZStack {
            content()
                .padding(32)
        }
        .frame(width: 600, height: 480)
        .glassCard(cornerRadius: 32)
    }
}

#Preview {
    BirthdayCard {
        Text("Card body")
            .foregroundStyle(.white)
    }
    .padding(40)
    .background(Color.black)
}
