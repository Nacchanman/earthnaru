import SwiftUI

struct MascotView: View {
    let object: LiftObject
    let isCelebrating: Bool
    let runFrame: Int

    private let pixel: CGFloat = 5
    private let canvasSize = CGSize(width: 154, height: 178)

    private let earthOrigin = CGPoint(x: 24, y: 36)
    private let leftArmOrigin = CGPoint(x: 3, y: 86)
    private let rightArmOrigin = CGPoint(x: 113, y: 70)
    private let starOrigin = CGPoint(x: 117, y: 34)
    private let leftLegOrigin = CGPoint(x: 55, y: 132)
    private let rightLegOrigin = CGPoint(x: 91, y: 132)

    var body: some View {
        let frame = runFrame % 4
        let bob: CGFloat = isCelebrating ? -8 : [0, -7, -2, -5][frame]
        let stomp: CGFloat = frame == 1 ? 4 : 0
        let lean: CGFloat = [-2, 3, -1, 2][frame]
        let squash: CGFloat = frame == 0 ? 0.96 : 1.0
        let stretch: CGFloat = frame == 1 || isCelebrating ? 1.05 : 1.0
        let armPump: CGFloat = frame == 1 || isCelebrating ? -8 : 0
        let starPop: CGFloat = frame == 1 || isCelebrating ? 1.16 : 1.0

        ZStack(alignment: .topLeading) {
            pixelLayer(rows: legRows(left: true), origin: CGPoint(x: leftLegOrigin.x - lean, y: leftLegOrigin.y + bob + stomp))
            pixelLayer(rows: legRows(left: false), origin: CGPoint(x: rightLegOrigin.x - lean, y: rightLegOrigin.y + bob + (frame == 3 ? 3 : 0)))

            pixelLayer(rows: leftArmRows(frame: frame), origin: CGPoint(x: leftArmOrigin.x + lean, y: leftArmOrigin.y + bob - armPump / 3))
            pixelLayer(rows: rightArmRows(frame: frame), origin: CGPoint(x: rightArmOrigin.x + lean, y: rightArmOrigin.y + bob + armPump))

            pixelLayer(rows: earthRows, origin: CGPoint(x: earthOrigin.x, y: earthOrigin.y + bob))
                .shadow(color: .black.opacity(0.16), radius: 0, x: 3, y: 3)
                .scaleEffect(x: squash, y: stretch, anchor: .bottom)
                .offset(x: lean)

            eyes(origin: CGPoint(x: earthOrigin.x + 55 + lean, y: earthOrigin.y + 42 + bob + (stretch > 1 ? -2 : 0)))
            pixelLayer(rows: starRows, origin: CGPoint(x: starOrigin.x, y: starOrigin.y + bob + (isCelebrating ? -3 : 0)))
                .scaleEffect(starPop, anchor: .center)
                .offset(x: lean, y: armPump)

            if frame == 1 || isCelebrating {
                pixelLayer(rows: sparkRows, origin: CGPoint(x: starOrigin.x - 7, y: starOrigin.y + bob - 13 + armPump))
                    .transition(.scale)
            }
        }
        .frame(width: canvasSize.width, height: canvasSize.height, alignment: .topLeading)
        .clipped()
        .animation(.spring(response: 0.16, dampingFraction: 0.82), value: runFrame)
        .animation(.spring(response: 0.34, dampingFraction: 0.68), value: isCelebrating)
    }

    private func pixelLayer(rows: [String], origin: CGPoint) -> some View {
        PixelGrid(rows: rows, pixelSize: pixel)
            .offset(x: origin.x, y: origin.y)
    }

    private func eyes(origin: CGPoint) -> some View {
        HStack(spacing: 22) {
            PixelBlock(width: 2, height: 5, pixelSize: 4, color: MascotPalette.dark)
            PixelBlock(width: 2, height: 5, pixelSize: 4, color: MascotPalette.dark)
        }
        .offset(x: origin.x, y: origin.y)
    }

    private var earthRows: [String] {
        [
            ".......DDDDDDD.......",
            ".....DDDGGGBBBDD....",
            "....DGGGGGBBBBBBD...",
            "...DGGGGGGBBBBBBBD..",
            "..DGGGGGBBBBBBGGBBD.",
            ".DBGGGBBBBBBBGGGGGBD",
            ".DBBGGBBBBBBBGGGGGBD",
            "DBBBBBBBBBBBBGGGGGGBD",
            "DBBBBBBBBBBBGGGGBBBD",
            "DBBBBBBBBBBBGGGGBBBD",
            "DBBBBGGBBBBBBGGGGBBD",
            ".DBBGGGGBBBBBBGGGBD.",
            ".DBGGBBBBBBBBBBGGBD.",
            "..DBBBGGGGBBBBBBBD..",
            "...DGGGGGGGGBBBBD...",
            "....DGGGGGGGGBBD....",
            ".....DDGGGGGBDD.....",
            ".......DDDDDDD......."
        ]
    }

    private func leftArmRows(frame: Int) -> [String] {
        frame == 1 || frame == 2
        ? [
            "...DD..",
            "..DD...",
            ".DD....",
            "DD.....",
            "DD.....",
            ".DD....",
            "..DDD..",
            "...DDD."
        ]
        : [
            ".....DD",
            "....DD.",
            "...DD..",
            "..DD...",
            ".DD....",
            "DD.....",
            "DDD....",
            ".DDD..."
        ]
    }

    private func rightArmRows(frame: Int) -> [String] {
        frame == 1 || isCelebrating
        ? [
            "...DD..",
            "...DD..",
            "..DD...",
            "..DD...",
            ".DD....",
            ".DD....",
            "DDD....",
            "DD....."
        ]
        : [
            "....DD.",
            "....DD.",
            "...DD..",
            "...DD..",
            "..DD...",
            "..DD...",
            "DDD....",
            "DD....."
        ]
    }

    private var starRows: [String] {
        [
            "...R...",
            "...R...",
            ".RRRRR.",
            "..RRR..",
            ".RRRRR.",
            "...R...",
            "...R..."
        ]
    }

    private var sparkRows: [String] {
        [
            "Y...Y",
            ".Y.Y.",
            "..Y..",
            ".Y.Y.",
            "Y...Y"
        ]
    }

    private func legRows(left: Bool) -> [String] {
        left
        ? [
            "..DD",
            "..DD",
            ".DD.",
            ".DD.",
            "DDDD",
            "DDDD"
        ]
        : [
            "DD..",
            "DD..",
            ".DD.",
            ".DD.",
            "DDDD",
            "DDDD"
        ]
    }
}

private enum MascotPalette {
    static let dark = Color(red: 0.03, green: 0.14, blue: 0.40)
    static let ocean = Color(red: 0.24, green: 0.55, blue: 0.91)
    static let land = Color(red: 0.56, green: 0.74, blue: 0.39)
    static let star = Color(red: 0.94, green: 0.22, blue: 0.16)
    static let spark = Color(red: 1.0, green: 0.82, blue: 0.25)

    static func color(for symbol: Character) -> Color? {
        switch symbol {
        case "D": dark
        case "B": ocean
        case "G": land
        case "E": dark
        case "R": star
        case "Y": spark
        default: nil
        }
    }
}

private struct PixelGrid: View {
    let rows: [String]
    let pixelSize: CGFloat

    var body: some View {
        ZStack(alignment: .topLeading) {
            ForEach(Array(rows.enumerated()), id: \.offset) { rowIndex, row in
                ForEach(Array(Array(row).enumerated()), id: \.offset) { columnIndex, symbol in
                    if let color = MascotPalette.color(for: symbol) {
                        Rectangle()
                            .fill(color)
                            .frame(width: pixelSize, height: pixelSize)
                            .offset(
                                x: CGFloat(columnIndex) * pixelSize,
                                y: CGFloat(rowIndex) * pixelSize
                            )
                    }
                }
            }
        }
        .frame(
            width: CGFloat(rows.map { $0.count }.max() ?? 0) * pixelSize,
            height: CGFloat(rows.count) * pixelSize,
            alignment: .topLeading
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
