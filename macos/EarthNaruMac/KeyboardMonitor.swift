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
    private(set) var permissionSummary = "Accessibility: unknown, Input Monitoring: unknown"
    private var installFailures: [String] = []

    var activeMonitorSummary: String {
        var active: [String] = []
        if hidManager != nil { active.append("HID") }
        if eventTap != nil { active.append("Tap") }
        if globalMonitor != nil { active.append("Global") }
        if localMonitor != nil { active.append("Local") }
        let monitors = active.isEmpty ? "none" : active.joined(separator: "+")
        return "\(monitors); \(permissionSummary)"
    }

    static func isAccessibilityTrusted(prompt: Bool) -> Bool {
        let key = kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String
        let options = [key: prompt] as CFDictionary
        return AXIsProcessTrustedWithOptions(options)
    }

    static func isInputMonitoringTrusted(prompt: Bool) -> Bool {
        prompt ? CGRequestListenEventAccess() : CGPreflightListenEventAccess()
    }

    func requestAccessibilityPermission() {
        _ = Self.isAccessibilityTrusted(prompt: true)
    }

    @discardableResult
    func start(promptForPermission: Bool = false) -> Bool {
        lastError = nil
        installFailures = []

        installLocalMonitor()

        let accessibilityTrusted = Self.isAccessibilityTrusted(prompt: promptForPermission)
        let inputMonitoringTrusted = Self.isInputMonitoringTrusted(prompt: false)
        permissionSummary = "Accessibility: \(accessibilityTrusted ? "on" : "off"), Input Monitoring: \(inputMonitoringTrusted ? "on" : "off")"

        // Keep the background monitors idempotent and retryable. In Xcode builds,
        // macOS may show Input Monitoring enabled for a previous app path while this
        // process still preflights as denied, so we attempt installation and expose
        // the concrete failure in the menu instead of relying on preflight alone.
        installHIDMonitor()
        installEventTap()
        if accessibilityTrusted || inputMonitoringTrusted || eventTap != nil {
            installGlobalMonitor()
        }

        let hasBackgroundMonitor = hidManager != nil || eventTap != nil
        if hasBackgroundMonitor {
            isRunning = true
            return true
        }

        isRunning = false
        let details = installFailures.isEmpty ? "" : " (\(installFailures.joined(separator: "; ")))"
        lastError = "Background keyboard monitor is off. \(permissionSummary). If Input Monitoring is already enabled, remove/re-add the current EarthNaruMac build in System Settings, then relaunch.\(details)"
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
            installFailures.append("HID open failed: 0x\(String(UInt32(bitPattern: result), radix: 16))")
            IOHIDManagerUnscheduleFromRunLoop(manager, CFRunLoopGetMain(), CFRunLoopMode.commonModes.rawValue)
            IOHIDManagerClose(manager, IOOptionBits(kIOHIDOptionsTypeNone))
        }
    }

    private func installEventTap() {
        guard eventTap == nil else { return }

        let mask = CGEventMask(1 << CGEventType.keyDown.rawValue)
        let userInfo = Unmanaged.passUnretained(self).toOpaque()

        let callback: CGEventTapCallBack = { _, type, event, userInfo in
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
            }

        let tap = CGEvent.tapCreate(
            tap: .cghidEventTap,
            place: .headInsertEventTap,
            options: .listenOnly,
            eventsOfInterest: mask,
            callback: callback,
            userInfo: userInfo
        ) ?? CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .listenOnly,
            eventsOfInterest: mask,
            callback: callback,
            userInfo: userInfo
        )

        guard let tap else {
            installFailures.append("event tap denied")
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

        let now = ProcessInfo.processInfo.systemUptime
        guard now - lastEventTime > 0.015 else { return }
        lastEventTime = now

        onKeyDown?()
    }
}
