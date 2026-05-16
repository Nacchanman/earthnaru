import SwiftUI

struct MascotView: View {
    let object: LiftObject
    let isCelebrating: Bool
    let runFrame: Int

    private let pixel: CGFloat = 5
    private let canvasSize = CGSize(width: 154, height: 178)

    var body: some View {
        let frame = isCelebrating ? 4 : runFrame % 4

        ZStack {
            PixelMap(rows: spriteRows(frame: frame), pixelSize: pixel)
                .frame(width: canvasSize.width, height: canvasSize.height)
                .shadow(color: .black.opacity(0.16), radius: 0, x: 3, y: 3)

            if isCelebrating {
                Text(object.emoji)
                    .font(.system(size: 28))
                    .offset(x: 46, y: -73)
                    .transition(.scale)
            }
        }
        .frame(width: canvasSize.width, height: canvasSize.height, alignment: .center)
        .clipped()
        .animation(.spring(response: 0.16, dampingFraction: 0.82), value: runFrame)
        .animation(.spring(response: 0.34, dampingFraction: 0.68), value: isCelebrating)
    }

    private func spriteRows(frame: Int) -> [String] {
        switch frame {
        case 1:
            return [
                ".............................",
                "...........DDDDDDD...........",
                ".........DDDBBBBBBBDD........",
                "........DBBGGGGGBBBBBD.......",
                ".......DBGGGGGGBBBBBBBD......",
                "......DBGGGGGGBBBBBBBBBD.....",
                ".....DBBGGGGGBBBBBBGGBBBD....",
                "....DDBBBGGGBBBBBBGGGGBBDD...",
                "...DDDBBBBBBBBBBBBBGGGGGBD...",
                "..DDD.DBBBBBEBBBBBEBBGGBBD...",
                ".DDD..DBBBBBEBBBBBEBBBBBBD...",
                "DDD...DBBBBBBBBBBBBBBGGGGBD..",
                ".DD....DBBBBBGGBBBBBGGGGGBD..",
                "..DD...DBBBBGGGGBBBBGGGGBD..",
                "...DD...DBBGGGGGGGGBBBBGD...",
                "....DD...DBGGGGGGGGBBBBD....",
                ".........DDBGGGGGBBBDD......",
                "..........DDDBBBBBDD........",
                "............DDDDDDD.........",
                "...........DD....DD.........",
                "..........DD......DD........",
                ".........DD........DD.......",
                ".........DDDD.....DDDD......"
            ]
        case 2:
            return [
                ".............................",
                "...........DDDDDDD...........",
                ".........DDDBBBBBBBDD........",
                "........DBBGGGGGBBBBBD.......",
                ".......DBGGGGGGBBBBBBBD......",
                "....DDDBGGGGGGBBBBBBBBBD.....",
                "...DDDBBGGGGGBBBBBBGGBBBD....",
                "..DDDDBBBGGGBBBBBBGGGGBBDD...",
                ".DDD.DBBBBBBBBBBBBBGGGGGBD...",
                "DDD..DBBBBBBEBBBBBEBBGGBBD...",
                ".DD..DBBBBBBEBBBBBEBBBBBBD...",
                "..DD.DBBBBBBBBBBBBBBGGGGBD...",
                "...DD.DBBBBBGGBBBBBGGGGGBD...",
                "....DDDBBBGGGGBBBBGGGGBD....",
                "......DDBBGGGGGGGGBBBBGD....",
                ".......DBGGGGGGGGBBBBD......",
                "........DDBGGGGGBBBDD.......",
                ".........DDDBBBBBDD.........",
                "...........DDDDDDD..........",
                "..........DD......DD........",
                "..........DD......DD........",
                ".........DDDD....DDDD.......",
                ".........DDD......DDD......."
            ]
        case 3:
            return [
                ".............................",
                "...........DDDDDDD...........",
                ".........DDDBBBBBBBDD........",
                "........DBBGGGGGBBBBBD.......",
                ".......DBGGGGGGBBBBBBBD......",
                "....DDDBGGGGGGBBBBBBBBBD.....",
                "...DDDBBGGGGGBBBBBBGGBBBD....",
                "..DDDDBBBGGGBBBBBBGGGGBBDD...",
                ".DDD.DBBBBBBBBBBBBBGGGGGBD...",
                "..DDDDBBBBBBEBBBBBEBBGGBBD...",
                "...DDDBBBBBBEBBBBBEBBBBBBD...",
                "....DDBBBBBBBBBBBBBBGGGGBD...",
                ".....DDBBBBBGGBBBBBGGGGGBD...",
                "......DBBBGGGGBBBBGGGGBD....",
                ".......DBBGGGGGGGGBBBBGD....",
                "........DBGGGGGGGGBBBBD.....",
                ".........DDBGGGGGBBBDD......",
                "..........DDDBBBBBDD........",
                "............DDDDDDD.........",
                "............DD..DD..........",
                "...........DD....DD.........",
                "..........DDDD..DDDD........",
                "..........DDD....DDD........"
            ]
        case 4:
            return [
                "......................DDD....",
                ".....................DDD.....",
                "....................DDD......",
                "...........DDDDDDD.DD........",
                ".........DDDBBBBBBBDD........",
                "........DBBGGGGGBBBBBD.......",
                ".....DDDBGGGGGGBBBBBBBD......",
                "....DDDBGGGGGGBBBBBBBBBD.....",
                "...DDDBBGGGGGBBBBBBGGBBBD....",
                "..DDDDBBBGGGBBBBBBGGGGBBDD...",
                ".DDD.DBBBBBBBBBBBBBGGGGGBD...",
                "..DDDDBBBBBBEBBBBBEBBGGBBD...",
                "...DDDBBBBBBEBBBBBEBBBBBBD...",
                "....DDBBBBBBBBBBBBBBGGGGBD...",
                ".....DDBBBBBGGBBBBBGGGGGBD...",
                "......DBBBGGGGBBBBGGGGBD....",
                ".......DBBGGGGGGGGBBBBGD....",
                "........DBGGGGGGGGBBBBD.....",
                ".........DDBGGGGGBBBDD......",
                "..........DDDBBBBBDD........",
                "............DDDDDDD.........",
                "............DD..DD..........",
                "...........DD....DD.........",
                "..........DDDD..DDDD........"
            ]
        default:
            return [
                ".............................",
                "...........DDDDDDD...........",
                ".........DDDBBBBBBBDD........",
                "........DBBGGGGGBBBBBD.......",
                ".......DBGGGGGGBBBBBBBD......",
                "....DDDBGGGGGGBBBBBBBBBD.....",
                "...DDDBBGGGGGBBBBBBGGBBBD....",
                "..DDDDBBBGGGBBBBBBGGGGBBDD...",
                ".DDD.DBBBBBBBBBBBBBGGGGGBD...",
                "..DDDDBBBBBBEBBBBBEBBGGBBD...",
                "...DDDBBBBBBEBBBBBEBBBBBBD...",
                "....DDBBBBBBBBBBBBBBGGGGBD...",
                ".....DDBBBBBGGBBBBBGGGGGBD...",
                "......DBBBGGGGBBBBGGGGBD....",
                ".......DBBGGGGGGGGBBBBGD....",
                "........DBGGGGGGGGBBBBD.....",
                ".........DDBGGGGGBBBDD......",
                "..........DDDBBBBBDD........",
                "............DDDDDDD.........",
                "...........DD....DD.........",
                "...........DD....DD.........",
                "..........DDDD..DDDD........",
                "..........DDD....DDD........"
            ]
        }
    }
}

private enum MascotPalette {
    static let dark = Color(red: 0.03, green: 0.14, blue: 0.40)
    static let ocean = Color(red: 0.24, green: 0.55, blue: 0.91)
    static let oceanLight = Color(red: 0.34, green: 0.65, blue: 0.98)
    static let land = Color(red: 0.56, green: 0.74, blue: 0.39)

    static func color(for symbol: Character) -> Color? {
        switch symbol {
        case "D": dark
        case "B": ocean
        case "b": oceanLight
        case "G": land
        case "E": dark
        default: nil
        }
    }
}

private struct PixelMap: View {
    let rows: [String]
    let pixelSize: CGFloat

    private var trimmedPixels: [(row: Int, column: Int, color: Color)] {
        let matrix = rows.map { Array($0) }
        var minRow = Int.max
        var minColumn = Int.max
        var rawPixels: [(row: Int, column: Int, color: Color)] = []

        for (rowIndex, row) in matrix.enumerated() {
            for (columnIndex, symbol) in row.enumerated() {
                guard let color = MascotPalette.color(for: symbol) else { continue }
                rawPixels.append((rowIndex, columnIndex, color))
                minRow = min(minRow, rowIndex)
                minColumn = min(minColumn, columnIndex)
            }
        }

        guard minRow != Int.max else { return [] }

        return rawPixels.map { pixel in
            (
                row: pixel.row - minRow,
                column: pixel.column - minColumn,
                color: pixel.color
            )
        }
    }

    private var dimensions: (columns: Int, rows: Int) {
        let pixels = trimmedPixels
        let columns = (pixels.map(\.column).max() ?? 0) + 1
        let rows = (pixels.map(\.row).max() ?? 0) + 1
        return (columns, rows)
    }

    var body: some View {
        let pixels = trimmedPixels
        let dimensions = dimensions

        GeometryReader { geometry in
            let spriteWidth = CGFloat(dimensions.columns) * pixelSize
            let spriteHeight = CGFloat(dimensions.rows) * pixelSize
            let originX = floor((geometry.size.width - spriteWidth) / 2)
            let originY = floor((geometry.size.height - spriteHeight) / 2)

            ZStack(alignment: .topLeading) {
                ForEach(Array(pixels.enumerated()), id: \.offset) { _, pixel in
                    Rectangle()
                        .fill(pixel.color)
                        .frame(width: pixelSize, height: pixelSize)
                        .offset(
                            x: originX + CGFloat(pixel.column) * pixelSize,
                            y: originY + CGFloat(pixel.row) * pixelSize
                        )
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
        }
    }
}

#Preview {
    MascotView(object: LiftObject(level: 5, name: "Keyboard", emoji: "⌨️"), isCelebrating: true, runFrame: 1)
}
