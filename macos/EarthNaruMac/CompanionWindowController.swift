import AppKit
import SwiftUI

enum CompanionCorner: String, CaseIterable {
    case topLeft
    case topRight
    case bottomLeft
    case bottomRight

    var label: String {
        switch self {
        case .topLeft: return "Top Left"
        case .topRight: return "Top Right"
        case .bottomLeft: return "Bottom Left"
        case .bottomRight: return "Bottom Right"
        }
    }
}

final class CompanionWindowController {
    private let window: NSWindow
    private var corner: CompanionCorner = .bottomRight
    private let windowSize = NSSize(width: 278, height: 392)

    var isVisible: Bool {
        window.isVisible
    }

    init(game: GameModel) {
        let contentView = CompanionView(game: game)
        let hostingView = NSHostingView(rootView: contentView)

        window = NSWindow(
            contentRect: NSRect(origin: .zero, size: windowSize),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        window.contentView = hostingView
        window.isOpaque = false
        window.backgroundColor = .clear
        window.hasShadow = true
        window.level = .floating
        window.collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle]
        window.isMovableByWindowBackground = true
    }

    func show() {
        move(to: corner)
        window.orderFrontRegardless()
    }

    func hide() {
        window.orderOut(nil)
    }

    func move(to corner: CompanionCorner) {
        self.corner = corner

        guard let screen = NSScreen.main else { return }
        let frame = screen.visibleFrame
        let size = window.frame.size
        let margin: CGFloat = 18

        let origin: NSPoint
        switch corner {
        case .topLeft:
            origin = NSPoint(x: frame.minX + margin, y: frame.maxY - size.height - margin)
        case .topRight:
            origin = NSPoint(x: frame.maxX - size.width - margin, y: frame.maxY - size.height - margin)
        case .bottomLeft:
            origin = NSPoint(x: frame.minX + margin, y: frame.minY + margin)
        case .bottomRight:
            origin = NSPoint(x: frame.maxX - size.width - margin, y: frame.minY + margin)
        }

        window.setFrameOrigin(origin)
    }
}
