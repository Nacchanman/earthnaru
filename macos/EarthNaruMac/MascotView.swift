import SwiftUI

struct MascotView: View {
    let object: LiftObject
    let isCelebrating: Bool

    var body: some View {
        TimelineView(.animation) { timeline in
            let t = timeline.date.timeIntervalSinceReferenceDate
            let bounce = sin(t * 6) * 4
            let armLift: CGFloat = isCelebrating ? -46 : CGFloat(bounce)

            ZStack {
                trophyObject
                    .offset(x: 66, y: 56)
                    .opacity(isCelebrating ? 0.18 : 1)

                VStack(spacing: 4) {
                    if isCelebrating {
                        Text(object.emoji)
                            .font(.system(size: 34))
                            .offset(y: -8)
                    }

                    ZStack {
                        earthBody

                        Rectangle()
                            .fill(Color(red: 0.04, green: 0.16, blue: 0.42))
                            .frame(width: 8, height: 28)
                            .offset(x: -22, y: -2)

                        Rectangle()
                            .fill(Color(red: 0.04, green: 0.16, blue: 0.42))
                            .frame(width: 8, height: 28)
                            .offset(x: 22, y: -2)

                        arm(side: -1, lift: CGFloat(bounce))
                            .offset(x: -58, y: 22)

                        arm(side: 1, lift: armLift)
                            .offset(x: 58, y: 12)

                        leg(side: -1)
                            .offset(x: -24, y: 72 + CGFloat(max(0, bounce / 2)))
                        leg(side: 1)
                            .offset(x: 24, y: 72 + CGFloat(max(0, -bounce / 2)))
                    }
                    .offset(y: CGFloat(bounce / 3))
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

    private var earthBody: some View {
        ZStack {
            Circle()
                .fill(Color(red: 0.25, green: 0.56, blue: 0.92))
                .frame(width: 132, height: 132)
                .overlay(
                    Circle()
                        .stroke(Color(red: 0.04, green: 0.16, blue: 0.42), lineWidth: 8)
                )

            PixelLand(points: [
                CGRect(x: -46, y: -50, width: 38, height: 18),
                CGRect(x: -56, y: -30, width: 34, height: 24),
                CGRect(x: -38, y: 34, width: 60, height: 26),
                CGRect(x: 20, y: -42, width: 36, height: 38),
                CGRect(x: 32, y: 16, width: 44, height: 38),
                CGRect(x: 52, y: 48, width: 20, height: 20),
                CGRect(x: -42, y: 6, width: 16, height: 9)
            ])
        }
    }

    private func arm(side: CGFloat, lift: CGFloat) -> some View {
        ZStack {
            Rectangle()
                .fill(Color(red: 0.04, green: 0.16, blue: 0.42))
                .frame(width: 10, height: 46)
                .rotationEffect(.degrees(side == 1 ? -58 : 30))
                .offset(x: side * 8, y: lift / 2)
            Circle()
                .fill(Color(red: 0.04, green: 0.16, blue: 0.42))
                .frame(width: 20, height: 20)
                .offset(x: side * 27, y: lift)
        }
    }

    private func leg(side: CGFloat) -> some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(Color(red: 0.04, green: 0.16, blue: 0.42))
                .frame(width: 11, height: 34)
            Rectangle()
                .fill(Color(red: 0.04, green: 0.16, blue: 0.42))
                .frame(width: 32, height: 11)
                .offset(x: side * -7)
        }
    }
}

private struct PixelLand: View {
    let points: [CGRect]

    var body: some View {
        ZStack {
            ForEach(Array(points.enumerated()), id: \.offset) { _, rect in
                Rectangle()
                    .fill(Color(red: 0.57, green: 0.76, blue: 0.41))
                    .frame(width: rect.width, height: rect.height)
                    .offset(x: rect.minX, y: rect.minY)
            }
        }
    }
}

#Preview {
    MascotView(object: LiftObject(level: 5, name: "Keyboard", emoji: "⌨️"), isCelebrating: true)
}
