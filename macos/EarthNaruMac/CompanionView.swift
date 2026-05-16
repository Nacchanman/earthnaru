import SwiftUI

struct CompanionView: View {
    @ObservedObject var game: GameModel

    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 6) {
                Text("Lv.\(game.level)")
                    .font(.system(size: 13, weight: .black, design: .rounded))
                Spacer()
                Text("⌨️ \(game.totalKeys)")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(.secondary)
            }

            ProgressView(value: game.progressToNextLevel)
                .controlSize(.small)

            MascotView(object: game.currentObject, isCelebrating: game.isCelebrating)
                .frame(width: 180, height: 215)

            HStack(spacing: 4) {
                Text(game.isPaused ? "Paused" : "Training")
                    .font(.caption2.bold())
                    .foregroundStyle(game.isPaused ? .orange : .secondary)
                Spacer()
                Text(game.currentObject.emoji)
                    .font(.caption)
                Text(game.currentObject.name)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
        .padding(12)
        .frame(width: 210, height: 300)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(.white.opacity(0.4), lineWidth: 1)
        )
    }
}

#Preview {
    CompanionView(game: GameModel())
}
