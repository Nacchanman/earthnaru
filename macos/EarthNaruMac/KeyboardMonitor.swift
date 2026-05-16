import AppKit
import ApplicationServices
import Foundation

final class KeyboardMonitor {
    var onKeyDown: (() -> Void)?

    private var localMonitor: Any?
    private var globalMonitor: Any?

    private(set) var isRunning = false
    private(set) var lastError: String?

    static func isAccessibilityTrusted(prompt: Bool) -> Bool {
        let key = kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String
        let options = [key: prompt] as CFDictionary
        return AXIsProcessTrustedWithOptions(options)
    }

    func requestAccessibilityPermission() {
        _ = Self.isAccessibilityTrusted(prompt: true)
    }

    @discardableResult
    func start(promptForPermission: Bool = false) -> Bool {
        guard !isRunning else { return true }
        lastError = nil

        installLocalMonitor()

        guard Self.isAccessibilityTrusted(prompt: promptForPermission) else {
            lastError = "Accessibility permission is off. Enable EarthNaruMac in System Settings, then choose Restart Key Counter."
            return false
        }

        installGlobalMonitor()

        guard globalMonitor != nil else {
            lastError = "Keyboard monitor could not start. Quit and relaunch EarthNaruMac after enabling Accessibility."
            return false
        }

        isRunning = true
        return true
    }

    func stop() {
        if let localMonitor {
            NSEvent.removeMonitor(localMonitor)
        }

        if let globalMonitor {
            NSEvent.removeMonitor(globalMonitor)
        }

        localMonitor = nil
        globalMonitor = nil
        isRunning = false
    }

    private func installLocalMonitor() {
        guard localMonitor == nil else { return }

        localMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            self?.handleKeyEvent(isRepeat: event.isARepeat)
            return event
        }
    }

    private func installGlobalMonitor() {
        guard globalMonitor == nil else { return }

        globalMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
            self?.handleKeyEvent(isRepeat: event.isARepeat)
        }
    }

    private func handleKeyEvent(isRepeat: Bool) {
        guard !isRepeat else { return }
        onKeyDown?()
    }
}
