import Foundation
import SwiftUI

struct MascotView: View {
    let date: Date
    let mood: TimeMood

    private let pixel: CGFloat = 4
    private let canvasSize = CGSize(width: 138, height: 156)

    var body: some View {
        let pose = MascotPose(date: date, mood: mood)

        ZStack(alignment: .topLeading) {
            ambientDots(pose: pose)
            characterGroup(pose: pose)
                .scaleEffect(x: pose.squash, y: pose.stretch, anchor: .bottom)
                .rotationEffect(.degrees(pose.bodyAngle), anchor: .bottom)
                .offset(x: pose.bodyX, y: pose.bodyY)
        }
        .frame(width: canvasSize.width, height: canvasSize.height, alignment: .topLeading)
        .clipped()
    }

    private func characterGroup(pose: MascotPose) -> some View {
        ZStack(alignment: .topLeading) {
            pixelLayer(rows: pose.leftLegRows, origin: CGPoint(x: 51 + pose.leftFootX, y: 103 + pose.leftFootY))
                .rotationEffect(.degrees(pose.leftFootAngle), anchor: .top)
            pixelLayer(rows: pose.rightLegRows, origin: CGPoint(x: 78 + pose.rightFootX, y: 103 + pose.rightFootY))
                .rotationEffect(.degrees(pose.rightFootAngle), anchor: .top)

            pixelLayer(rows: pose.leftArmRows, origin: CGPoint(x: 7 + pose.leftArmX, y: 74 + pose.leftArmY))
                .rotationEffect(.degrees(pose.leftArmAngle), anchor: .trailing)
            pixelLayer(rows: pose.rightArmRows, origin: CGPoint(x: 97 + pose.rightArmX, y: 56 + pose.rightArmY))
                .rotationEffect(.degrees(pose.rightArmAngle), anchor: .leading)

            pixelLayer(rows: earthRows, origin: CGPoint(x: 23, y: 34))
                .shadow(color: .black.opacity(mood == .night || mood == .lateNight ? 0.28 : 0.16), radius: 0, x: 3, y: 3)

            eyes(pose: pose)

            pixelLayer(rows: starRows, origin: CGPoint(x: 111 + pose.starX, y: 30 + pose.starY))
                .scaleEffect(pose.starScale, anchor: .center)
                .rotationEffect(.degrees(pose.starAngle))

            accessory(pose: pose)
        }
        .frame(width: canvasSize.width, height: canvasSize.height, alignment: .topLeading)
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
            pixelLayer(rows: sparkleRows, origin: CGPoint(x: 96 + pose.sparkleX, y: 15 + pose.sparkleY))
        case .sun:
            pixelLayer(rows: sunRows, origin: CGPoint(x: 10 + pose.sparkleX, y: 11 + pose.sparkleY))
        case .moon:
            pixelLayer(rows: moonRows, origin: CGPoint(x: 11 + pose.sparkleX, y: 14 + pose.sparkleY))
        case .sleep:
            pixelLayer(rows: sleepRows, origin: CGPoint(x: 99 + pose.sparkleX, y: 18 + pose.sparkleY))
        case .orbit:
            pixelLayer(rows: orbitRows, origin: CGPoint(x: 13 + pose.sparkleX, y: 96 + pose.sparkleY))
        case .rain:
            pixelLayer(rows: rainRows, origin: CGPoint(x: 10 + pose.sparkleX, y: 12 + pose.sparkleY))
        case .none:
            EmptyView()
        }
    }

    private func pixelLayer(rows: [String], origin: CGPoint) -> some View {
        PixelGrid(rows: rows, pixelSize: pixel)
            .offset(x: origin.x, y: origin.y)
    }

    private func eyes(pose: MascotPose) -> some View {
        ZStack(alignment: .topLeading) {
            PixelGrid(rows: pose.eyeRows, pixelSize: pixel)
                .offset(x: 58 + pose.eyeLookX, y: 62 + pose.eyeY)
            PixelGrid(rows: pose.eyeRows, pixelSize: pixel)
                .offset(x: 87 + pose.eyeLookX, y: 62 + pose.eyeY)
        }
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

    private var orbitRows: [String] {
        [
            "....Y",
            "..Y..",
            "Y...."
        ]
    }

    private var rainRows: [String] {
        [
            "L...L...L",
            ".L...L...",
            "...L...L."
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
        Int(t / 4.0)
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
        case .hop, .dance, .march:
            return CGFloat(sin(beat * 0.50)) * 3
        case .lookAround, .orbit:
            return CGFloat(sin(beat * 0.18)) * 4
        case .sway:
            return CGFloat(sin(beat * 0.22)) * 5
        case .dream:
            return CGFloat(sin(beat * 0.14)) * 2
        case .shake:
            return CGFloat(sin(beat * 1.50)) * 2
        case .twirl:
            return CGFloat(sin(beat * 0.70)) * 4
        case .moonWalk:
            return CGFloat(sin(beat * 0.38)) * 6
        case .float:
            return CGFloat(sin(beat * 0.10)) * 3
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
        case .peek:
            return CGFloat(sin(beat * 0.18)) * 3 + 2
        case .cheer:
            return -abs(CGFloat(sin(beat * 0.55))) * 7
        case .float:
            return CGFloat(sin(beat * 0.12)) * 5 - 4
        case .sleep, .dream:
            return CGFloat(sin(beat * 0.10)) * 2
        default:
            return CGFloat(sin(beat * 0.18)) * 2
        }
    }

    var bodyAngle: Double {
        switch routine {
        case .dance, .march:
            return sin(beat * 0.45) * 5
        case .lookAround:
            return sin(beat * 0.18) * 4
        case .sway:
            return sin(beat * 0.18) * 7
        case .sleep, .dream:
            return sin(beat * 0.08) * 2
        case .shake:
            return sin(beat * 1.50) * 3
        case .twirl:
            return sin(beat * 0.70) * 10
        case .moonWalk:
            return sin(beat * 0.32) * -5
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
        case .sleep:
            return 1.04
        case .cheer:
            return 0.96 + abs(CGFloat(sin(beat * 0.55))) * 0.06
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
        case .cheer:
            return 1.06 - abs(CGFloat(sin(beat * 0.55))) * 0.04
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
            return -9
        case .dance, .clap:
            return CGFloat(sin(beat * 0.60)) * 5
        case .peek:
            return -4
        case .cheer:
            return -14
        case .kick:
            return CGFloat(sin(beat * 0.45)) * 3
        case .sleep:
            return 4
        default:
            return CGFloat(sin(beat * 0.22)) * 2
        }
    }

    var rightArmX: CGFloat {
        switch routine {
        case .wave, .starToss: return 2
        case .clap: return -3
        case .cheer: return 1
        default: return 0
        }
    }

    var rightArmY: CGFloat {
        switch routine {
        case .wave:
            return CGFloat(sin(beat * 0.80)) * 7 - 4
        case .starToss:
            return -8 + CGFloat(sin(beat * 0.55)) * 5
        case .stretch:
            return -12
        case .clap:
            return CGFloat(cos(beat * 0.70)) * 5
        case .cheer:
            return -16
        case .kick:
            return CGFloat(cos(beat * 0.45)) * 3
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
        case .clap:
            return -18 + sin(beat * 0.70) * 15
        case .stretch:
            return -20
        case .peek:
            return -28
        case .cheer:
            return -36 + sin(beat * 0.55) * 10
        case .twirl:
            return sin(beat * 0.70) * 26
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
        case .clap:
            return 18 - sin(beat * 0.70) * 15
        case .cheer:
            return 36 - sin(beat * 0.55) * 10
        case .twirl:
            return -sin(beat * 0.70) * 26
        default:
            return sin(beat * 0.22) * 8
        }
    }

    var leftFootX: CGFloat {
        switch routine {
        case .dance, .march, .moonWalk:
            return CGFloat(sin(beat * 0.50)) * 3
        case .kick:
            return -3
        default:
            return 0
        }
    }

    var rightFootX: CGFloat {
        switch routine {
        case .dance, .march, .moonWalk:
            return CGFloat(cos(beat * 0.50)) * 3
        case .kick:
            return abs(CGFloat(sin(beat * 0.55))) * 13
        default:
            return 0
        }
    }

    var leftFootY: CGFloat {
        switch routine {
        case .hop:
            return abs(CGFloat(sin(beat * 0.50))) * -3
        case .march:
            return max(0, CGFloat(sin(beat * 0.55))) * -4
        case .moonWalk:
            return CGFloat(sin(beat * 0.40)) * 2
        default:
            return 0
        }
    }

    var rightFootY: CGFloat {
        switch routine {
        case .dance:
            return CGFloat(sin(beat * 0.50)) * 3
        case .march:
            return max(0, CGFloat(cos(beat * 0.55))) * -4
        case .kick:
            return -abs(CGFloat(sin(beat * 0.55))) * 8
        case .moonWalk:
            return CGFloat(cos(beat * 0.40)) * 2
        default:
            return leftFootY
        }
    }

    var leftFootAngle: Double {
        routine == .dance || routine == .march || routine == .moonWalk ? sin(beat * 0.50) * 8 : 0
    }

    var rightFootAngle: Double {
        switch routine {
        case .kick:
            return -28 * abs(sin(beat * 0.55))
        case .dance, .march, .moonWalk:
            return cos(beat * 0.50) * 8
        default:
            return 0
        }
    }

    var starX: CGFloat {
        switch routine {
        case .starToss:
            return CGFloat(sin(beat * 0.50)) * 9
        case .orbit:
            return CGFloat(cos(beat * 0.28)) * 15 - 6
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
        case .orbit:
            return CGFloat(sin(beat * 0.28)) * 10
        case .sleep, .dream:
            return CGFloat(sin(beat * 0.12)) * 2
        default:
            return CGFloat(sin(beat * 0.25)) * 2
        }
    }

    var starScale: CGFloat {
        switch routine {
        case .starToss, .dance, .orbit:
            return 1.0 + abs(CGFloat(sin(beat * 0.50))) * 0.22
        case .sleep:
            return 0.84
        default:
            return 1.0 + CGFloat(sin(beat * 0.18)) * 0.06
        }
    }

    var starAngle: Double {
        switch routine {
        case .starToss, .dance, .orbit:
            return t * 90.0
        default:
            return sin(beat * 0.15) * 8
        }
    }

    var eyeRows: [String] {
        if Int(t * 3.0) % 37 == 0 {
            return ["DD"]
        }

        switch routine {
        case .sleep:
            return ["..", "DD"]
        case .dream:
            return [".D", "D.", ".D", "D."]
        case .wink:
            return ["DD"]
        default:
            return ["DD", "DD", "DD", "DD", "DD"]
        }
    }

    var eyeLookX: CGFloat {
        switch routine {
        case .lookAround, .peek:
            return CGFloat(sin(beat * 0.18)) * 2
        default:
            return 0
        }
    }

    var eyeY: CGFloat {
        switch routine {
        case .sleep:
            return 5
        case .stretch:
            return -2
        default:
            return 0
        }
    }

    var accessory: Accessory {
        switch routine {
        case .sparkle, .clap: return .sparkle
        case .sunSalute: return .sun
        case .sleep: return .sleep
        case .dream: return .moon
        case .orbit: return .orbit
        case .rainDance: return .rain
        case .cheer, .twirl: return .sparkle
        default: return .none
        }
    }

    var leftArmRows: [String] {
        switch routine {
        case .cheer:
            return [
                "....DD.",
                "...DD..",
                "..DD...",
                ".DD....",
                "DD.....",
                "DD.....",
                ".DD....",
                "..DD..."
            ]
        case .clap:
            return [
                ".....DD",
                "....DDD",
                "...DD.",
                "..DD..",
                ".DD...",
                ".DD...",
                "..DD.."
            ]
        case .stretch:
            return [
                "....DD.",
                "...DD..",
                "..DD...",
                ".DD....",
                "DD.....",
                ".DD....",
                "..DD..."
            ]
        case .peek:
            return [
                "....DD",
                "...DDD",
                "..DD..",
                ".DD...",
                ".DD...",
                "..DD.."
            ]
        case .twirl, .dance:
            return [
                "....DD",
                "...DD.",
                "..DD..",
                ".DDD..",
                "DD.D..",
                ".DDD..",
                "..DD.."
            ]
        default:
            return [
                "....DD",
                "...DDD",
                "..DD..",
                ".DD...",
                "DD....",
                "DD....",
                ".DD..."
            ]
        }
    }

    var rightArmRows: [String] {
        switch routine {
        case .cheer:
            return [
                ".DD....",
                "..DD...",
                "...DD..",
                "....DD.",
                ".....DD",
                ".....DD",
                "....DD.",
                "...DD.."
            ]
        case .wave, .starToss:
            return [
                "DD....",
                "DDD...",
                "..DD..",
                "...DD.",
                "....DD",
                "...DD.",
                "..DD..",
                ".DD..."
            ]
        case .clap:
            return [
                "DD....",
                "DDD...",
                ".DD...",
                "..DD..",
                "...DD.",
                "...DD.",
                "..DD.."
            ]
        case .stretch:
            return [
                ".DD...",
                "..DD..",
                "...DD.",
                "....DD",
                ".....DD",
                "....DD",
                "...DD."
            ]
        case .twirl, .dance:
            return [
                "DD....",
                ".DD...",
                "..DD..",
                "..DDD.",
                "..D.DD",
                "..DDD.",
                "..DD.."
            ]
        default:
            return [
                "DD....",
                "DDD...",
                "..DD..",
                "...DD.",
                "....DD",
                "....DD",
                "...DD."
            ]
        }
    }

    var leftLegRows: [String] {
        switch routine {
        case .moonWalk:
            return [
                ".DD.",
                ".DD.",
                "DD..",
                "DD..",
                "DDD.",
                ".DDD",
                "..DD"
            ]
        case .dance, .march:
            return [
                ".DD.",
                ".DD.",
                "..DD",
                "..DD",
                ".DDD",
                "DDD."
            ]
        case .sleep:
            return [
                ".DD.",
                ".DD.",
                "DDD.",
                "DDDD"
            ]
        default:
            return [
                ".DD.",
                ".DD.",
                ".DD.",
                "DD..",
                "DDDD",
                "DDDD"
            ]
        }
    }

    var rightLegRows: [String] {
        switch routine {
        case .kick:
            return [
                ".DD...",
                ".DDD..",
                "..DDD.",
                "...DDD",
                "...DDD"
            ]
        case .moonWalk:
            return [
                ".DD.",
                ".DD.",
                "..DD",
                "..DD",
                ".DDD",
                "DDD.",
                "DD.."
            ]
        case .dance, .march:
            return [
                ".DD.",
                ".DD.",
                "DD..",
                "DD..",
                "DDD.",
                ".DDD"
            ]
        case .sleep:
            return [
                ".DD.",
                ".DD.",
                ".DDD",
                "DDDD"
            ]
        default:
            return [
                ".DD.",
                ".DD.",
                ".DD.",
                "..DD",
                "DDDD",
                "DDDD"
            ]
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
        default: return routine == .dance || routine == .sparkle || routine == .rainDance || routine == .cheer ? 5 : 2
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
    case march
    case clap
    case orbit
    case wink
    case sway
    case peek
    case shake
    case rainDance
    case kick
    case cheer
    case twirl
    case moonWalk
    case float
}

private enum Accessory {
    case none
    case sparkle
    case sun
    case moon
    case sleep
    case orbit
    case rain
}

private extension TimeMood {
    var routines: [Routine] {
        switch self {
        case .dawn:
            return [.sleep, .stretch, .sunSalute, .breathe, .wave, .lookAround, .sparkle, .hop, .wink, .sway, .peek, .float]
        case .morning:
            return [.stretch, .wave, .hop, .breathe, .starToss, .lookAround, .dance, .sparkle, .march, .clap, .orbit, .wink, .kick, .cheer]
        case .noon:
            return [.hop, .dance, .starToss, .wave, .sparkle, .breathe, .lookAround, .march, .clap, .shake, .orbit, .rainDance, .kick, .cheer, .twirl]
        case .afternoon:
            return [.breathe, .lookAround, .wave, .starToss, .stretch, .dance, .sparkle, .hop, .sway, .march, .peek, .wink, .moonWalk, .kick]
        case .evening:
            return [.wave, .breathe, .lookAround, .sparkle, .stretch, .starToss, .dance, .sway, .clap, .orbit, .dream, .twirl, .moonWalk]
        case .night:
            return [.breathe, .sleep, .dream, .lookAround, .wave, .sparkle, .sleep, .dream, .sway, .wink, .float]
        case .lateNight:
            return [.sleep, .dream, .breathe, .sleep, .dream, .lookAround, .sleep, .sparkle, .sway, .float]
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
