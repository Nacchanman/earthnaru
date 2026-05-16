import SwiftUI

struct MascotView: View {
    let object: LiftObject
    let isCelebrating: Bool
    let runFrame: Int

    private let pixel: CGFloat = 5

    var body: some View {
        let frame = runFrame % 4
        let bob: CGFloat = isCelebrating ? -4 : [0, -3, 0, -2][frame]

        ZStack {
            trophyObject
                .offset(x: 53, y: 55)
                .opacity(isCelebrating ? 0.12 : 1)

            ZStack {
                legs(frame: frame)
                    .offset(x: 0, y: 68 + bob)

                leftArm(frame: frame)
                    .offset(x: -55, y: 9 + bob)

                rightArm(frame: frame, isCelebrating: isCelebrating)
                    .offset(x: isCelebrating ? 55 : 55, y: isCelebrating ? -40 : 9 + bob)

                pixelEarth
                    .offset(x: 0, y: 12 + bob)

                eyes
                    .offset(x: 0, y: 12 + bob)

                if isCelebrating {
                    Text(object.emoji)
                        .font(.system(size: 28))
                        .offset(x: 61, y: -83)
                        .transition(.scale)
                }
            }
            .frame(width: 154, height: 178)
        }
        .frame(width: 154, height: 178)
        .animation(.spring(response: 0.16, dampingFraction: 0.82), value: runFrame)
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
            pixelSize: pixel
        )
        .shadow(color: .black.opacity(0.16), radius: 0, x: 3, y: 3)
    }

    private var eyes: some View {
        HStack(spacing: 23) {
            PixelBlock(width: 2, height: 6, pixelSize: 4, color: MascotPalette.dark)
            PixelBlock(width: 2, height: 6, pixelSize: 4, color: MascotPalette.dark)
        }
        .offset(y: -4)
    }

    private func leftArm(frame: Int) -> some View {
        let backward = frame == 0 || frame == 1
        return PixelMap(
            rows: backward
            ? [
                "....DD.",
                "...DD..",
                "..DD...",
                ".DD....",
                "DD.....",
                "DD.....",
                ".DDD..."
            ]
            : [
                "DD.....",
                ".DD....",
                "..DD...",
                "...DD..",
                "....DD.",
                "....DD.",
                "..DDD.."
            ],
            pixelSize: pixel
        )
    }

    private func rightArm(frame: Int, isCelebrating: Bool) -> some View {
        if isCelebrating {
            return PixelMap(
                rows: [
                    "....DD.",
                    "...DD..",
                    "..DD...",
                    ".DD....",
                    "DD.....",
                    "DD.....",
                    ".DDD..."
                ],
                pixelSize: pixel
            )
        }

        let forward = frame == 0 || frame == 1
        return PixelMap(
            rows: forward
            ? [
                "DD.....",
                ".DD....",
                "..DD...",
                "...DD..",
                "....DD.",
                "....DD.",
                "..DDD.."
            ]
            : [
                "....DD.",
                "...DD..",
                "..DD...",
                ".DD....",
                "DD.....",
                "DD.....",
                ".DDD..."
            ],
            pixelSize: pixel
        )
    }

    private func legs(frame: Int) -> some View {
        let leftForward = frame == 0 || frame == 1
        return HStack(spacing: 19) {
            leg(forward: leftForward)
            leg(forward: !leftForward)
                .scaleEffect(x: -1, y: 1)
        }
    }

    private func leg(forward: Bool) -> some View {
        PixelMap(
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
    MascotView(object: LiftObject(level: 5, name: "Keyboard", emoji: "⌨️"), isCelebrating: true, runFrame: 1)
}
