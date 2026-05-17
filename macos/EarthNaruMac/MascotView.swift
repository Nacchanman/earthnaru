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
            pixelLayer(rows: pose.leftLegRows, origin: CGPoint(x: 54 + pose.leftFootX, y: 101 + pose.leftFootY))
                .rotationEffect(.degrees(pose.leftFootAngle), anchor: .top)
            pixelLayer(rows: pose.rightLegRows, origin: CGPoint(x: 75 + pose.rightFootX, y: 101 + pose.rightFootY))
                .rotationEffect(.degrees(pose.rightFootAngle), anchor: .top)

            pixelLayer(rows: pose.leftArmRows, origin: CGPoint(x: 17 + pose.leftArmX, y: 72 + pose.leftArmY))
                .rotationEffect(.degrees(pose.leftArmAngle), anchor: .trailing)
            pixelLayer(rows: pose.rightArmRows, origin: CGPoint(x: 89 + pose.rightArmX, y: 56 + pose.rightArmY))
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
        Int(t / 7.0)
    }

    private var beat: Double {
        t * Double.pi * 2.0
    }

    private var routine: Routine {
        let routines = mood.routines
        return routines[abs(slot) % routines.count]
    }

    private var phase: Double {
        let value = t.truncatingRemainder(dividingBy: 7.0) / 7.0
        return value < 0 ? value + 1.0 : value
    }

    private var calmBreath: Double {
        sin(beat * 0.10)
    }

    private var liveliness: Double {
        switch mood {
        case .dawn, .night, .lateNight:
            return 0.7
        case .evening:
            return 0.85
        case .morning, .noon, .afternoon:
            return 1.0
        }
    }

    private func smooth(_ x: Double) -> Double {
        let clamped = min(max(x, 0.0), 1.0)
        return clamped * clamped * (3.0 - 2.0 * clamped)
    }

    private func pulse(center: Double, width: Double) -> Double {
        let distance = abs(phase - center)
        return smooth(1.0 - distance / width)
    }

    private func wave(start: Double, end: Double) -> Double {
        smooth((phase - start) / (end - start))
    }

    private var gesture: Gesture {
        switch routine {
        case .breathe, .sparkle:
            return .settle
        case .stretch, .sunSalute:
            return .stretch
        case .wave, .wink:
            return .wave
        case .hop, .cheer:
            return .bounce
        case .dance, .clap, .twirl:
            return .dance
        case .lookAround, .peek:
            return .curious
        case .starToss, .orbit:
            return .admire
        case .sleep:
            return .sleep
        case .dream, .float:
            return .dream
        case .march, .moonWalk:
            return .step
        case .sway:
            return .sway
        case .rainDance:
            return .rainShuffle
        case .kick, .shake:
            return .playfulStep
        }
    }

    private var weightShift: Double {
        switch gesture {
        case .settle:
            return sin(beat * 0.08) * 0.35
        case .curious:
            return sin(phase * Double.pi * 2.0) * 0.85
        case .wave:
            return 0.35 + pulse(center: 0.46, width: 0.30) * 0.25
        case .bounce:
            return sin(phase * Double.pi * 2.0) * 0.25
        case .stretch:
            return sin(phase * Double.pi) * 0.30
        case .step, .rainShuffle, .playfulStep:
            return sin(phase * Double.pi * 2.0) * 0.95
        case .dance:
            return sin(phase * Double.pi * 4.0) * 0.75
        case .admire:
            return 0.45 + sin(beat * 0.10) * 0.15
        case .sway:
            return sin(beat * 0.12) * 1.0
        case .sleep, .dream:
            return sin(beat * 0.055) * 0.25
        }
    }

    var bodyX: CGFloat {
        let base = calmBreath * 0.8
        let weight = weightShift * 2.6 * liveliness
        let accent: Double
        switch gesture {
        case .curious:
            accent = pulse(center: 0.36, width: 0.18) * -2.0 + pulse(center: 0.68, width: 0.20) * 2.0
        case .dance:
            accent = sin(phase * Double.pi * 6.0) * 1.2
        case .dream:
            accent = sin(beat * 0.08) * 2.4
        default:
            accent = 0
        }
        return CGFloat(base + weight + accent)
    }

    var bodyY: CGFloat {
        let breath = calmBreath * 1.5
        switch gesture {
        case .bounce:
            let crouch = pulse(center: 0.18, width: 0.14)
            let lift = pulse(center: 0.44, width: 0.20)
            let settle = pulse(center: 0.72, width: 0.16)
            return CGFloat(breath + crouch * 3.5 - lift * 8.5 + settle * 2.2)
        case .dance:
            return CGFloat(breath + sin(phase * Double.pi * 4.0) * 2.8 - pulse(center: 0.42, width: 0.18) * 3.0)
        case .stretch:
            return CGFloat(breath - wave(start: 0.12, end: 0.46) * 6.0 + wave(start: 0.70, end: 0.96) * 5.0)
        case .step, .rainShuffle, .playfulStep:
            return CGFloat(breath - abs(sin(phase * Double.pi * 2.0)) * 1.8)
        case .sleep:
            return CGFloat(2.5 + sin(beat * 0.055) * 1.4)
        case .dream:
            return CGFloat(-2.5 + sin(beat * 0.07) * 3.5)
        default:
            return CGFloat(breath)
        }
    }

    var bodyAngle: Double {
        switch gesture {
        case .curious:
            return weightShift * 4.5
        case .wave, .admire:
            return 2.5 + sin(beat * 0.10) * 1.0
        case .dance:
            return sin(phase * Double.pi * 4.0) * 5.2
        case .step, .rainShuffle, .playfulStep:
            return weightShift * 3.4
        case .stretch:
            return sin(phase * Double.pi) * 2.0
        case .sleep:
            return -3.0 + sin(beat * 0.055) * 1.0
        case .dream:
            return sin(beat * 0.07) * 2.4
        case .sway:
            return weightShift * 5.0
        default:
            return calmBreath * 1.2
        }
    }

    var squash: CGFloat {
        switch gesture {
        case .bounce:
            return CGFloat(1.0 + pulse(center: 0.18, width: 0.14) * 0.06 - pulse(center: 0.44, width: 0.20) * 0.03)
        case .stretch:
            return CGFloat(1.0 - wave(start: 0.12, end: 0.46) * 0.06 + wave(start: 0.70, end: 0.96) * 0.05)
        case .sleep:
            return CGFloat(1.03 + sin(beat * 0.055) * 0.01)
        case .dance:
            return CGFloat(1.0 + abs(sin(phase * Double.pi * 4.0)) * 0.025)
        default:
            return CGFloat(1.0 + calmBreath * 0.008)
        }
    }

    var stretch: CGFloat {
        switch gesture {
        case .bounce:
            return CGFloat(1.0 - pulse(center: 0.18, width: 0.14) * 0.045 + pulse(center: 0.44, width: 0.20) * 0.04)
        case .stretch:
            return CGFloat(1.0 + wave(start: 0.12, end: 0.46) * 0.08 - wave(start: 0.70, end: 0.96) * 0.06)
        case .sleep:
            return CGFloat(0.98 + sin(beat * 0.055) * 0.012)
        case .dream:
            return CGFloat(1.0 + sin(beat * 0.07) * 0.02)
        default:
            return CGFloat(1.0 - calmBreath * 0.008)
        }
    }

    var leftArmX: CGFloat {
        switch gesture {
        case .stretch:
            return 0
        case .dance:
            return CGFloat(-weightShift * 0.7)
        case .sleep:
            return 1
        default:
            return 0
        }
    }

    var leftArmY: CGFloat {
        switch gesture {
        case .stretch:
            return CGFloat(-3 * wave(start: 0.12, end: 0.44) + 3 * wave(start: 0.72, end: 0.96))
        case .dance:
            return CGFloat(calmBreath * 0.8 + sin(phase * Double.pi * 4.0 + 0.8) * 0.9)
        case .sleep:
            return 2
        case .rainShuffle:
            return CGFloat(1 + sin(phase * Double.pi * 4.0) * 0.8)
        default:
            return CGFloat(calmBreath * 0.6)
        }
    }

    var rightArmX: CGFloat {
        switch gesture {
        case .wave, .admire:
            return 0
        case .dance:
            return CGFloat(-weightShift * 0.7)
        case .sleep:
            return -1
        default:
            return 0
        }
    }

    var rightArmY: CGFloat {
        switch gesture {
        case .wave:
            return CGFloat(-2 + sin(phase * Double.pi * 5.0) * 1.0)
        case .admire:
            return CGFloat(-3 + pulse(center: 0.42, width: 0.30) * -1.5)
        case .stretch:
            return CGFloat(-4 * wave(start: 0.12, end: 0.44) + 4 * wave(start: 0.72, end: 0.96))
        case .dance:
            return CGFloat(calmBreath * 0.8 + cos(phase * Double.pi * 4.0 + 0.6) * 0.9)
        case .sleep:
            return 2
        case .rainShuffle:
            return CGFloat(1 + cos(phase * Double.pi * 4.0) * 0.8)
        default:
            return CGFloat(calmBreath * 0.6)
        }
    }

    var leftArmAngle: Double {
        switch gesture {
        case .stretch:
            return -2 - wave(start: 0.12, end: 0.44) * 4 + wave(start: 0.72, end: 0.96) * 4
        case .curious:
            return -1 + weightShift * -1.5
        case .dance:
            return -2 + sin(phase * Double.pi * 4.0 + 0.4) * 2.5
        case .rainShuffle:
            return -1 + sin(phase * Double.pi * 4.0) * 2
        case .sleep:
            return 3
        case .dream:
            return sin(beat * 0.07) * 2
        default:
            return calmBreath * 1.5
        }
    }

    var rightArmAngle: Double {
        switch gesture {
        case .wave:
            return -7 + sin(phase * Double.pi * 5.0) * 4
        case .admire:
            return -7 + pulse(center: 0.42, width: 0.30) * -3 + sin(beat * 0.10)
        case .stretch:
            return -3 - wave(start: 0.12, end: 0.44) * 5 + wave(start: 0.72, end: 0.96) * 5
        case .dance:
            return 2 + cos(phase * Double.pi * 4.0 + 0.4) * 2.5
        case .rainShuffle:
            return 1 + cos(phase * Double.pi * 4.0) * 2
        case .sleep:
            return -3
        case .dream:
            return sin(beat * 0.07 + 1.2) * 2
        default:
            return calmBreath * 1.5
        }
    }

    var leftFootX: CGFloat {
        switch gesture {
        case .step, .rainShuffle:
            return CGFloat(min(0, sin(phase * Double.pi * 2.0)) * 1.2)
        case .playfulStep:
            return CGFloat(-pulse(center: 0.36, width: 0.18) * 1.0)
        case .dance:
            return CGFloat(sin(phase * Double.pi * 4.0) * 0.8)
        case .sleep:
            return 1
        default:
            return 0
        }
    }

    var rightFootX: CGFloat {
        switch gesture {
        case .step, .rainShuffle:
            return CGFloat(max(0, sin(phase * Double.pi * 2.0)) * 1.2)
        case .playfulStep:
            return CGFloat(pulse(center: 0.42, width: 0.22) * 1.0)
        case .dance:
            return CGFloat(cos(phase * Double.pi * 4.0) * 0.8)
        case .sleep:
            return -1
        default:
            return 0
        }
    }

    var leftFootY: CGFloat {
        switch gesture {
        case .bounce:
            return CGFloat(-pulse(center: 0.44, width: 0.20) * 1.2)
        case .step:
            return CGFloat(max(0, -sin(phase * Double.pi * 2.0)) * -1.4)
        case .rainShuffle:
            return CGFloat(max(0, -sin(phase * Double.pi * 2.0)) * -0.8)
        case .dance:
            return CGFloat(max(0, sin(phase * Double.pi * 4.0)) * -1.0)
        case .sleep:
            return 1
        default:
            return 0
        }
    }

    var rightFootY: CGFloat {
        switch gesture {
        case .bounce:
            return leftFootY
        case .step:
            return CGFloat(max(0, sin(phase * Double.pi * 2.0)) * -1.4)
        case .rainShuffle:
            return CGFloat(max(0, sin(phase * Double.pi * 2.0)) * -0.8)
        case .dance:
            return CGFloat(max(0, -sin(phase * Double.pi * 4.0)) * -1.0)
        case .playfulStep:
            return CGFloat(-pulse(center: 0.42, width: 0.22) * 1.0)
        case .sleep:
            return 1
        default:
            return 0
        }
    }

    var leftFootAngle: Double {
        switch gesture {
        case .step, .rainShuffle, .dance:
            return -1.0
        case .sleep:
            return 0
        default:
            return 0
        }
    }

    var rightFootAngle: Double {
        switch gesture {
        case .step, .rainShuffle, .dance:
            return 1.0
        case .playfulStep:
            return 1.2
        case .sleep:
            return 0
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
        if Int(t * 3.0) % 41 == 0 {
            return ["DD"]
        }

        switch gesture {
        case .sleep:
            return ["..", "DD"]
        case .dream:
            return [".D", "D.", ".D", "D."]
        case .wave where pulse(center: 0.62, width: 0.08) > 0.7:
            return ["DD"]
        default:
            return ["DD", "DD", "DD", "DD", "DD"]
        }
    }

    var eyeLookX: CGFloat {
        switch gesture {
        case .curious:
            return CGFloat(weightShift * 2.0)
        case .admire, .wave:
            return 1
        default:
            return 0
        }
    }

    var eyeY: CGFloat {
        switch gesture {
        case .sleep:
            return 5
        case .stretch:
            return -2
        case .bounce:
            return CGFloat(-pulse(center: 0.44, width: 0.20) * 1.5)
        default:
            return 0
        }
    }

    var accessory: Accessory {
        switch routine {
        case .sparkle, .clap, .cheer, .twirl:
            return .sparkle
        case .sunSalute:
            return .sun
        case .sleep:
            return .sleep
        case .dream:
            return .moon
        case .orbit, .starToss:
            return .orbit
        case .rainDance:
            return .rain
        default:
            return .none
        }
    }

    var leftArmRows: [String] {
        switch gesture {
        case .stretch:
            return [
                "...DD.",
                "..DD..",
                ".DD...",
                "DD....",
                "DD....",
                ".DD..."
            ]
        case .dance, .rainShuffle:
            return [
                "...DD",
                "..DDD",
                ".DD..",
                "DD...",
                "DD...",
                ".DD.."
            ]
        case .sleep:
            return [
                "..DD",
                ".DDD",
                "DD..",
                "DD..",
                ".DD."
            ]
        case .curious:
            return [
                "...DD",
                "..DDD",
                ".DD..",
                "DD...",
                "DD...",
                ".DD.."
            ]
        case .bounce:
            return [
                "..DD",
                ".DDD",
                "DD..",
                "DD..",
                ".DD."
            ]
        default:
            return [
                "...DD",
                "..DDD",
                ".DD..",
                "DD...",
                "DD...",
                ".DD.."
            ]
        }
    }

    var rightArmRows: [String] {
        switch gesture {
        case .wave, .admire:
            return [
                ".DD...",
                "..DD..",
                "...DD.",
                "....DD",
                "....DD",
                "...DDD",
                ".DD..."
            ]
        case .dance, .rainShuffle:
            return [
                "DD....",
                "..DD..",
                "..DDD.",
                "..D.DD",
                "..DDD.",
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
        case .sleep:
            return [
                "DD...",
                "DDD..",
                "..DD.",
                "..DD.",
                ".DD.."
            ]
        case .bounce:
            return [
                "DD...",
                "DDD..",
                "..DD.",
                "..DDD",
                "...DD",
                "..DD."
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
        switch gesture {
        case .step, .rainShuffle:
            return [
                ".DD.",
                ".DD.",
                ".DD.",
                "DD..",
                "DDD.",
                "DD.."
            ]
        case .dance:
            return [
                ".DD.",
                ".DD.",
                ".DD.",
                "DD..",
                "DDD.",
                "DD.."
            ]
        case .bounce:
            return [
                ".DD.",
                "DDD.",
                "DD..",
                "DDDD"
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
        switch gesture {
        case .step, .rainShuffle:
            return [
                ".DD.",
                ".DD.",
                ".DD.",
                "..DD",
                ".DDD",
                "..DD"
            ]
        case .dance, .playfulStep:
            return [
                ".DD.",
                ".DD.",
                ".DD.",
                "..DD",
                ".DDD",
                "..DD"
            ]
        case .bounce:
            return [
                ".DD.",
                ".DDD",
                "..DD",
                "DDDD"
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
        default: return gesture == .dance || gesture == .rainShuffle || routine == .sparkle || routine == .cheer ? 5 : 2
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

private enum Gesture {
    case settle
    case curious
    case wave
    case bounce
    case stretch
    case step
    case admire
    case dance
    case sway
    case rainShuffle
    case playfulStep
    case sleep
    case dream
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
            return [.sleep, .dream, .stretch, .sunSalute, .breathe, .lookAround, .wave, .sparkle, .sway, .peek, .float, .wink]
        case .morning:
            return [.stretch, .wave, .breathe, .lookAround, .hop, .starToss, .sparkle, .march, .clap, .sway, .wink, .cheer, .orbit]
        case .noon:
            return [.breathe, .hop, .dance, .wave, .starToss, .lookAround, .march, .clap, .sparkle, .rainDance, .cheer, .orbit, .sway]
        case .afternoon:
            return [.breathe, .lookAround, .wave, .starToss, .stretch, .dance, .sparkle, .hop, .sway, .march, .peek, .wink, .float]
        case .evening:
            return [.wave, .breathe, .lookAround, .sparkle, .stretch, .starToss, .sway, .clap, .orbit, .dream, .float, .wink]
        case .night:
            return [.breathe, .sleep, .dream, .lookAround, .wave, .sparkle, .sleep, .dream, .sway, .wink, .float, .orbit]
        case .lateNight:
            return [.sleep, .dream, .breathe, .sleep, .dream, .lookAround, .sleep, .sparkle, .sway, .float, .wink]
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
