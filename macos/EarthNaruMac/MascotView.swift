import Foundation
import SwiftUI

struct MascotView: View {
    let date: Date
    let mood: TimeMood

    private let pixel: CGFloat = 4
    private let canvasSize = CGSize(width: 138, height: 156)
    private let earthOrigin = CGPoint(x: 22, y: 34)

    var body: some View {
        let pose = MascotPose(date: date, mood: mood)

        ZStack(alignment: .topLeading) {
            ambientDots(pose: pose)

            pixelLayer(rows: legRows(left: true), origin: CGPoint(x: 50 + pose.leftFootX, y: 122 + pose.footY))
                .rotationEffect(.degrees(pose.leftFootAngle), anchor: .top)
            pixelLayer(rows: legRows(left: false), origin: CGPoint(x: 80 + pose.rightFootX, y: 122 + pose.altFootY))
                .rotationEffect(.degrees(pose.rightFootAngle), anchor: .top)

            pixelLayer(rows: leftArmRows, origin: CGPoint(x: 4 + pose.leftArmX, y: 78 + pose.bodyY + pose.leftArmY))
                .rotationEffect(.degrees(pose.leftArmAngle), anchor: .trailing)
            pixelLayer(rows: rightArmRows, origin: CGPoint(x: 104 + pose.rightArmX, y: 55 + pose.bodyY + pose.rightArmY))
                .rotationEffect(.degrees(pose.rightArmAngle), anchor: .leading)

            pixelLayer(rows: earthRows, origin: CGPoint(x: earthOrigin.x, y: earthOrigin.y + pose.bodyY))
                .shadow(color: .black.opacity(mood == .night || mood == .lateNight ? 0.28 : 0.16), radius: 0, x: 3, y: 3)
                .scaleEffect(x: pose.squash, y: pose.stretch, anchor: .bottom)
                .rotationEffect(.degrees(pose.bodyAngle))
                .offset(x: pose.bodyX)

            eyes(pose: pose)

            pixelLayer(rows: starRows, origin: CGPoint(x: 110 + pose.starX, y: 30 + pose.bodyY + pose.starY))
                .scaleEffect(pose.starScale, anchor: .center)
                .rotationEffect(.degrees(pose.starAngle))

            accessory(pose: pose)
        }
        .frame(width: canvasSize.width, height: canvasSize.height, alignment: .topLeading)
        .clipped()
    }

    private func ambientDots(pose: MascotPose) -> some View {
        ZStack(alignment: .topLeading) {
            ForEach(0..<pose.dotCount, id: \.self) { index in
                Rectangle()
                    .fill(pose.dotColor.opacity(pose.dotOpacity(index: index)))
                    .frame(width: pixel, height: pixel)
                    .offset(x: pose.dotPosition(index: index).x, y: pose.dotPosition(index: index).y)
            }
        }
    }

    @ViewBuilder
    private func accessory(pose: MascotPose) -> some View {
        switch pose.accessory {
        case .sparkle:
            pixelLayer(rows: sparkleRows, origin: CGPoint(x: 95 + pose.sparkleX, y: 16 + pose.sparkleY))
        case .sun:
            pixelLayer(rows: sunRows, origin: CGPoint(x: 9 + pose.sparkleX, y: 10 + pose.sparkleY))
        case .moon:
            pixelLayer(rows: moonRows, origin: CGPoint(x: 12 + pose.sparkleX, y: 14 + pose.sparkleY))
        case .sleep:
            pixelLayer(rows: sleepRows, origin: CGPoint(x: 98 + pose.sparkleX, y: 20 + pose.sparkleY))
        case .none:
            EmptyView()
        }
    }

    private func pixelLayer(rows: [String], origin: CGPoint) -> some View {
        PixelGrid(rows: rows, pixelSize: pixel)
            .offset(x: origin.x, y: origin.y)
    }

    private func eyes(pose: MascotPose) -> some View {
        HStack(spacing: pose.eyeSpacing) {
            PixelGrid(rows: pose.eyeRows, pixelSize: 3)
            PixelGrid(rows: pose.eyeRows, pixelSize: 3)
        }
        .offset(x: earthOrigin.x + 49 + pose.bodyX, y: earthOrigin.y + 42 + pose.bodyY + pose.eyeY)
        .rotationEffect(.degrees(pose.bodyAngle))
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

    private var leftArmRows: [String] {
        [
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

    private var rightArmRows: [String] {
        [
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

    private var sparkleRows: [String] {
        [
            "Y...Y",
            ".Y.Y.",
            "..Y..",
            ".Y.Y.",
            "Y...Y"
        ]
    }

    private var sunRows: [String] {
        [
            "..Y..",
            ".YYY.",
            "YYYYY",
            ".YYY.",
            "..Y.."
        ]
    }

    private var moonRows: [String] {
        [
            ".LL.",
            "L...",
            "L...",
            ".LL."
        ]
    }

    private var sleepRows: [String] {
        [
            "LLL.",
            "..L.",
            ".L..",
            "LLL."
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

private struct MascotPose {
    let date: Date
    let mood: TimeMood

    private var t: Double {
        date.timeIntervalSinceReferenceDate
    }

    private var slot: Int {
        Int(t / 5.0)
    }

    private var beat: Double {
        t * Double.pi * 2.0
    }

    private var routine: Routine {
        let routines = mood.routines
        return routines[abs(slot) % routines.count]
    }

    var bodyX: CGFloat {
        switch routine {
        case .hop, .dance:
            return CGFloat(sin(beat * 0.50)) * 3
        case .lookAround:
            return CGFloat(sin(beat * 0.18)) * 4
        case .dream:
            return CGFloat(sin(beat * 0.14)) * 2
        default:
            return CGFloat(sin(beat * 0.12)) * 1.2
        }
    }

    var bodyY: CGFloat {
        switch routine {
        case .hop:
            return -abs(CGFloat(sin(beat * 0.50))) * 10
        case .dance:
            return CGFloat(sin(beat * 0.75)) * 4 - 2
        case .stretch:
            return CGFloat(sin(beat * 0.20)) * -5
        case .sleep, .dream:
            return CGFloat(sin(beat * 0.10)) * 2
        default:
            return CGFloat(sin(beat * 0.18)) * 2
        }
    }

    var bodyAngle: Double {
        switch routine {
        case .dance:
            return sin(beat * 0.45) * 5
        case .lookAround:
            return sin(beat * 0.18) * 4
        case .sleep, .dream:
            return sin(beat * 0.08) * 2
        default:
            return sin(beat * 0.13) * 1.5
        }
    }

    var squash: CGFloat {
        switch routine {
        case .hop:
            return 1.0 + abs(CGFloat(sin(beat * 0.50))) * 0.05
        case .stretch:
            return 0.94
        default:
            return 1.0
        }
    }

    var stretch: CGFloat {
        switch routine {
        case .stretch:
            return 1.10 + CGFloat(sin(beat * 0.20)) * 0.03
        case .hop:
            return 1.0 - abs(CGFloat(sin(beat * 0.50))) * 0.04
        case .sleep, .dream:
            return 0.98 + CGFloat(sin(beat * 0.10)) * 0.02
        default:
            return 1.0 + CGFloat(sin(beat * 0.16)) * 0.01
        }
    }

    var leftArmX: CGFloat {
        routine == .stretch ? -4 : 0
    }

    var leftArmY: CGFloat {
        switch routine {
        case .stretch:
            return -8
        case .dance:
            return CGFloat(sin(beat * 0.60)) * 5
        case .sleep:
            return 4
        default:
            return CGFloat(sin(beat * 0.22)) * 2
        }
    }

    var rightArmX: CGFloat {
        routine == .wave || routine == .starToss ? 2 : 0
    }

    var rightArmY: CGFloat {
        switch routine {
        case .wave:
            return CGFloat(sin(beat * 0.80)) * 7 - 4
        case .starToss:
            return -8 + CGFloat(sin(beat * 0.55)) * 5
        case .stretch:
            return -12
        case .sleep:
            return 3
        default:
            return CGFloat(cos(beat * 0.18)) * 2
        }
    }

    var leftArmAngle: Double {
        switch routine {
        case .dance:
            return -10 + sin(beat * 0.60) * 14
        case .stretch:
            return -20
        case .sleep:
            return 10
        default:
            return sin(beat * 0.25) * 7
        }
    }

    var rightArmAngle: Double {
        switch routine {
        case .wave:
            return -22 + sin(beat * 0.85) * 22
        case .starToss:
            return -30 + sin(beat * 0.55) * 14
        case .stretch:
            return -26
        case .dance:
            return 14 + sin(beat * 0.55) * 14
        default:
            return sin(beat * 0.22) * 8
        }
    }

    var leftFootX: CGFloat {
        routine == .dance ? CGFloat(sin(beat * 0.50)) * 3 : 0
    }

    var rightFootX: CGFloat {
        routine == .dance ? CGFloat(cos(beat * 0.50)) * 3 : 0
    }

    var footY: CGFloat {
        routine == .hop ? abs(CGFloat(sin(beat * 0.50))) * -3 : 0
    }

    var altFootY: CGFloat {
        routine == .dance ? CGFloat(sin(beat * 0.50)) * 3 : footY
    }

    var leftFootAngle: Double {
        routine == .dance ? sin(beat * 0.50) * 8 : 0
    }

    var rightFootAngle: Double {
        routine == .dance ? cos(beat * 0.50) * 8 : 0
    }

    var starX: CGFloat {
        switch routine {
        case .starToss:
            return CGFloat(sin(beat * 0.50)) * 9
        case .dance:
            return CGFloat(cos(beat * 0.40)) * 3
        default:
            return 0
        }
    }

    var starY: CGFloat {
        switch routine {
        case .starToss:
            return -abs(CGFloat(sin(beat * 0.50))) * 15
        case .sleep, .dream:
            return CGFloat(sin(beat * 0.12)) * 2
        default:
            return CGFloat(sin(beat * 0.25)) * 2
        }
    }

    var starScale: CGFloat {
        switch routine {
        case .starToss, .dance:
            return 1.0 + abs(CGFloat(sin(beat * 0.50))) * 0.22
        case .sleep:
            return 0.84
        default:
            return 1.0 + CGFloat(sin(beat * 0.18)) * 0.06
        }
    }

    var starAngle: Double {
        switch routine {
        case .starToss, .dance:
            return t * 90.0
        default:
            return sin(beat * 0.15) * 8
        }
    }

    var eyeRows: [String] {
        if Int(t * 3.0) % 31 == 0 {
            return ["DD"]
        }

        switch routine {
        case .sleep:
            return ["...", "DDD"]
        case .dream:
            return [".D.", "D.D"]
        case .dance, .hop:
            return ["D.D", ".D."]
        default:
            return ["DD", "DD", "DD", "DD"]
        }
    }

    var eyeSpacing: CGFloat {
        routine == .lookAround ? 24 + CGFloat(sin(beat * 0.18)) * 2 : 22
    }

    var eyeY: CGFloat {
        routine == .sleep ? 3 : 0
    }

    var accessory: Accessory {
        switch routine {
        case .sparkle: return .sparkle
        case .sunSalute: return .sun
        case .sleep: return .sleep
        case .dream: return .moon
        default: return .none
        }
    }

    var sparkleX: CGFloat {
        CGFloat(sin(beat * 0.20)) * 5
    }

    var sparkleY: CGFloat {
        CGFloat(cos(beat * 0.18)) * 4
    }

    var dotCount: Int {
        switch mood {
        case .night, .lateNight: return 7
        case .dawn, .evening: return 4
        default: return routine == .dance || routine == .sparkle ? 5 : 2
        }
    }

    var dotColor: Color {
        switch mood {
        case .night, .lateNight: return MascotPalette.moon
        case .evening: return MascotPalette.spark
        default: return MascotPalette.cloud
        }
    }

    func dotOpacity(index: Int) -> Double {
        0.18 + abs(sin(t * 0.9 + Double(index))) * 0.30
    }

    func dotPosition(index: Int) -> CGPoint {
        let seed = Double(index * 37 + slot % 11)
        let x = 8 + CGFloat((seed * 13).truncatingRemainder(dividingBy: 118))
        let baseY = CGFloat((seed * 7).truncatingRemainder(dividingBy: 44))
        let y = 8 + baseY + CGFloat(sin(t * 0.45 + seed)) * 4
        return CGPoint(x: x, y: y)
    }
}

private enum Routine {
    case breathe
    case stretch
    case wave
    case hop
    case dance
    case lookAround
    case starToss
    case sparkle
    case sunSalute
    case sleep
    case dream
}

private enum Accessory {
    case none
    case sparkle
    case sun
    case moon
    case sleep
}

private extension TimeMood {
    var routines: [Routine] {
        switch self {
        case .dawn:
            return [.sleep, .stretch, .sunSalute, .breathe, .wave, .lookAround, .sparkle, .hop]
        case .morning:
            return [.stretch, .wave, .hop, .breathe, .starToss, .lookAround, .dance, .sparkle]
        case .noon:
            return [.hop, .dance, .starToss, .wave, .sparkle, .breathe, .lookAround, .hop]
        case .afternoon:
            return [.breathe, .lookAround, .wave, .starToss, .stretch, .dance, .sparkle, .hop]
        case .evening:
            return [.wave, .breathe, .lookAround, .sparkle, .stretch, .starToss, .dance, .breathe]
        case .night:
            return [.breathe, .sleep, .dream, .lookAround, .wave, .sparkle, .sleep, .dream]
        case .lateNight:
            return [.sleep, .dream, .breathe, .sleep, .dream, .lookAround, .sleep, .sparkle]
        }
    }
}

private enum MascotPalette {
    static let dark = Color(red: 0.03, green: 0.14, blue: 0.40)
    static let ocean = Color(red: 0.24, green: 0.55, blue: 0.91)
    static let land = Color(red: 0.56, green: 0.74, blue: 0.39)
    static let star = Color(red: 0.94, green: 0.22, blue: 0.16)
    static let spark = Color(red: 1.0, green: 0.82, blue: 0.25)
    static let moon = Color(red: 0.78, green: 0.86, blue: 1.0)
    static let cloud = Color.white

    static func color(for symbol: Character) -> Color? {
        switch symbol {
        case "D": dark
        case "B": ocean
        case "G": land
        case "R": star
        case "Y": spark
        case "L": moon
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
