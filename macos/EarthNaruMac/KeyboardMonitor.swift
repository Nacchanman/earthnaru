import AppKit
import ApplicationServices
import Foundation

final class KeyboardMonitor {
    var onKeyDown: (() -> Void)?

    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    private var localMonitor: Any?
    private var globalMonitor: Any?
    private var lastEventTime: TimeInterval = 0

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
        installEventTap()

        guard globalMonitor != nil || eventTap != nil else {
            lastError = "Keyboard monitor could not start. Quit EarthNaruMac, open it again, then choose Restart Key Counter."
            return false
        }

        isRunning = true
        return true
    }

    func stop() {
        if let eventTap {
            CGEvent.tapEnable(tap: eventTap, enable: false)
            CFMachPortInvalidate(eventTap)
        }

        if let runLoopSource {
            CFRunLoopRemoveSource(CFRunLoopGetMain(), runLoopSource, .commonModes)
        }

        if let localMonitor {
            NSEvent.removeMonitor(localMonitor)
        }

        if let globalMonitor {
            NSEvent.removeMonitor(globalMonitor)
        }

        eventTap = nil
        runLoopSource = nil
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

    private func installEventTap() {
        guard eventTap == nil else { return }

        let mask = CGEventMask(1 << CGEventType.keyDown.rawValue)
        let userInfo = Unmanaged.passUnretained(self).toOpaque()

        guard let tap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .listenOnly,
            eventsOfInterest: mask,
            callback: { _, type, event, userInfo in
                guard let userInfo else {
                    return Unmanaged.passUnretained(event)
                }

                if type == .tapDisabledByTimeout || type == .tapDisabledByUserInput {
                    let monitor = Unmanaged<KeyboardMonitor>.fromOpaque(userInfo).takeUnretainedValue()
                    if let eventTap = monitor.eventTap {
                        CGEvent.tapEnable(tap: eventTap, enable: true)
                    }
                    return Unmanaged.passUnretained(event)
                }

                guard type == .keyDown else {
                    return Unmanaged.passUnretained(event)
                }

                let monitor = Unmanaged<KeyboardMonitor>.fromOpaque(userInfo).takeUnretainedValue()
                monitor.handleKeyEvent(isRepeat: event.getIntegerValueField(.keyboardEventAutorepeat) != 0)

                return Unmanaged.passUnretained(event)
            },
            userInfo: userInfo
        ) else {
            return
        }

        eventTap = tap
        runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)

        if let runLoopSource {
            CFRunLoopAddSource(CFRunLoopGetMain(), runLoopSource, .commonModes)
        }

        CGEvent.tapEnable(tap: tap, enable: true)
    }

    private func handleKeyEvent(isRepeat: Bool) {
        guard !isRepeat else { return }

        // NSEvent global monitor and CGEvent tap can both fire for the same physical key.
        // Keep whichever arrives first and ignore near-duplicates.
        let now = ProcessInfo.processInfo.systemUptime
        guard now - lastEventTime > 0.015 else { return }
        lastEventTime = now

        onKeyDown?()
    }
}
