import SwiftUI

struct MascotView: View {
    let object: LiftObject
    let isCelebrating: Bool

    var body: some View {
        TimelineView(.animation) { timeline in
            let t = timeline.date.timeIntervalSinceReferenceDate
            let pump = sin(t * 7) * 3
            let bodyBounce = CGFloat(pump / 3)

            ZStack {
                trophyObject
                    .offset(x: 67, y: 62)
                    .opacity(isCelebrating ? 0.12 : 1)

                ZStack {
                    leftArm(pump: CGFloat(pump))
                        .offset(x: -87, y: 28)

                    rightArm(pump: CGFloat(pump), isCelebrating: isCelebrating)
                        .offset(x: isCelebrating ? 75 : 82, y: isCelebrating ? -25 : 12)

                    legs(pump: CGFloat(pump))
                        .offset(y: 94)

                    pixelEarth
                        .offset(y: bodyBounce)

                    eyes
                        .offset(y: bodyBounce)

                    if isCelebrating {
                        Text(object.emoji)
                            .font(.system(size: 34))
                            .offset(x: 83, y: -82)
                            .transition(.scale)
                    }
                }
                .frame(width: 180, height: 190)
                .offset(y: 6)
            }
            .frame(width: 180, height: 215)
            .animation(.spring(response: 0.34, dampingFraction: 0.68), value: isCelebrating)
        }
    }

    private var trophyObject: some View {
        VStack(spacing: 1) {
            Text(object.emoji)
                .font(.system(size: 26))
            Text("Lv.\(object.level)")
                .font(.system(size: 8, weight: .bold, design: .rounded))
                .foregroundStyle(.secondary)
        }
        .padding(5)
        .background(.white.opacity(0.55))
        .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))
    }

    private var pixelEarth: some View {
        PixelMap(
            rows: [
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
            ],
            pixelSize: 7
        )
        .shadow(color: .black.opacity(0.16), radius: 0, x: 4, y: 4)
    }

    private var eyes: some View {
        HStack(spacing: 31) {
            PixelBlock(width: 2, height: 7, pixelSize: 6, color: MascotPalette.dark)
            PixelBlock(width: 2, height: 7, pixelSize: 6, color: MascotPalette.dark)
        }
        .offset(y: -7)
    }

    private func leftArm(pump: CGFloat) -> some View {
        PixelMap(
            rows: [
                ".....DDD..",
                "....DDD...",
                "....DD....",
                "...DDD....",
                "...DD.....",
                "..DDD.....",
                "..DD......",
                ".DDD......",
                ".DD.......",
                "DDD.......",
                "DDD.......",
                ".DDDDD....",
                "..DDDDD...",
                "....DDD..."
            ],
            pixelSize: 5
        )
        .offset(y: pump)
    }

    private func rightArm(pump: CGFloat, isCelebrating: Bool) -> some View {
        Group {
            if isCelebrating {
                PixelMap(
                    rows: [
                        "......DDD..",
                        ".....DDDD..",
                        ".....DDD...",
                        "....DDD....",
                        "....DD.....",
                        "...DDD.....",
                        "..DDD......",
                        "..DD.......",
                        ".DDD.......",
                        ".DD........",
                        "DDD........",
                        "DD........."
                    ],
                    pixelSize: 5
                )
            } else {
                PixelMap(
                    rows: [
                        "DD........",
                        "DDD.......",
                        ".DDD......",
                        "..DDD.....",
                        "...DDD....",
                        "....DDD...",
                        ".....DD...",
                        ".....DDD..",
                        "......DDD.",
                        "......DDDD",
                        ".......DDD",
                        ".......DD."
                    ],
                    pixelSize: 5
                )
                .offset(y: -pump)
            }
        }
    }

    private func legs(pump: CGFloat) -> some View {
        HStack(spacing: 30) {
            PixelMap(
                rows: [
                    "..DD..",
                    "..DD..",
                    "..DD..",
                    "..DD..",
                    "..DD..",
                    "DDDDDD",
                    "DDDDDD"
                ],
                pixelSize: 5
            )
            .offset(x: -3, y: max(0, pump / 2))

            PixelMap(
                rows: [
                    "..DD..",
                    "..DD..",
                    "..DD..",
                    "..DD..",
                    "..DD..",
                    "DDDDDD",
                    "DDDDDD"
                ],
                pixelSize: 5
            )
            .scaleEffect(x: -1, y: 1)
            .offset(x: 3, y: max(0, -pump / 2))
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
    MascotView(object: LiftObject(level: 5, name: "Keyboard", emoji: "⌨️"), isCelebrating: true)
}
