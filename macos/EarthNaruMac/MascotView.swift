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

            pixelLayer(rows: pose.leftArmRows, origin: CGPoint(x: 3 + pose.leftArmX, y: 64 + pose.leftArmY))
                .rotationEffect(.degrees(pose.leftArmAngle), anchor: .trailing)
            pixelLayer(rows: pose.rightArmRows, origin: CGPoint(x: 98 + pose.rightArmX, y: 64 + pose.rightArmY))
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

    private var actionEnvelope: Double {
        let edge = 0.18
        return min(smooth(phase / edge), smooth((1.0 - phase) / edge))
    }

    private var isTransitioning: Bool {
        actionEnvelope < 0.35
    }

    private var stepSign: Double {
        sin(phase * Double.pi * 2.0)
    }

    private var quickStepSign: Double {
        sin(phase * Double.pi * 4.0)
    }

    private func softened(_ value: Double) -> Double {
        value * actionEnvelope
    }

    private func softened(_ value: CGFloat) -> CGFloat {
        value * CGFloat(actionEnvelope)
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
        case .breathe, .sparkle, .stargaze, .proudPose, .pauseLook, .tinySigh, .cloudWatch:
            return .settle
        case .stretch, .sunSalute, .yawn, .morningRub, .shoulderRoll, .eveningStretch, .wakeReach:
            return .stretch
        case .wave, .wink, .shyWave, .bigWave, .handSway, .armCircle, .doubleWave, .helloPeek:
            return .wave
        case .hop, .cheer, .softBounce, .sunHop:
            return .bounce
        case .dance, .clap, .twirl, .tinyJump, .happyShimmy, .tinyClap, .shoulderDance:
            return .dance
        case .lookAround, .peek, .nod, .lookUp, .lookDown, .sideNod, .rainPeek:
            return .curious
        case .starToss, .orbit, .pointStar, .starReach, .moonGaze:
            return .admire
        case .sleep, .sleepTurn:
            return .sleep
        case .dream, .float, .driftLeft, .driftRight:
            return .dream
        case .march, .moonWalk, .softWalk, .tiptoe, .sideStep, .slowMarch, .sneakStep, .miniMarch:
            return .step
        case .sway, .bow, .sleepySway, .microBow, .slowSway:
            return .sway
        case .rainDance:
            return .rainShuffle
        case .kick, .shake, .toeTap, .kneeBend, .heelRock, .footShuffle, .toeWiggle, .heelClick:
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
        let routineAccent: Double
        switch routine {
        case .driftLeft:
            routineAccent = -2.0 - pulse(center: 0.50, width: 0.36) * 2.0
        case .driftRight:
            routineAccent = 2.0 + pulse(center: 0.50, width: 0.36) * 2.0
        case .sideNod:
            routineAccent = sin(phase * Double.pi * 2.0) * 1.4
        case .sneakStep:
            routineAccent = sin(phase * Double.pi * 2.0) * 0.8
        default:
            routineAccent = 0
        }
        return CGFloat(base + softened(weight + accent + routineAccent))
    }

    var bodyY: CGFloat {
        let breath = calmBreath * 1.5
        switch gesture {
        case .bounce:
            let crouch = pulse(center: 0.18, width: 0.14)
            let lift = pulse(center: 0.44, width: 0.20)
            let settle = pulse(center: 0.72, width: 0.16)
            return CGFloat(breath + softened(crouch * 3.5 - lift * 8.5 + settle * 2.2))
        case .dance:
            return CGFloat(breath + softened(sin(phase * Double.pi * 4.0) * 2.8 - pulse(center: 0.42, width: 0.18) * 3.0))
        case .stretch:
            return CGFloat(breath + softened(-wave(start: 0.12, end: 0.46) * 6.0 + wave(start: 0.70, end: 0.96) * 5.0))
        case .step, .rainShuffle, .playfulStep:
            return CGFloat(breath - softened(abs(stepSign) * 1.8))
        case .sleep:
            return CGFloat(2.5 + sin(beat * 0.055) * 1.4)
        case .dream:
            return CGFloat(-2.5 + sin(beat * 0.07) * 3.5)
        default:
            let routineAccent: Double
            switch routine {
            case .softBounce:
                routineAccent = -pulse(center: 0.46, width: 0.28) * 3.0
            case .tinySigh:
                routineAccent = pulse(center: 0.62, width: 0.22) * 1.8
            case .cloudWatch, .lookUp:
                routineAccent = -pulse(center: 0.50, width: 0.35) * 1.2
            default:
                routineAccent = 0
            }
            return CGFloat(breath + softened(routineAccent))
        }
    }

    var bodyAngle: Double {
        switch gesture {
        case .curious:
            return softened(weightShift * 4.5)
        case .wave, .admire:
            return softened(2.5 + sin(beat * 0.10) * 1.0)
        case .dance:
            return softened(sin(phase * Double.pi * 4.0) * 5.2)
        case .step, .rainShuffle, .playfulStep:
            return softened(weightShift * 3.4)
        case .stretch:
            return softened(sin(phase * Double.pi) * 2.0)
        case .sleep:
            return -3.0 + sin(beat * 0.055) * 1.0
        case .dream:
            return sin(beat * 0.07) * 2.4
        case .sway:
            return softened(weightShift * 5.0)
        default:
            switch routine {
            case .microBow:
                return softened(pulse(center: 0.50, width: 0.34) * 4.0)
            case .sideNod:
                return softened(sin(phase * Double.pi * 4.0) * 2.2)
            default:
                return calmBreath * 1.2
            }
        }
    }

    var squash: CGFloat {
        let base: Double
        switch gesture {
        case .bounce:
            base = 1.0 + pulse(center: 0.18, width: 0.14) * 0.06 - pulse(center: 0.44, width: 0.20) * 0.03
        case .stretch:
            base = 1.0 - wave(start: 0.12, end: 0.46) * 0.06 + wave(start: 0.70, end: 0.96) * 0.05
        case .sleep:
            return CGFloat(1.03 + sin(beat * 0.055) * 0.01)
        case .dance:
            base = 1.0 + abs(quickStepSign) * 0.025
        default:
            return CGFloat(1.0 + calmBreath * 0.008)
        }
        return CGFloat(1.0 + (base - 1.0) * actionEnvelope)
    }

    var stretch: CGFloat {
        let base: Double
        switch gesture {
        case .bounce:
            base = 1.0 - pulse(center: 0.18, width: 0.14) * 0.045 + pulse(center: 0.44, width: 0.20) * 0.04
        case .stretch:
            base = 1.0 + wave(start: 0.12, end: 0.46) * 0.08 - wave(start: 0.70, end: 0.96) * 0.06
        case .sleep:
            return CGFloat(0.98 + sin(beat * 0.055) * 0.012)
        case .dream:
            return CGFloat(1.0 + sin(beat * 0.07) * 0.02)
        default:
            return CGFloat(1.0 - calmBreath * 0.008)
        }
        return CGFloat(1.0 + (base - 1.0) * actionEnvelope)
    }

    var leftArmX: CGFloat {
        switch gesture {
        case .stretch:
            return 0
        case .dance:
            return softened(CGFloat(-weightShift * 0.7))
        case .sleep:
            return 1
        default:
            return 0
        }
    }

    var leftArmY: CGFloat {
        switch gesture {
        case .stretch:
            return softened(CGFloat(-2 * wave(start: 0.12, end: 0.44) + 2 * wave(start: 0.72, end: 0.96)))
        case .dance:
            return CGFloat(calmBreath * 0.5) + softened(CGFloat(sin(phase * Double.pi * 4.0 + 0.8) * 0.5))
        case .sleep:
            return 2
        case .rainShuffle:
            return softened(CGFloat(1 + quickStepSign * 0.8))
        default:
            return CGFloat(calmBreath * 0.6)
        }
    }

    var rightArmX: CGFloat {
        switch gesture {
        case .wave, .admire:
            return softened(CGFloat(pulse(center: 0.54, width: 0.26) * 1.2))
        case .dance:
            return softened(CGFloat(-weightShift * 0.7))
        case .sleep:
            return -1
        default:
            return 0
        }
    }

    var rightArmY: CGFloat {
        switch gesture {
        case .wave:
            return softened(CGFloat(-1 + sin(phase * Double.pi * 5.0) * 0.8))
        case .admire:
            return softened(CGFloat(-3 + pulse(center: 0.42, width: 0.30) * -1.5))
        case .stretch:
            return softened(CGFloat(-4 * wave(start: 0.12, end: 0.44) + 4 * wave(start: 0.72, end: 0.96)))
        case .dance:
            return CGFloat(calmBreath * 0.8) + softened(CGFloat(cos(phase * Double.pi * 4.0 + 0.6) * 0.9))
        case .sleep:
            return 2
        case .rainShuffle:
            return softened(CGFloat(1 + cos(phase * Double.pi * 4.0) * 0.8))
        default:
            return CGFloat(calmBreath * 0.6)
        }
    }

    var leftArmAngle: Double {
        switch gesture {
        case .stretch:
            return softened(-1 - wave(start: 0.12, end: 0.44) * 2 + wave(start: 0.72, end: 0.96) * 2)
        case .curious:
            return softened(weightShift * -0.8)
        case .dance:
            return softened(-1 + sin(phase * Double.pi * 4.0 + 0.4))
        case .rainShuffle:
            return softened(quickStepSign)
        case .sleep:
            return 1
        case .dream:
            return sin(beat * 0.07)
        default:
            return calmBreath * 0.7
        }
    }

    var rightArmAngle: Double {
        switch gesture {
        case .wave:
            return softened(-5 + sin(phase * Double.pi * 5.0) * 3)
        case .admire:
            return softened(-7 + pulse(center: 0.42, width: 0.30) * -3 + sin(beat * 0.10))
        case .stretch:
            return softened(-3 - wave(start: 0.12, end: 0.44) * 5 + wave(start: 0.72, end: 0.96) * 5)
        case .dance:
            return softened(2 + cos(phase * Double.pi * 4.0 + 0.4) * 2.5)
        case .rainShuffle:
            return softened(1 + cos(phase * Double.pi * 4.0) * 2)
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
        case .step:
            return softened(CGFloat(min(0, stepSign) * 1.4))
        case .rainShuffle:
            return softened(CGFloat(min(0, stepSign) * 0.9))
        case .playfulStep:
            return softened(CGFloat(-pulse(center: 0.42, width: 0.22) * 1.0))
        case .sleep:
            return -1
        default:
            return 0
        }
    }

    var rightFootX: CGFloat {
        switch gesture {
        case .step:
            return softened(CGFloat(max(0, stepSign) * 1.4))
        case .rainShuffle:
            return softened(CGFloat(max(0, stepSign) * 0.9))
        case .playfulStep:
            return softened(CGFloat(pulse(center: 0.42, width: 0.22) * 1.0))
        case .sleep:
            return 1
        default:
            return 0
        }
    }

    var leftFootY: CGFloat {
        switch gesture {
        case .bounce:
            return softened(CGFloat(-pulse(center: 0.44, width: 0.20) * 1.2))
        case .step:
            return softened(CGFloat(max(0, -stepSign) * -1.4))
        case .rainShuffle:
            return softened(CGFloat(max(0, -stepSign) * -0.8))
        case .dance:
            return softened(CGFloat(max(0, quickStepSign) * -1.0))
        case .playfulStep:
            return softened(CGFloat(-pulse(center: 0.68, width: 0.18) * 0.8))
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
            return softened(CGFloat(max(0, stepSign) * -1.4))
        case .rainShuffle:
            return softened(CGFloat(max(0, stepSign) * -0.8))
        case .dance:
            return softened(CGFloat(max(0, -quickStepSign) * -1.0))
        case .playfulStep:
            return softened(CGFloat(-pulse(center: 0.42, width: 0.22) * 1.0))
        case .sleep:
            return 1
        default:
            return 0
        }
    }

    var leftFootAngle: Double {
        0
    }

    var rightFootAngle: Double {
        0
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
            return [".D", "D.", ".D"]
        case .wave where pulse(center: 0.62, width: 0.08) > 0.7:
            return ["DD"]
        default:
            return ["DD", "DD", "DD", "DD"]
        }
    }

    var eyeLookX: CGFloat {
        switch gesture {
        case .curious:
            return CGFloat(weightShift * 2.0)
        case .admire, .wave:
            return 1
        default:
            switch routine {
            case .driftLeft:
                return -1
            case .driftRight:
                return 1
            default:
                return 0
            }
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
            switch routine {
            case .lookUp, .cloudWatch, .moonGaze:
                return -1
            case .lookDown, .tinySigh:
                return 1
            default:
                return 0
            }
        }
    }

    var accessory: Accessory {
        switch routine {
        case .sparkle, .clap, .cheer, .twirl, .tinyJump, .proudPose, .happyShimmy, .tinyClap:
            return .sparkle
        case .sunSalute, .sunHop:
            return .sun
        case .sleep, .sleepTurn:
            return .sleep
        case .dream, .moonGaze:
            return .moon
        case .orbit, .starToss, .starReach:
            return .orbit
        case .rainDance, .rainPeek:
            return .rain
        default:
            return .none
        }
    }

    private var neutralLeftArmRows: [String] {
        [
            "....DD",
            "...DDD",
            "..DD..",
            ".DD...",
            "DD...."
        ]
    }

    private var neutralRightArmRows: [String] {
        [
            "DD....",
            "DDD...",
            "..DD..",
            "...DD.",
            "....DD",
            "...DD."
        ]
    }

    private var plantedLeftLegRows: [String] {
        [
            ".DD.",
            ".DD.",
            ".DD.",
            "DDDD",
            "DDD."
        ]
    }

    private var plantedRightLegRows: [String] {
        [
            ".DD.",
            ".DD.",
            ".DD.",
            "DDDD",
            ".DDD"
        ]
    }

    var leftArmRows: [String] {
        if isTransitioning {
            return neutralLeftArmRows
        }

        switch gesture {
        case .stretch:
            return [
                "...DD.",
                "..DD..",
                ".DD...",
                "DD....",
                ".DD..."
            ]
        case .wave:
            switch Int(phase * 5.0) % 5 {
            case 0:
                return [
                    "....DD",
                    "...DD.",
                    "..DD..",
                    ".DD..",
                    "DD..."
                ]
            case 1:
                return [
                    "...DD.",
                    "..DD..",
                    ".DD...",
                    "DDD...",
                    "..DD.."
                ]
            case 2:
                return [
                    "..DD..",
                    ".DD...",
                    "DD....",
                    "DDD...",
                    "...DD."
                ]
            case 3:
                return [
                    "...DD.",
                    "..DD..",
                    "DDD...",
                    ".DDD..",
                    "...DD."
                ]
            default:
                return neutralLeftArmRows
            }
        case .dance, .rainShuffle:
            return quickStepSign > 0
                ? [
                    "....DD",
                    "...DDD",
                    "..DD..",
                    ".DDD..",
                    "DDD..."
                ]
                : [
                    "...DD.",
                    "..DD..",
                    "DDD...",
                    "D.D...",
                    "..DD.."
                ]
        case .sleep:
            return [
                "...DD",
                "..DDD",
                ".DD..",
                "..DD."
            ]
        case .curious:
            return [
                "...DD.",
                "..DDD.",
                ".DD...",
                "..DD.."
            ]
        case .bounce:
            return [
                "...DD",
                "..DDD",
                ".DD..",
                "DD..."
            ]
        default:
            return neutralLeftArmRows
        }
    }

    var rightArmRows: [String] {
        if isTransitioning {
            return neutralRightArmRows
        }

        switch gesture {
        case .wave:
            switch Int(phase * 5.0) % 5 {
            case 0:
                return [
                    "DD....",
                    ".DD...",
                    "..DD..",
                    "...DD.",
                    "....DD"
                ]
            case 1:
                return [
                    ".DD...",
                    "..DD..",
                    "...DD.",
                    "...DDD",
                    "..DD.."
                ]
            case 2:
                return [
                    "..DD..",
                    "...DD.",
                    "....DD",
                    "...DDD",
                    ".DD..."
                ]
            case 3:
                return [
                    ".DD...",
                    "..DD..",
                    "...DDD",
                    "..DDD.",
                    ".DD..."
                ]
            default:
                return neutralRightArmRows
            }
        case .admire:
            return pulse(center: 0.45, width: 0.28) > 0.55
                ? [
                    ".DD...",
                    "..DD..",
                    "...DD.",
                    "....DD",
                    "...DDD",
                    "..DD.."
                ]
                : [
                    "DD....",
                    ".DD...",
                    "..DD..",
                    "...DDD",
                    "...DD."
                ]
        case .dance, .rainShuffle:
            return quickStepSign > 0
                ? [
                    "DD....",
                    "DDD...",
                    "..DD..",
                    "..DDD.",
                    "...DDD"
                ]
                : [
                    ".DD...",
                    "..DD..",
                    "...DDD",
                    "...D.D",
                    "..DD.."
                ]
        case .stretch:
            return [
                ".DD...",
                "..DD..",
                "...DD.",
                "....DD",
                "...DD."
            ]
        case .sleep:
            return [
                "DD...",
                "DDD..",
                "..DD.",
                ".DD.."
            ]
        case .bounce:
            return [
                "DD...",
                "DDD..",
                "..DD.",
                "..DDD",
                "..DD."
            ]
        default:
            return neutralRightArmRows
        }
    }

    var leftLegRows: [String] {
        if isTransitioning {
            return plantedLeftLegRows
        }

        switch gesture {
        case .step, .rainShuffle:
            return stepSign < 0
                ? [
                    ".DD.",
                    ".DDD",
                    "..DD",
                    ".DD.",
                    "DDDD",
                    "DDD."
                ]
                : plantedLeftLegRows
        case .dance:
            return quickStepSign > 0
                ? [
                    ".DD.",
                    ".DD.",
                    ".DDD",
                    "..DD",
                    "DDDD",
                    "DDD."
                ]
                : plantedLeftLegRows
        case .playfulStep:
            return pulse(center: 0.68, width: 0.18) > 0.45
                ? [
                    ".DD.",
                    "DDD.",
                    "DD..",
                    ".DD.",
                    "DDDD",
                    "DDD."
                ]
                : plantedLeftLegRows
        case .bounce:
            return [
                ".DD.",
                ".DD.",
                "DDDD",
                "DDD."
            ]
        case .sleep:
            return [
                ".DD.",
                ".DD.",
                "DDDD",
                "DDD."
            ]
        default:
            return plantedLeftLegRows
        }
    }

    var rightLegRows: [String] {
        if isTransitioning {
            return plantedRightLegRows
        }

        switch gesture {
        case .step, .rainShuffle:
            return stepSign > 0
                ? [
                    ".DD.",
                    "DDD.",
                    "DD..",
                    ".DD.",
                    "DDDD",
                    ".DDD"
                ]
                : plantedRightLegRows
        case .dance, .playfulStep:
            if gesture == .playfulStep {
                return pulse(center: 0.42, width: 0.22) > 0.45
                    ? [
                        ".DD.",
                        ".DDD",
                        "..DD",
                        ".DD.",
                        "DDDD",
                        ".DDD"
                    ]
                    : plantedRightLegRows
            }
            return quickStepSign < 0
                ? [
                    ".DD.",
                    ".DDD",
                    "..DD",
                    ".DD.",
                    "DDDD",
                    ".DDD"
                ]
                : plantedRightLegRows
        case .bounce:
            return [
                ".DD.",
                ".DD.",
                "DDDD",
                ".DDD"
            ]
        case .sleep:
            return [
                ".DD.",
                ".DD.",
                "DDDD",
                ".DDD"
            ]
        default:
            return plantedRightLegRows
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
    case pauseLook
    case tinySigh
    case cloudWatch
    case stretch
    case eveningStretch
    case wakeReach
    case wave
    case shyWave
    case bigWave
    case doubleWave
    case helloPeek
    case handSway
    case armCircle
    case hop
    case softBounce
    case sunHop
    case dance
    case happyShimmy
    case shoulderDance
    case lookAround
    case nod
    case sideNod
    case lookUp
    case lookDown
    case starToss
    case pointStar
    case starReach
    case stargaze
    case moonGaze
    case sparkle
    case sunSalute
    case yawn
    case morningRub
    case sleep
    case dream
    case march
    case softWalk
    case tiptoe
    case sideStep
    case slowMarch
    case sneakStep
    case miniMarch
    case clap
    case tinyClap
    case orbit
    case wink
    case sway
    case bow
    case microBow
    case slowSway
    case sleepySway
    case peek
    case rainPeek
    case shake
    case rainDance
    case kick
    case toeTap
    case kneeBend
    case heelRock
    case footShuffle
    case toeWiggle
    case heelClick
    case cheer
    case twirl
    case tinyJump
    case shoulderRoll
    case proudPose
    case moonWalk
    case float
    case driftLeft
    case driftRight
    case sleepTurn
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
            return [.sleep, .dream, .sleepTurn, .yawn, .morningRub, .wakeReach, .stretch, .sunSalute, .sunHop, .breathe, .pauseLook, .lookAround, .lookUp, .shyWave, .helloPeek, .sparkle, .softWalk, .sneakStep, .sway, .peek, .float, .driftLeft, .wink, .nod]
        case .morning:
            return [.stretch, .wakeReach, .wave, .bigWave, .doubleWave, .breathe, .cloudWatch, .lookAround, .hop, .softBounce, .starToss, .pointStar, .starReach, .sparkle, .march, .miniMarch, .softWalk, .tiptoe, .clap, .tinyClap, .sway, .sideNod, .wink, .cheer, .orbit, .toeTap, .toeWiggle, .proudPose]
        case .noon:
            return [.breathe, .pauseLook, .hop, .sunHop, .tinyJump, .dance, .happyShimmy, .shoulderDance, .wave, .handSway, .armCircle, .starToss, .starReach, .lookAround, .lookDown, .march, .sideStep, .slowMarch, .miniMarch, .clap, .tinyClap, .sparkle, .rainDance, .rainPeek, .cheer, .orbit, .sway, .kneeBend, .heelClick, .armCircle]
        case .afternoon:
            return [.breathe, .tinySigh, .lookAround, .lookUp, .wave, .shyWave, .helloPeek, .starToss, .stargaze, .cloudWatch, .stretch, .shoulderRoll, .dance, .happyShimmy, .sparkle, .hop, .softBounce, .sway, .slowSway, .march, .footShuffle, .toeWiggle, .peek, .wink, .float, .driftRight, .heelRock]
        case .evening:
            return [.wave, .shyWave, .breathe, .tinySigh, .lookAround, .lookDown, .sparkle, .eveningStretch, .bow, .microBow, .starToss, .pointStar, .moonGaze, .sway, .slowSway, .clap, .tinyClap, .orbit, .dream, .float, .driftLeft, .wink, .softWalk, .handSway]
        case .night:
            return [.breathe, .pauseLook, .sleep, .dream, .sleepTurn, .lookAround, .lookUp, .shyWave, .sparkle, .sleep, .dream, .sleepySway, .microBow, .wink, .float, .driftRight, .orbit, .stargaze, .moonGaze, .tiptoe, .sneakStep]
        case .lateNight:
            return [.sleep, .dream, .sleepTurn, .breathe, .tinySigh, .sleep, .dream, .lookAround, .lookDown, .sleep, .sparkle, .sleepySway, .float, .driftLeft, .wink, .yawn, .moonGaze]
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
