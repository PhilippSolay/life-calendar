import SwiftUI

/// Layout tab of the setup panel: position swatches, padding, icon type/size,
/// and column count.
struct LayoutPage: View {
    @EnvironmentObject var settings: Settings

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            positionRow
            paddingRow
            gridSizeRow
            iconTypeRow
            iconSizeRow
            columnsRow
        }
    }

    // MARK: - Position

    @ViewBuilder
    private var positionRow: some View {
        HStack(alignment: .center, spacing: 12) {
            Text("Position")
                .font(.system(size: 12.5))
                .foregroundStyle(.white.opacity(0.7))
            Spacer(minLength: 8)
            PositionSwatches(
                value: settings.gridAnchor.index,
                onChange: { settings.gridAnchor = GridAnchor.from(index: $0) }
            )
        }
    }

    // MARK: - Padding (hidden helper when centered)

    @ViewBuilder
    private var paddingRow: some View {
        if !settings.gridAnchor.isCentered {
            NumRow(
                label: "Padding",
                value: Int(round(settings.sidePadding * 100)),
                suffix: "%",
                range: 0...20,
                onChange: { settings.sidePadding = Double($0) / 100 }
            )
        }
    }

    // MARK: - Grid size

    @ViewBuilder
    private var gridSizeRow: some View {
        NumRow(
            label: "Grid size",
            value: Int(round(settings.gridScale * 100)),
            suffix: "%",
            range: 1...100,
            onChange: { settings.gridScale = Double($0) / 100 }
        )
    }

    // MARK: - Icon type

    @ViewBuilder
    private var iconTypeRow: some View {
        HStack(alignment: .center, spacing: 12) {
            Text("Icon type")
                .font(.system(size: 12.5))
                .foregroundStyle(.white.opacity(0.7))
            Spacer(minLength: 8)
            IconTypePicker(
                value: settings.dotShape,
                onChange: { settings.dotShape = $0 }
            )
        }
    }

    // MARK: - Icon size

    @ViewBuilder
    private var iconSizeRow: some View {
        NumRow(
            label: "Icon size",
            value: Int(round(settings.iconSize * 100)),
            suffix: "%",
            range: 0...100,
            onChange: { settings.iconSize = Double($0) / 100 }
        )
    }

    // MARK: - Columns

    @ViewBuilder
    private var columnsRow: some View {
        NumRow(
            label: "Columns",
            value: settings.columns,
            range: 4...24,
            onChange: { settings.columns = $0 }
        )
    }
}

#Preview {
    LayoutPage()
        .environmentObject(Settings.shared)
        .padding(22)
        .frame(width: 360)
        .background(Color.black)
}
