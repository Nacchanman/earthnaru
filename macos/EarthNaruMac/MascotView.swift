import SwiftUI

struct MascotView: View {
    let object: LiftObject
    let isCelebrating: Bool
    let runFrame: Int

    private let pixel: CGFloat = 5

    var body: some View {
        let frame = isCelebrating ? 4 : runFrame % 4

        ZStack {
            trophyObject
                .offset(x: 56, y: 54)
                .opacity(isCelebrating ? 0.12 : 1)

            PixelMap(rows: spriteRows(frame: frame), pixelSize: pixel)
                .shadow(color: .black.opacity(0.16), radius: 0, x: 3, y: 3)
                .offset(y: isCelebrating ? -4 : 0)

            if isCelebrating {
                Text(object.emoji)
                    .font(.system(size: 28))
                    .offset(x: 61, y: -73)
                    .transition(.scale)
            }
        }
        .frame(width: 154, height: 178)
        .animation(.spring(response: 0.18, dampingFraction: 0.78), value: runFrame)
        .animation(.spring(response: 0.34, dampingFraction: 0.68), value: isCelebrating)
    }

    private var trophyObject: some View {
        VStack(spacing: 1) {
            Text(object.emoji)
                .font(.system(size: 22))
            Text("Lv.\(object.level)")
                .font(.system(size: 8, weight: .bold, design: .rounded))
                .foregroundStyle(.secondary)
        }
        .padding(4)
        .background(.white.opacity(0.55))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private func spriteRows(frame: Int) -> [String] {
        switch frame {
        case 1:
            return [
                "..............DDDDDDD.......",
                "............DDDBBBBBBBDD....",
                "......DD...DBBGGGGGBBBBBD...",
                ".....DD...DBGGGGGGBBBBBBBD..",
                "....DD...DBGGGGGGBBBBBBBBBD.",
                "...DD...DBBGGGGGBBBBBBGGBBBD",
                "..DD....DBBBGGGBBBBBBGGGGBBD",
                ".DD....DBBBBBBBBBBBBBGGGGGBD",
                ".DDD...DBBBBBBEBBBBBEBBGGBBD",
                "..DDD..DBBBBBBEBBBBBEBBBBBBD",
                ".......DBBBBBBBBBBBBBBGGGGBD",
                "........DBBBBBGGBBBBBGGGGGBD",
                "........DBBBBGGGGBBBBGGGGBD.",
                ".........DBBGGGGGGGGBBBBGD..",
                "..........DBGGGGGGGGBBBBD...",
                "...........DDBGGGGGBBBDD....",
                "............DDDBBBBBDD......",
                "..............DDDDDDD.......",
                ".............DD....DD.......",
                "............DD......DD......",
                "...........DD........DD.....",
                "...........DDDD.....DDDD...."
            ]
        case 2:
            return [
                "..............DDDDDDD.......",
                "............DDDBBBBBBBDD....",
                ".........DDDBBGGGGGBBBBBD...",
                "........DDDBGGGGGGBBBBBBBD..",
                ".......DDDBGGGGGGBBBBBBBBBD.",
                "......DDDBBGGGGGBBBBBBGGBBBD",
                ".....DD.DBBBGGGBBBBBBGGGGBBD",
                "....DD.DBBBBBBBBBBBBBGGGGGBD",
                "...DD..DBBBBBBEBBBBBEBBGGBBD",
                "..DDD..DBBBBBBEBBBBBEBBBBBBD",
                "..DD...DBBBBBBBBBBBBBBGGGGBD",
                ".......DBBBBBGGBBBBBGGGGGBD",
                "........DBBBBGGGGBBBBGGGGBD.",
                ".........DBBGGGGGGGGBBBBGD..",
                "..........DBGGGGGGGGBBBBD...",
                "...........DDBGGGGGBBBDD....",
                "............DDDBBBBBDD......",
                "..............DDDDDDD.......",
                "............DD......DD......",
                "............DD......DD......",
                "...........DDDD....DDDD.....",
                "...........DDD......DDD....."
            ]
        case 3:
            return [
                "..............DDDDDDD.......",
                "............DDDBBBBBBBDD....",
                ".........DDDBBGGGGGBBBBBD...",
                "........DDDBGGGGGGBBBBBBBD..",
                ".......DDDBGGGGGGBBBBBBBBBD.",
                "......DDDBBGGGGGBBBBBBGGBBBD",
                ".....DD.DBBBGGGBBBBBBGGGGBBD",
                "....DD.DBBBBBBBBBBBBBGGGGGBD",
                "...DDD.DBBBBBEBBBBBEBBGGBBD",
                "....DDDDBBBBBEBBBBBEBBBBBBD",
                ".......DBBBBBBBBBBBBBBGGGGBD",
                "........DBBBBBGGBBBBBGGGGGBD",
                "........DBBBBGGGGBBBBGGGGBD.",
                ".........DBBGGGGGGGGBBBBGD..",
                "..........DBGGGGGGGGBBBBD...",
                "...........DDBGGGGGBBBDD....",
                "............DDDBBBBBDD......",
                "..............DDDDDDD.......",
                "..............DD..DD........",
                ".............DD....DD.......",
                "............DDDD..DDDD......",
                "............DDD....DDD......"
            ]
        case 4:
            return [
                "......................DDD...",
                ".....................DDD....",
                "....................DDD.....",
                "..............DDDDDDD.......",
                "............DDDBBBBBBBDD....",
                ".........DDDBBGGGGGBBBBBD...",
                "........DDDBGGGGGGBBBBBBBD..",
                ".......DDDBGGGGGGBBBBBBBBBD.",
                "......DDDBBGGGGGBBBBBBGGBBBD",
                ".....DD.DBBBGGGBBBBBBGGGGBBD",
                "....DD.DBBBBBBBBBBBBBGGGGGBD",
                "...DDD.DBBBBBEBBBBBEBBGGBBD",
                "....DDDDBBBBBEBBBBBEBBBBBBD",
                ".......DBBBBBBBBBBBBBBGGGGBD",
                "........DBBBBBGGBBBBBGGGGGBD",
                "........DBBBBGGGGBBBBGGGGBD.",
                ".........DBBGGGGGGGGBBBBGD..",
                "..........DBGGGGGGGGBBBBD...",
                "...........DDBGGGGGBBBDD....",
                "............DDDBBBBBDD......",
                "..............DDDDDDD.......",
                "..............DD..DD........",
                ".............DD....DD.......",
                "............DDDD..DDDD......"
            ]
        default:
            return [
                "..............DDDDDDD.......",
                "............DDDBBBBBBBDD....",
                ".........DDDBBGGGGGBBBBBD...",
                "........DDDBGGGGGGBBBBBBBD..",
                ".......DDDBGGGGGGBBBBBBBBBD.",
                "......DDDBBGGGGGBBBBBBGGBBBD",
                ".....DD.DBBBGGGBBBBBBGGGGBBD",
                "....DD.DBBBBBBBBBBBBBGGGGGBD",
                "...DDD.DBBBBBEBBBBBEBBGGBBD",
                "....DDDDBBBBBEBBBBBEBBBBBBD",
                ".......DBBBBBBBBBBBBBBGGGGBD",
                "........DBBBBBGGBBBBBGGGGGBD",
                "........DBBBBGGGGBBBBGGGGBD.",
                ".........DBBGGGGGGGGBBBBGD..",
                "..........DBGGGGGGGGBBBBD...",
                "...........DDBGGGGGBBBDD....",
                "............DDDBBBBBDD......",
                "..............DDDDDDD.......",
                ".............DD....DD.......",
                ".............DD....DD.......",
                "............DDDD..DDDD......",
                "............DDD....DDD......"
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

    private var maxColumns: Int {
        rows.map { $0.count }.max() ?? 0
    }

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
        .frame(width: CGFloat(maxColumns) * pixelSize, height: CGFloat(rows.count) * pixelSize)
    }
}

#Preview {
    MascotView(object: LiftObject(level: 5, name: "Keyboard", emoji: "⌨️"), isCelebrating: true, runFrame: 1)
}
