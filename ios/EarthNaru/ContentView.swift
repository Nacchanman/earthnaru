import SwiftUI

struct ContentView: View {
    @StateObject private var game = GameModel()
    @StateObject private var bridge = KeyboardBridgeClient()
    @State private var bridgeURL = "ws://192.168.1.10:8787"

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 1.0, green: 0.96, blue: 0.90), Color(red: 0.92, green: 0.96, blue: 1.0)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 14) {
                header
                Spacer(minLength: 4)
                MascotView(object: game.currentObject, isCelebrating: game.isCelebrating)
                    .frame(maxWidth: .infinity)
                Spacer(minLength: 4)
                stats
                connectionPanel
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 12)
        }
    }

    private var header: some View {
        VStack(spacing: 2) {
            Text("EarthNaru")
                .font(.system(size: 34, weight: .black, design: .rounded))
            Text("Type on your computer. Watch Earth get stronger.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var stats: some View {
        VStack(spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("LEVEL")
                        .font(.caption2.bold())
                        .foregroundStyle(.secondary)
                    Text("\(game.level)")
                        .font(.system(size: 42, weight: .black, design: .rounded))
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text("KEYS")
                        .font(.caption2.bold())
                        .foregroundStyle(.secondary)
                    Text("\(game.totalKeys)")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                }
            }

            ProgressView(value: game.progressToNextLevel)
                .progressViewStyle(.linear)

            if let next = game.nextRequiredKeys {
                Text("Next level in \(max(0, next - game.totalKeys)) keys")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                Text("Max level reached. EarthNaru is legendary.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(14)
        .background(.white.opacity(0.7))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private var connectionPanel: some View {
        VStack(spacing: 8) {
            HStack {
                Circle()
                    .fill(statusColor)
                    .frame(width: 9, height: 9)
                Text(bridge.state.label)
                    .font(.caption.bold())
                Spacer()
                Button("+1 Test") {
                    game.addLocalKeyForTesting()
                }
                .font(.caption.bold())
            }

            TextField("ws://computer-ip:8787", text: $bridgeURL)
                .keyboardType(.URL)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .font(.caption)
                .padding(10)
                .background(.white.opacity(0.9))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            HStack {
                Button("Connect") {
                    bridge.connect(to: bridgeURL) { total in
                        game.applyRemoteTotal(total)
                    }
                }
                .buttonStyle(.borderedProminent)

                Button("Disconnect") {
                    bridge.disconnect()
                }
                .buttonStyle(.bordered)
            }
        }
        .padding(12)
        .background(.white.opacity(0.62))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private var statusColor: Color {
        switch bridge.state {
        case .connected: return .green
        case .connecting: return .orange
        case .disconnected: return .gray
        case .failed: return .red
        }
    }
}

#Preview {
    ContentView()
}
