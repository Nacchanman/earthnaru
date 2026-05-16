import Foundation

struct BridgeMessage: Decodable {
    let type: String
    let totalKeys: Int
    let sentAt: String?
}

@MainActor
final class KeyboardBridgeClient: ObservableObject {
    enum State: Equatable {
        case disconnected
        case connecting
        case connected
        case failed(String)

        var label: String {
            switch self {
            case .disconnected: return "Disconnected"
            case .connecting: return "Connecting"
            case .connected: return "Connected"
            case .failed(let message): return "Failed: \(message)"
            }
        }
    }

    @Published private(set) var state: State = .disconnected

    private var webSocketTask: URLSessionWebSocketTask?
    private var onTotalKeys: ((Int) -> Void)?

    func connect(to urlString: String, onTotalKeys: @escaping (Int) -> Void) {
        disconnect()
        self.onTotalKeys = onTotalKeys

        guard let url = URL(string: urlString) else {
            state = .failed("Invalid URL")
            return
        }

        state = .connecting
        let task = URLSession.shared.webSocketTask(with: url)
        webSocketTask = task
        task.resume()
        state = .connected
        receiveLoop()
    }

    func disconnect() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil
        state = .disconnected
    }

    private func receiveLoop() {
        webSocketTask?.receive { [weak self] result in
            Task { @MainActor in
                guard let self else { return }

                switch result {
                case .success(let message):
                    self.handle(message)
                    self.receiveLoop()
                case .failure(let error):
                    self.state = .failed(error.localizedDescription)
                    self.webSocketTask = nil
                }
            }
        }
    }

    private func handle(_ message: URLSessionWebSocketTask.Message) {
        let text: String?
        switch message {
        case .string(let value):
            text = value
        case .data(let data):
            text = String(data: data, encoding: .utf8)
        @unknown default:
            text = nil
        }

        guard
            let text,
            let data = text.data(using: .utf8),
            let decoded = try? JSONDecoder().decode(BridgeMessage.self, from: data)
        else {
            return
        }

        onTotalKeys?(decoded.totalKeys)
    }
}
