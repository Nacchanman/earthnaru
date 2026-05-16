import SwiftUI

struct MascotView: View {
    let object: LiftObject
    let isCelebrating: Bool
    let runFrame: Int

    private let pixel: CGFloat = 5
    private let canvasSize = CGSize(width: 154, height: 178)
    private let bodyCenter = CGPoint(x: 77, y: 88)

    var body: some View {
        let frame = runFrame % 4
        let bob: CGFloat = isCelebrating ? -4 : [0, -3, 0, -2][frame]

        ZStack {
            legs(frame: frame)
                .position(x: bodyCenter.x, y: bodyCenter.y + 60 + bob)

            leftArm(frame: frame)
                .position(x: bodyCenter.x - 54, y: bodyCenter.y + 4 + bob)

            rightArm(frame: frame, isCelebrating: isCelebrating)
                .position(x: bodyCenter.x + 54, y: bodyCenter.y + (isCelebrating ? -42 : 4) + bob)

            PixelGrid(rows: earthRows, pixelSize: pixel)
                .shadow(color: .black.opacity(0.16), radius: 0, x: 3, y: 3)
                .position(x: bodyCenter.x, y: bodyCenter.y + bob)

            eyes
                .position(x: bodyCenter.x + 13, y: bodyCenter.y - 2 + bob)

            if isCelebrating {
                Text(object.emoji)
                    .font(.system(size: 28))
                    .position(x: bodyCenter.x + 58, y: bodyCenter.y - 84)
                    .transition(.scale)
            }
        }
        .frame(width: canvasSize.width, height: canvasSize.height, alignment: .center)
        .clipped()
        .animation(.spring(response: 0.16, dampingFraction: 0.82), value: runFrame)
        .animation(.spring(response: 0.34, dampingFraction: 0.68), value: isCelebrating)
    }

    private var earthRows: [String] {
        [
            ".......DDDDDDD.......",
            ".....DDDBBBBBBBDD....",
            "....DBBGGGGGBBBBBD...",
            "...DBGGGGGGBBBBBBBD..",
            "..DBGGGGGGBBBBBBBBBD.",
            ".DBBGGGGGBBBBBBGGBBBD",
            ".DBBBGGGBBBBBBGGGGBBD",
            "DBBBBBBBBBBBBBGGGGGBD",
            "DBBBBBBEBBBBBEBBGGBBD",
            "DBBBBBBEBBBBBEBBBBBBD",
            "DBBBBBBBBBBBBBBGGGGBD",
            ".DBBBBBGGBBBBBGGGGGBD",
            ".DBBBBGGGGBBBBGGGGBD.",
            "..DBBGGGGGGGGBBBBGD..",
            "...DBGGGGGGGGBBBBD...",
            "....DDBGGGGGBBBDD....",
            ".....DDDBBBBBDD......",
            ".......DDDDDDD......."
        ]
    }

    private var eyes: some View {
        HStack(spacing: 22) {
            PixelBlock(width: 2, height: 5, pixelSize: 4, color: MascotPalette.dark)
            PixelBlock(width: 2, height: 5, pixelSize: 4, color: MascotPalette.dark)
        }
    }

    private func leftArm(frame: Int) -> some View {
        let rows: [String]
        if frame == 0 || frame == 1 {
            rows = [
                "....DD",
                "...DD.",
                "..DD..",
                ".DD...",
                "DD....",
                "DD....",
                ".DDD.."
            ]
        } else {
            rows = [
                "DD....",
                ".DD...",
                "..DD..",
                "...DD.",
                "....DD",
                "....DD",
                "..DDD."
            ]
        }
        return PixelGrid(rows: rows, pixelSize: pixel)
    }

    private func rightArm(frame: Int, isCelebrating: Bool) -> some View {
        if isCelebrating {
            return PixelGrid(rows: [
                "....DD",
                "...DD.",
                "..DD..",
                ".DD...",
                "DD....",
                "DD....",
                ".DDD.."
            ], pixelSize: pixel)
        }

        let rows: [String]
        if frame == 0 || frame == 1 {
            rows = [
                "DD....",
                ".DD...",
                "..DD..",
                "...DD.",
                "....DD",
                "....DD",
                "..DDD."
            ]
        } else {
            rows = [
                "....DD",
                "...DD.",
                "..DD..",
                ".DD...",
                "DD....",
                "DD....",
                ".DDD.."
            ]
        }
        return PixelGrid(rows: rows, pixelSize: pixel)
    }

    private func legs(frame: Int) -> some View {
        let leftForward = frame == 0 || frame == 1
        return HStack(spacing: 18) {
            leg(forward: leftForward)
            leg(forward: !leftForward)
                .scaleEffect(x: -1, y: 1)
        }
    }

    private func leg(forward: Bool) -> some View {
        PixelGrid(
            rows: forward
            ? [
                "..DD.",
                "..DD.",
                ".DD..",
                ".DD..",
                "DDDD.",
                "DDDD."
            ]
            : [
                ".DD..",
                ".DD..",
                "..DD.",
                "..DD.",
                ".DDDD",
                ".DDDD"
            ],
            pixelSize: pixel
        )
    }
}

private enum MascotPalette {
    static let dark = Color(red: 0.03, green: 0.14, blue: 0.40)
    static let ocean = Color(red: 0.24, green: 0.55, blue: 0.91)
    static let land = Color(red: 0.56, green: 0.74, blue: 0.39)

    static func color(for symbol: Character) -> Color? {
        switch symbol {
        case "D": dark
        case "B": ocean
        case "G": land
        case "E": dark
        default: nil
        }
    }
}

private struct PixelGrid: View {
    let rows: [String]
    let pixelSize: CGFloat

    private var pixels: [(row: Int, column: Int, color: Color)] {
        var minRow = Int.max
        var minColumn = Int.max
        var raw: [(row: Int, column: Int, color: Color)] = []

        for (rowIndex, row) in rows.map({ Array($0) }).enumerated() {
            for (columnIndex, symbol) in row.enumerated() {
                guard let color = MascotPalette.color(for: symbol) else { continue }
                raw.append((rowIndex, columnIndex, color))
                minRow = min(minRow, rowIndex)
                minColumn = min(minColumn, columnIndex)
            }
        }

        guard minRow != Int.max else { return [] }
        return raw.map { ($0.row - minRow, $0.column - minColumn, $0.color) }
    }

    private var dimensions: (columns: Int, rows: Int) {
        let px = pixels
        return ((px.map(\.column).max() ?? 0) + 1, (px.map(\.row).max() ?? 0) + 1)
    }

    var body: some View {
        let px = pixels
        let dimensions = dimensions

        ZStack(alignment: .topLeading) {
            ForEach(Array(px.enumerated()), id: \.offset) { _, pixel in
                Rectangle()
                    .fill(pixel.color)
                    .frame(width: pixelSize, height: pixelSize)
                    .offset(
                        x: CGFloat(pixel.column) * pixelSize,
                        y: CGFloat(pixel.row) * pixelSize
                    )
            }
        }
        .frame(
            width: CGFloat(dimensions.columns) * pixelSize,
            height: CGFloat(dimensions.rows) * pixelSize
        )
    }
}

private struct PixelBlock: View {
    let width: Int
    let height: Int
    let pixelSize: CGFloat
    let color: Color

    var body: some View {
        VStack(spacing: 0) {
            ForEach(0..<height, id: \.self) { _ in
                HStack(spacing: 0) {
                    ForEach(0..<width, id: \.self) { _ in
                        Rectangle()
                            .fill(color)
                            .frame(width: pixelSize, height: pixelSize)
                    }
                }
            }
        }
    }
}

#Preview {
    MascotView(object: LiftObject(level: 5, name: "Keyboard", emoji: "⌨️"), isCelebrating: true, runFrame: 1)
}
