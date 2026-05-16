import AppKit
import ApplicationServices
import Foundation
import IOKit.hid

final class KeyboardMonitor {
    var onKeyDown: (() -> Void)?

    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    private var hidManager: IOHIDManager?
    private var localMonitor: Any?
    private var globalMonitor: Any?
    private var lastEventTime: TimeInterval = 0

    private(set) var isRunning = false
    private(set) var lastError: String?

    var activeMonitorSummary: String {
        var active: [String] = []
        if hidManager != nil { active.append("HID") }
        if eventTap != nil { active.append("Tap") }
        if globalMonitor != nil { active.append("Global") }
        if localMonitor != nil { active.append("Local") }
        return active.isEmpty ? "none" : active.joined(separator: "+")
    }

    static func isAccessibilityTrusted(prompt: Bool) -> Bool {
        let key = kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String
        let options = [key: prompt] as CFDictionary
        return AXIsProcessTrustedWithOptions(options)
    }

    static func isInputMonitoringTrusted(prompt: Bool) -> Bool {
        if prompt {
            return CGRequestListenEventAccess()
        }

        return CGPreflightListenEventAccess()
    }

    func requestAccessibilityPermission() {
        _ = Self.isAccessibilityTrusted(prompt: true)
    }

    func requestInputMonitoringPermission() {
        _ = Self.isInputMonitoringTrusted(prompt: true)
    }

    @discardableResult
    func start(promptForPermission: Bool = false) -> Bool {
        lastError = nil

        installLocalMonitor()

        let inputMonitoringTrusted = Self.isInputMonitoringTrusted(prompt: promptForPermission)
        let accessibilityTrusted = Self.isAccessibilityTrusted(prompt: promptForPermission)
        let canListenInBackground = inputMonitoringTrusted || accessibilityTrusted

        if inputMonitoringTrusted {
            // HID receives physical key down values from other apps without reading
            // or retaining the typed characters themselves. It is a useful fallback,
            // but the Core Graphics tap below is the primary path for Input Monitoring.
            installHIDMonitor()
        }

        if canListenInBackground {
            installEventTap()
            installGlobalMonitor()
        }

        let hasBackgroundMonitor = hidManager != nil || eventTap != nil || globalMonitor != nil
        if hasBackgroundMonitor {
            isRunning = true
            return true
        }

        isRunning = false

        switch (accessibilityTrusted, inputMonitoringTrusted) {
        case (true, true):
            lastError = "Background keyboard monitor could not start. Quit and relaunch EarthNaruMac, then try Restart Key Counter."
        case (true, false):
            lastError = "Background keyboard monitor is off. Enable Input Monitoring for EarthNaruMac, then quit and relaunch."
        case (false, true):
            lastError = "Background keyboard monitor is off. Enable Accessibility for EarthNaruMac, then quit and relaunch."
        case (false, false):
            lastError = "Background keyboard monitor is off. Enable Accessibility and Input Monitoring for EarthNaruMac, then quit and relaunch."
        }
        return false
    }

    func stop() {
        if let eventTap {
            CGEvent.tapEnable(tap: eventTap, enable: false)
            CFMachPortInvalidate(eventTap)
        }

        if let runLoopSource {
            CFRunLoopRemoveSource(CFRunLoopGetMain(), runLoopSource, .commonModes)
        }

        if let hidManager {
            IOHIDManagerUnscheduleFromRunLoop(hidManager, CFRunLoopGetMain(), CFRunLoopMode.commonModes.rawValue)
            IOHIDManagerClose(hidManager, IOOptionBits(kIOHIDOptionsTypeNone))
        }

        if let localMonitor {
            NSEvent.removeMonitor(localMonitor)
        }

        if let globalMonitor {
            NSEvent.removeMonitor(globalMonitor)
        }

        eventTap = nil
        runLoopSource = nil
        hidManager = nil
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

    private func installHIDMonitor() {
        guard hidManager == nil else { return }

        let manager = IOHIDManagerCreate(kCFAllocatorDefault, IOOptionBits(kIOHIDOptionsTypeNone))
        let keyboardMatch: [String: Any] = [
            kIOHIDDeviceUsagePageKey: kHIDPage_GenericDesktop,
            kIOHIDDeviceUsageKey: kHIDUsage_GD_Keyboard
        ]

        IOHIDManagerSetDeviceMatchingMultiple(manager, [keyboardMatch] as CFArray)

        let context = Unmanaged.passUnretained(self).toOpaque()
        IOHIDManagerRegisterInputValueCallback(manager, { context, _, _, value in
            guard let context else { return }

            let monitor = Unmanaged<KeyboardMonitor>.fromOpaque(context).takeUnretainedValue()
            let element = IOHIDValueGetElement(value)
            let page = IOHIDElementGetUsagePage(element)
            let usage = IOHIDElementGetUsage(element)
            let pressed = IOHIDValueGetIntegerValue(value) != 0

            guard page == UInt32(kHIDPage_KeyboardOrKeypad), usage > 0, pressed else { return }
            monitor.handleKeyEvent(isRepeat: false)
        }, context)

        IOHIDManagerScheduleWithRunLoop(manager, CFRunLoopGetMain(), CFRunLoopMode.commonModes.rawValue)
        let result = IOHIDManagerOpen(manager, IOOptionBits(kIOHIDOptionsTypeNone))

        if result == kIOReturnSuccess {
            hidManager = manager
        } else {
            IOHIDManagerUnscheduleFromRunLoop(manager, CFRunLoopGetMain(), CFRunLoopMode.commonModes.rawValue)
            IOHIDManagerClose(manager, IOOptionBits(kIOHIDOptionsTypeNone))
        }
    }

    private func installEventTap() {
        guard eventTap == nil else { return }

        // Input Monitoring grants Core Graphics listen access. Try the HID tap first,
        // then fall back to the session tap because some user configurations allow the
        // session-level tap even when IOHID callbacks do not fire for background apps.
        guard let tap = makeEventTap(location: .cghidEventTap) ?? makeEventTap(location: .cgSessionEventTap) else {
            return
        }

        eventTap = tap
        runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)

        if let runLoopSource {
            CFRunLoopAddSource(CFRunLoopGetMain(), runLoopSource, .commonModes)
        }

        CGEvent.tapEnable(tap: tap, enable: true)
    }

    private func makeEventTap(location: CGEventTapLocation) -> CFMachPort? {
        let mask = CGEventMask(1 << CGEventType.keyDown.rawValue)
        let userInfo = Unmanaged.passUnretained(self).toOpaque()

        return CGEvent.tapCreate(
            tap: location,
            place: .headInsertEventTap,
            options: .listenOnly,
            eventsOfInterest: mask,
            callback: { _, type, event, userInfo in
                guard let userInfo else {
                    return Unmanaged.passUnretained(event)
                }

                let monitor = Unmanaged<KeyboardMonitor>.fromOpaque(userInfo).takeUnretainedValue()

                if type == .tapDisabledByTimeout || type == .tapDisabledByUserInput {
                    if let eventTap = monitor.eventTap {
                        CGEvent.tapEnable(tap: eventTap, enable: true)
                    }
                    return Unmanaged.passUnretained(event)
                }

                guard type == .keyDown else {
                    return Unmanaged.passUnretained(event)
                }

                monitor.handleKeyEvent(isRepeat: event.getIntegerValueField(.keyboardEventAutorepeat) != 0)
                return Unmanaged.passUnretained(event)
            },
            userInfo: userInfo
        )
    }

    private func handleKeyEvent(isRepeat: Bool) {
        guard !isRepeat else { return }

        let now = ProcessInfo.processInfo.systemUptime
        guard now - lastEventTime > 0.015 else { return }
        lastEventTime = now

        onKeyDown?()
    }
}
