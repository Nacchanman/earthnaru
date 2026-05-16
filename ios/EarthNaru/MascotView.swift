import SwiftUI

struct MascotView: View {
    let object: LiftObject
    let isCelebrating: Bool

    @State private var trainingPhase = false

    var body: some View {
        TimelineView(.animation) { timeline in
            let t = timeline.date.timeIntervalSinceReferenceDate
            let bounce = sin(t * 6) * 6
            let armLift: CGFloat = isCelebrating ? -74 : CGFloat(bounce)

            ZStack {
                trophyObject
                    .offset(x: 112, y: 86)
                    .opacity(isCelebrating ? 0.2 : 1)

                VStack(spacing: 8) {
                    if isCelebrating {
                        Text(object.emoji)
                            .font(.system(size: 54))
                            .offset(y: -20)
                            .transition(.scale)
                    }

                    ZStack {
                        earthBody

                        Rectangle()
                            .fill(Color(red: 0.04, green: 0.16, blue: 0.42))
                            .frame(width: 14, height: 46)
                            .offset(x: -36, y: -4)

                        Rectangle()
                            .fill(Color(red: 0.04, green: 0.16, blue: 0.42))
                            .frame(width: 14, height: 46)
                            .offset(x: 36, y: -4)

                        arm(side: -1, lift: CGFloat(bounce))
                            .offset(x: -96, y: 36)

                        arm(side: 1, lift: armLift)
                            .offset(x: 96, y: 18)

                        leg(side: -1)
                            .offset(x: -38, y: 118 + CGFloat(max(0, bounce / 2)))
                        leg(side: 1)
                            .offset(x: 38, y: 118 + CGFloat(max(0, -bounce / 2)))
                    }
                    .offset(y: CGFloat(bounce / 3))
                }
            }
            .frame(width: 340, height: 430)
            .animation(.spring(response: 0.35, dampingFraction: 0.65), value: isCelebrating)
        }
    }

    private var trophyObject: some View {
        VStack(spacing: 2) {
            Text(object.emoji)
                .font(.system(size: 42))
            Text("Lv.\(object.level)")
                .font(.caption.bold())
                .foregroundStyle(.secondary)
        }
        .padding(8)
        .background(.white.opacity(0.72))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private var earthBody: some View {
        ZStack {
            Circle()
                .fill(Color(red: 0.25, green: 0.56, blue: 0.92))
                .frame(width: 216, height: 216)
                .overlay(
                    Circle()
                        .stroke(Color(red: 0.04, green: 0.16, blue: 0.42), lineWidth: 12)
                )

            PixelLand(points: [
                CGRect(x: -74, y: -82, width: 62, height: 28),
                CGRect(x: -92, y: -50, width: 52, height: 38),
                CGRect(x: -62, y: 54, width: 96, height: 42),
                CGRect(x: 34, y: -68, width: 58, height: 62),
                CGRect(x: 52, y: 26, width: 72, height: 60),
                CGRect(x: 86, y: 76, width: 32, height: 34),
                CGRect(x: -70, y: 8, width: 24, height: 14)
            ])
        }
    }

    private func arm(side: CGFloat, lift: CGFloat) -> some View {
        ZStack {
            Rectangle()
                .fill(Color(red: 0.04, green: 0.16, blue: 0.42))
                .frame(width: 18, height: 78)
                .rotationEffect(.degrees(side == 1 ? -58 : 30))
                .offset(x: side * 12, y: lift / 2)
            Circle()
                .fill(Color(red: 0.04, green: 0.16, blue: 0.42))
                .frame(width: 34, height: 34)
                .offset(x: side * 44, y: lift)
        }
    }

    private func leg(side: CGFloat) -> some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(Color(red: 0.04, green: 0.16, blue: 0.42))
                .frame(width: 18, height: 56)
            Rectangle()
                .fill(Color(red: 0.04, green: 0.16, blue: 0.42))
                .frame(width: 54, height: 18)
                .offset(x: side * -12)
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
        .drawingGroup()
    }
}

#Preview {
    MascotView(object: LiftObject(level: 5, name: "Keyboard", emoji: "⌨️"), isCelebrating: true)
}
