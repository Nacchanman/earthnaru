import SwiftUI

struct CompanionView: View {
    @ObservedObject var game: GameModel

    var body: some View {
        VStack(spacing: 10) {
            header
            stage
            todayPanel
            levelPanel
        }
        .padding(14)
        .frame(width: 278, height: 392)
        .background(panelBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(.white.opacity(0.34), lineWidth: 1)
        )
    }

    private var header: some View {
        HStack(alignment: .center, spacing: 10) {
            VStack(alignment: .leading, spacing: 2) {
                Text("EarthNaru")
                    .font(.system(size: 18, weight: .black, design: .rounded))
                Text(game.isPaused ? "Paused" : game.activityPace.title)
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(game.isPaused ? .orange : game.activityPace.color)
            }

            Spacer()

            HStack(spacing: 5) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 11, weight: .bold))
                Text("\(game.todayKeys)")
                    .font(.system(size: 13, weight: .black, design: .rounded))
            }
            .foregroundStyle(game.activityPace.color)
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(game.activityPace.color.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
    }

    private var stage: some View {
        ZStack(alignment: .bottom) {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.80, green: 0.91, blue: 0.98),
                            Color(red: 0.86, green: 0.93, blue: 0.82),
                            Color(red: 0.98, green: 0.90, blue: 0.70)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            VStack(spacing: 0) {
                HStack {
                    levelBadge
                    Spacer()
                    liftBadge
                }
                .padding(10)

                Spacer(minLength: 0)

                MascotView(
                    object: game.currentObject,
                    isCelebrating: game.isCelebrating,
                    runFrame: game.runFrame
                )
                .frame(width: 154, height: 178)
                .scaleEffect(0.86)
                .offset(y: 8)
            }
        }
        .frame(height: 190)
    }

    private var todayPanel: some View {
        VStack(alignment: .leading, spacing: 7) {
            HStack {
                MetricLabel(icon: "keyboard", title: "Today", value: "\(game.todayKeys)")
                Spacer()
                Text("\(game.todayGoal) goal")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(.secondary)
            }

            MeterBar(value: game.todayProgress, color: game.activityPace.color)

            Text(game.isPaused ? "Counting is paused." : game.activityPace.caption)
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
        .padding(10)
        .background(.white.opacity(0.50))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private var levelPanel: some View {
        HStack(spacing: 8) {
            MetricTile(icon: "sum", title: "Total", value: "\(game.totalKeys)")
            MetricTile(icon: "arrow.up.forward", title: "Next", value: game.nextRequiredKeys == nil ? "Max" : "\(game.keysToNextLevel)")
            MetricTile(icon: "trophy.fill", title: "Lift", value: game.currentObject.name)
        }
    }

    private var levelBadge: some View {
        HStack(spacing: 5) {
            Image(systemName: "bolt.fill")
                .font(.system(size: 10, weight: .black))
            Text("Lv.\(game.level)")
                .font(.system(size: 12, weight: .black, design: .rounded))
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .background(Color(red: 0.08, green: 0.22, blue: 0.36).opacity(0.88))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private var liftBadge: some View {
        HStack(spacing: 4) {
            Text(game.currentObject.emoji)
                .font(.system(size: 14))
            Text(game.currentObject.name)
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .lineLimit(1)
        }
        .foregroundStyle(Color(red: 0.08, green: 0.22, blue: 0.36))
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .background(.white.opacity(0.72))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private var panelBackground: some ShapeStyle {
        LinearGradient(
            colors: [
                Color(red: 0.97, green: 0.98, blue: 0.95).opacity(0.92),
                Color(red: 0.91, green: 0.96, blue: 0.98).opacity(0.92)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

private struct MetricLabel: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        HStack(spacing: 7) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .bold))
                .frame(width: 18, height: 18)
                .foregroundStyle(Color(red: 0.14, green: 0.42, blue: 0.57))

            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.system(size: 17, weight: .black, design: .rounded))
            }
        }
    }
}

private struct MetricTile: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 11, weight: .black))
                .foregroundStyle(Color(red: 0.12, green: 0.35, blue: 0.52))

            Text(title)
                .font(.system(size: 9, weight: .bold, design: .rounded))
                .foregroundStyle(.secondary)

            Text(value)
                .font(.system(size: 12, weight: .black, design: .rounded))
                .lineLimit(1)
                .minimumScaleFactor(0.72)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(9)
        .background(.white.opacity(0.48))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

private struct MeterBar: View {
    let value: Double
    let color: Color

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .fill(.black.opacity(0.08))

                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .fill(color)
                    .frame(width: max(8, proxy.size.width * value))
            }
        }
        .frame(height: 8)
    }
}

#Preview {
    CompanionView(game: GameModel())
}
