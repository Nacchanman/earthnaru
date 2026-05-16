import SwiftUI

struct MascotView: View {
    let object: LiftObject
    let isCelebrating: Bool

    var body: some View {
        TimelineView(.animation) { timeline in
            let t = timeline.date.timeIntervalSinceReferenceDate
            let pump = sin(t * 7) * 4
            let rightHandLift: CGFloat = isCelebrating ? -54 : CGFloat(pump)
            let leftHandLift: CGFloat = CGFloat(-pump / 2)

            ZStack {
                trophyObject
                    .offset(x: 66, y: 58)
                    .opacity(isCelebrating ? 0.15 : 1)

                VStack(spacing: 0) {
                    if isCelebrating {
                        Text(object.emoji)
                            .font(.system(size: 34))
                            .offset(x: 45, y: 8)
                    }

                    ZStack {
                        leftArm(lift: leftHandLift)
                            .offset(x: -73, y: 39)

                        rightArm(lift: rightHandLift)
                            .offset(x: 75, y: 25)

                        pixelEarth
                            .offset(y: CGFloat(pump / 4))

                        eyes
                            .offset(y: CGFloat(pump / 4))

                        legs(pump: CGFloat(pump))
                            .offset(y: 96)
                    }
                    .frame(width: 180, height: 172)
                }
            }
            .frame(width: 180, height: 215)
            .animation(.spring(response: 0.35, dampingFraction: 0.65), value: isCelebrating)
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
            pixelSize: 7,
            palette: MascotPalette.self
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

    private func leftArm(lift: CGFloat) -> some View {
        ZStack {
            PixelBlock(width: 2, height: 7, pixelSize: 7, color: MascotPalette.dark)
                .rotationEffect(.degrees(32))
                .offset(x: 14, y: lift / 3)
            PixelBlock(width: 4, height: 3, pixelSize: 7, color: MascotPalette.dark)
                .offset(x: -8, y: 32 + lift)
            PixelBlock(width: 3, height: 3, pixelSize: 7, color: MascotPalette.dark)
                .offset(x: -22, y: 47 + lift)
        }
    }

    private func rightArm(lift: CGFloat) -> some View {
        ZStack {
            PixelBlock(width: 2, height: 8, pixelSize: 7, color: MascotPalette.dark)
                .rotationEffect(.degrees(-58))
                .offset(x: -8, y: lift / 2)
            PixelBlock(width: 4, height: 3, pixelSize: 7, color: MascotPalette.dark)
                .offset(x: 24, y: -8 + lift)
            PixelBlock(width: 3, height: 3, pixelSize: 7, color: MascotPalette.dark)
                .offset(x: 43, y: -27 + lift)
        }
    }

    private func legs(pump: CGFloat) -> some View {
        HStack(spacing: 26) {
            VStack(spacing: 0) {
                PixelBlock(width: 2, height: 5, pixelSize: 7, color: MascotPalette.dark)
                PixelBlock(width: 6, height: 2, pixelSize: 7, color: MascotPalette.dark)
                    .offset(x: -14)
            }
            .offset(y: max(0, pump / 2))

            VStack(spacing: 0) {
                PixelBlock(width: 2, height: 5, pixelSize: 7, color: MascotPalette.dark)
                PixelBlock(width: 6, height: 2, pixelSize: 7, color: MascotPalette.dark)
                    .offset(x: 14)
            }
            .offset(y: max(0, -pump / 2))
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

private struct PixelMap<Palette>: View {
    let rows: [String]
    let pixelSize: CGFloat
    let palette: Palette.Type

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
