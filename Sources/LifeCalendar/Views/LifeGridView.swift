import SwiftUI
import AppKit

struct LifeGridView: View {
    let progress: LifeProgress
    let backgroundColor: Color
    let foregroundColor: Color
    let backgroundImage: NSImage?
    let gridScale: Double
    let backgroundImageMode: BackgroundImageMode
    let dotImage: NSImage?
    let gridOpacity: Double
    let gridAnchor: GridAnchor
    let sidePadding: Double
    let dotShape: DotShape
    let iconSize: Double
    let currentYearStyle: CurrentYearStyle

    private let strokeRatio: Double = 0.06

    private var cellPadding: Double {
        let clamped = min(max(iconSize, 0.0), 1.0)
        return (1.0 - clamped) / 2.0
    }

    var body: some View {
        GeometryReader { geo in
            let layout = CellLayout(
                canvas: geo.size,
                columns: progress.columns,
                rows: progress.rows,
                gridScale: gridScale,
                gridAnchor: gridAnchor,
                sidePadding: sidePadding,
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

    @ViewBuilder
    private func shapeFilled(size: Double, color: Color) -> some View {
        switch dotShape {
        case .circle:
            Circle()
                .fill(color)
                .frame(width: size, height: size)
        case .roundedSquare:
            RoundedRectangle(cornerRadius: size * 0.25, style: .continuous)
                .fill(color)
                .frame(width: size, height: size)
        case .square:
            Rectangle()
                .fill(color)
                .frame(width: size, height: size)
        }
    }

    @ViewBuilder
    private func shapeStroked(size: Double, color: Color, lineWidth: Double) -> some View {
        switch dotShape {
        case .circle:
            Circle()
                .stroke(color, lineWidth: lineWidth)
                .frame(width: size, height: size)
        case .roundedSquare:
            RoundedRectangle(cornerRadius: size * 0.25, style: .continuous)
                .stroke(color, lineWidth: lineWidth)
                .frame(width: size, height: size)
        case .square:
            Rectangle()
                .stroke(color, lineWidth: lineWidth)
                .frame(width: size, height: size)
        }
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
                            shapeFilled(size: dotSize, color: .white)
                        } else {
                            shapeStroked(
                                size: dotSize,
                                color: .white,
                                lineWidth: layout.strokeWidth(dotSize: dotSize)
                            )
                        }
                    }
                    .position(x: center.x, y: center.y)
                    .opacity(cell.opacity)
                }
            }
        }
    }

    private func filledCellsMask(layout: CellLayout) -> some View {
        // The current cell is masked from the dot image only when the user has
        // chosen `.image` for current year. Otherwise the current cell is drawn
        // explicitly by `currentCell` so the outline / color style shows through.
        ZStack {
            Color.clear
            ForEach(0..<progress.totalYears, id: \.self) { index in
                let cell = progress.cells[index]
                let include: Bool = {
                    switch cell.state {
                    case .lived: return true
                    case .current: return currentYearStyle == .image
                    case .remaining: return false
                    }
                }()
                if include {
                    let center = layout.center(at: index)
                    let dotSize = layout.dotSize(scale: cell.sizeScale)
                    shapeFilled(size: dotSize, color: .white)
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
                shapeFilled(size: size, color: foregroundColor)
            } else {
                EmptyView()
            }
        case .current:
            currentCell(size: size)
        case .remaining:
            if backgroundImage != nil && backgroundImageMode == .ringOutlines {
                EmptyView()
            } else {
                shapeStroked(
                    size: size,
                    color: foregroundColor,
                    lineWidth: max(0.5, size * strokeRatio)
                )
            }
        }
    }

    @ViewBuilder
    private func currentCell(size: Double) -> some View {
        let baseStroke = max(0.5, size * strokeRatio)
        ZStack {
            // Inner mark depends on the chosen style.
            switch currentYearStyle {
            case .outline:
                // Thicker stroke than the remaining cells so the current year
                // reads as a deliberate accent rather than another empty ring.
                shapeStroked(size: size, color: foregroundColor, lineWidth: baseStroke * 3.0)
            case .color:
                // Solid fill in the foreground color. Always drawn — even when
                // a dot image is set, because the filledCellsMask now excludes
                // the current cell unless the user explicitly picks .image.
                shapeFilled(size: size, color: foregroundColor)
            case .image:
                // When a dot image is configured, the filledCellsMask renders
                // it into this cell — nothing extra to draw here. When there's
                // no image, fall back to a solid colored fill.
                if dotImage == nil {
                    shapeFilled(size: size, color: foregroundColor)
                }
            }

            // Halo is always drawn on the current cell.
            shapeStroked(
                size: size * 1.45,
                color: foregroundColor.opacity(0.6),
                lineWidth: baseStroke * 1.2
            )
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

    init(canvas: CGSize, columns: Int, rows: Int, gridScale: Double, gridAnchor: GridAnchor, sidePadding: Double, cellPadding: Double, strokeRatio: Double) {
        let base = min(canvas.width / Double(columns), canvas.height / Double(rows))
        self.cellSize = base * gridScale
        let width = cellSize * Double(columns)
        let height = cellSize * Double(rows)

        // Use the smaller dimension so left/right and top/bottom paddings end up
        // with the same pixel value (instead of one being wider on landscape).
        let pad = min(canvas.width, canvas.height) * sidePadding
        let padX = pad
        let padY = pad

        switch gridAnchor.horizontal {
        case .leading:
            self.originX = padX
        case .center:
            self.originX = (canvas.width - width) / 2
        case .trailing:
            self.originX = canvas.width - width - padX
        }

        switch gridAnchor.vertical {
        case .top:
            self.originY = padY
        case .center:
            self.originY = (canvas.height - height) / 2
        case .bottom:
            self.originY = canvas.height - height - padY
        }

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
