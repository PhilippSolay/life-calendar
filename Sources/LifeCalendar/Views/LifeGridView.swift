import SwiftUI
import AppKit

struct LifeGridView: View {
    let progress: LifeProgress
    let backgroundColor: Color
    let foregroundColor: Color
    let highlightCurrentYear: Bool
    let backgroundImage: NSImage?
    let gridScale: Double
    let backgroundImageMode: BackgroundImageMode
    let dotImage: NSImage?
    let gridOpacity: Double

    private let cellPadding: Double = 0.18
    private let strokeRatio: Double = 0.06

    var body: some View {
        GeometryReader { geo in
            let layout = CellLayout(
                canvas: geo.size,
                columns: progress.columns,
                rows: progress.rows,
                gridScale: gridScale,
                cellPadding: cellPadding,
                strokeRatio: strokeRatio
            )

            ZStack {
                backgroundColor.ignoresSafeArea()

                if let image = backgroundImage, backgroundImageMode == .fullScreen {
                    fullScreenImage(image, in: geo.size)
                }

                ZStack {
                    if let image = backgroundImage {
                        switch backgroundImageMode {
                        case .fullScreen:
                            EmptyView()
                        case .insideRings:
                            fullScreenImage(image, in: geo.size)
                                .mask(ringMask(filled: true, layout: layout))
                        case .ringOutlines:
                            fullScreenImage(image, in: geo.size)
                                .mask(ringMask(filled: false, layout: layout))
                        }
                    }

                    if let dot = dotImage {
                        fullScreenImage(dot, in: geo.size)
                            .mask(filledCellsMask(layout: layout))
                    }

                    ForEach(0..<progress.totalYears, id: \.self) { index in
                        let cell = progress.cells[index]
                        let center = layout.center(at: index)
                        let dotSize = layout.dotSize(scale: cell.sizeScale)

                        cellShape(for: cell, size: dotSize)
                            .position(x: center.x, y: center.y)
                            .opacity(cell.opacity)
                    }
                }
                .opacity(gridOpacity)
            }
        }
    }

    private func fullScreenImage(_ image: NSImage, in size: CGSize) -> some View {
        Image(nsImage: image)
            .resizable()
            .scaledToFill()
            .frame(width: size.width, height: size.height)
            .clipped()
            .ignoresSafeArea()
    }

    private func ringMask(filled: Bool, layout: CellLayout) -> some View {
        ZStack {
            Color.clear
            ForEach(0..<progress.totalYears, id: \.self) { index in
                let cell = progress.cells[index]
                if cell.state == .remaining {
                    let center = layout.center(at: index)
                    let dotSize = layout.dotSize(scale: cell.sizeScale)
                    Group {
                        if filled {
                            Circle()
                                .fill(Color.white)
                                .frame(width: dotSize, height: dotSize)
                        } else {
                            Circle()
                                .stroke(Color.white, lineWidth: layout.strokeWidth(dotSize: dotSize))
                                .frame(width: dotSize, height: dotSize)
                        }
                    }
                    .position(x: center.x, y: center.y)
                    .opacity(cell.opacity)
                }
            }
        }
    }

    private func filledCellsMask(layout: CellLayout) -> some View {
        ZStack {
            Color.clear
            ForEach(0..<progress.totalYears, id: \.self) { index in
                let cell = progress.cells[index]
                if cell.state == .lived || cell.state == .current {
                    let center = layout.center(at: index)
                    let dotSize = layout.dotSize(scale: cell.sizeScale)
                    Circle()
                        .fill(Color.white)
                        .frame(width: dotSize, height: dotSize)
                        .position(x: center.x, y: center.y)
                        .opacity(cell.opacity)
                }
            }
        }
    }

    @ViewBuilder
    private func cellShape(for cell: LifeCell, size: Double) -> some View {
        switch cell.state {
        case .lived:
            if dotImage == nil {
                Circle()
                    .fill(foregroundColor)
                    .frame(width: size, height: size)
            } else {
                EmptyView()
            }
        case .current:
            ZStack {
                if dotImage == nil {
                    Circle()
                        .fill(foregroundColor)
                        .frame(width: size, height: size)
                }
                if highlightCurrentYear {
                    Circle()
                        .stroke(foregroundColor.opacity(0.6), lineWidth: size * strokeRatio * 1.2)
                        .frame(width: size * 1.45, height: size * 1.45)
                }
            }
        case .remaining:
            if backgroundImage != nil && backgroundImageMode == .ringOutlines {
                EmptyView()
            } else {
                Circle()
                    .stroke(foregroundColor, lineWidth: max(0.5, size * strokeRatio))
                    .frame(width: size, height: size)
            }
        }
    }
}

private struct CellLayout {
    let cellSize: Double
    let originX: Double
    let originY: Double
    let columns: Int
    let cellPadding: Double
    let strokeRatio: Double

    init(canvas: CGSize, columns: Int, rows: Int, gridScale: Double, cellPadding: Double, strokeRatio: Double) {
        let base = min(canvas.width / Double(columns), canvas.height / Double(rows))
        self.cellSize = base * gridScale
        let width = cellSize * Double(columns)
        let height = cellSize * Double(rows)
        self.originX = (canvas.width - width) / 2
        self.originY = (canvas.height - height) / 2
        self.columns = columns
        self.cellPadding = cellPadding
        self.strokeRatio = strokeRatio
    }

    func center(at index: Int) -> CGPoint {
        let row = index / columns
        let col = index % columns
        return CGPoint(
            x: originX + cellSize * (Double(col) + 0.5),
            y: originY + cellSize * (Double(row) + 0.5)
        )
    }

    func dotSize(scale: Double) -> Double {
        cellSize * (1.0 - cellPadding * 2) * scale
    }

    func strokeWidth(dotSize: Double) -> Double {
        max(0.5, dotSize * strokeRatio)
    }
}
