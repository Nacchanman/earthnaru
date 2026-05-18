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
    private let windowSize = NSSize(width: 104, height: 104)

    var isVisible: Bool {
        window.isVisible
    }

    init() {
        let contentView = CompanionView()
        let hostingView = HoverFadingHostingView(rootView: contentView)

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

        hostingView.onHoverChanged = { [weak window] isHovering in
            NSAnimationContext.runAnimationGroup { context in
                context.duration = 0.12
                window?.animator().alphaValue = isHovering ? 0.04 : 1.0
            }
            window?.hasShadow = !isHovering
        }
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

private final class HoverFadingHostingView<Content: View>: NSHostingView<Content> {
    var onHoverChanged: ((Bool) -> Void)?

    private var hoverTrackingArea: NSTrackingArea?

    override func updateTrackingAreas() {
        if let hoverTrackingArea {
            removeTrackingArea(hoverTrackingArea)
        }

        let options: NSTrackingArea.Options = [
            .activeAlways,
            .inVisibleRect,
            .mouseEnteredAndExited
        ]
        let trackingArea = NSTrackingArea(rect: .zero, options: options, owner: self, userInfo: nil)
        addTrackingArea(trackingArea)
        hoverTrackingArea = trackingArea

        super.updateTrackingAreas()
    }

    override func mouseEntered(with event: NSEvent) {
        onHoverChanged?(true)
        super.mouseEntered(with: event)
    }

    override func mouseExited(with event: NSEvent) {
        onHoverChanged?(false)
        super.mouseExited(with: event)
    }
}
