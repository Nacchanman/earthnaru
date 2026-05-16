import AppKit
import SwiftUI

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private let game = GameModel()
    private let keyboardMonitor = KeyboardMonitor()
    private var companionWindow: CompanionWindowController?
    private var statusItem: NSStatusItem?
    private var permissionRetryTimer: Timer?
    private var diagnosticRefreshTimer: Timer?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)

        companionWindow = CompanionWindowController(game: game)
        companionWindow?.show()

        configureMenuBar()
        startKeyboardMonitorIfAllowed(promptForPermission: false)
    }

    func applicationWillTerminate(_ notification: Notification) {
        permissionRetryTimer?.invalidate()
        diagnosticRefreshTimer?.invalidate()
        keyboardMonitor.stop()
    }

    private func startKeyboardMonitorIfAllowed(promptForPermission: Bool) {
        keyboardMonitor.onKeyDown = { [weak self] in
            Task { @MainActor in
                self?.game.addKeypress()
                self?.rebuildMenu()
            }
        }

        if keyboardMonitor.start(promptForPermission: promptForPermission) {
            permissionRetryTimer?.invalidate()
            permissionRetryTimer = nil
        } else {
            scheduleSilentPermissionRetry()
        }

        rebuildMenu()
    }

    private func scheduleSilentPermissionRetry() {
        permissionRetryTimer?.invalidate()
        permissionRetryTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.startKeyboardMonitorIfAllowed(promptForPermission: false)
            }
        }
    }

    private func configureMenuBar() {
        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        item.button?.title = "🌍 \(game.level)"
        statusItem = item
        startDiagnosticRefresh()
        rebuildMenu()
    }

    private func startDiagnosticRefresh() {
        diagnosticRefreshTimer?.invalidate()
        diagnosticRefreshTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.keyboardMonitor.refreshDiagnostics()
                self?.rebuildMenu()
            }
        }
    }

    private func rebuildMenu() {
        let menu = NSMenu()
        statusItem?.button?.title = game.isPaused ? "🌍 ⏸" : "🌍 \(game.level)"

        let statusTitle: String
        if keyboardMonitor.isRunning {
            statusTitle = "Key counter: On (\(keyboardMonitor.activeMonitorSummary))"
        } else {
            statusTitle = keyboardMonitor.lastError ?? "Key counter: Needs permission"
        }

        let status = NSMenuItem(title: statusTitle, action: nil, keyEquivalent: "")
        status.isEnabled = false
        menu.addItem(status)

        let permissions = NSMenuItem(title: "Permissions: \(keyboardMonitor.permissionSummary)", action: nil, keyEquivalent: "")
        permissions.isEnabled = false
        menu.addItem(permissions)

        let lastKey = NSMenuItem(title: "Last key: \(keyboardMonitor.lastEventSummary)", action: nil, keyEquivalent: "")
        lastKey.isEnabled = false
        menu.addItem(lastKey)

        let install = NSMenuItem(title: "Monitor install: \(keyboardMonitor.installSummary)", action: nil, keyEquivalent: "")
        install.isEnabled = false
        menu.addItem(install)

        if keyboardMonitor.likelyPermissionTargetMismatch {
            let hint = NSMenuItem(
                title: "Fix: remove old EarthNaruMac entries, add this exact app, then relaunch.",
                action: nil,
                keyEquivalent: ""
            )
            hint.isEnabled = false
            menu.addItem(hint)
        }

        let progress = NSMenuItem(
            title: "Today: \(game.todayKeys)/\(game.todayGoal) keys • Level \(game.level)",
            action: nil,
            keyEquivalent: ""
        )
        progress.isEnabled = false
        menu.addItem(progress)

        menu.addItem(NSMenuItem.separator())

        menu.addItem(NSMenuItem(title: game.isPaused ? "Resume" : "Pause", action: #selector(togglePause), keyEquivalent: "p"))
        menu.addItem(NSMenuItem(title: companionWindow?.isVisible == true ? "Hide Companion" : "Show Companion", action: #selector(toggleWindow), keyEquivalent: "m"))
        menu.addItem(NSMenuItem(title: "Reset Today", action: #selector(resetToday), keyEquivalent: "d"))
        menu.addItem(NSMenuItem(title: "Reset All Progress", action: #selector(resetProgress), keyEquivalent: "r"))
        menu.addItem(NSMenuItem(title: "Test +1 Key", action: #selector(testKeyCounter), keyEquivalent: "t"))
        menu.addItem(NSMenuItem(title: "Restart Key Counter", action: #selector(restartKeyCounter), keyEquivalent: "k"))

        menu.addItem(NSMenuItem.separator())

        let cornerMenu = NSMenuItem(title: "Move to Corner", action: nil, keyEquivalent: "")
        let submenu = NSMenu()
        for corner in CompanionCorner.allCases {
            let menuItem = NSMenuItem(title: corner.label, action: #selector(moveWindow(_:)), keyEquivalent: "")
            menuItem.representedObject = corner.rawValue
            submenu.addItem(menuItem)
        }
        menu.setSubmenu(submenu, for: cornerMenu)
        menu.addItem(cornerMenu)

        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Request Accessibility Permission", action: #selector(requestAccessibilityPermission), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Request Input Monitoring Permission", action: #selector(requestInputMonitoringPermission), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Open Accessibility Settings", action: #selector(openAccessibilitySettings), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Open Input Monitoring Settings", action: #selector(openInputMonitoringSettings), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Reveal Running App", action: #selector(revealRunningApp), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Copy Diagnostics", action: #selector(copyDiagnostics), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Quit EarthNaru", action: #selector(quit), keyEquivalent: "q"))

        statusItem?.menu = menu
    }

    @objc private func togglePause() {
        game.isPaused.toggle()
        rebuildMenu()
    }

    @objc private func toggleWindow() {
        if companionWindow?.isVisible == true {
            companionWindow?.hide()
        } else {
            companionWindow?.show()
        }
        rebuildMenu()
    }

    @objc private func resetProgress() {
        game.reset()
        rebuildMenu()
    }

    @objc private func resetToday() {
        game.resetToday()
        rebuildMenu()
    }

    @objc private func testKeyCounter() {
        game.addKeypress()
        rebuildMenu()
    }

    @objc private func restartKeyCounter() {
        keyboardMonitor.stop()
        startKeyboardMonitorIfAllowed(promptForPermission: false)
        rebuildMenu()
    }

    @objc private func requestAccessibilityPermission() {
        keyboardMonitor.requestAccessibilityPermission()
        startKeyboardMonitorIfAllowed(promptForPermission: false)
    }

    @objc private func requestInputMonitoringPermission() {
        keyboardMonitor.requestInputMonitoringPermission()
        startKeyboardMonitorIfAllowed(promptForPermission: false)
    }

    @objc private func moveWindow(_ sender: NSMenuItem) {
        guard
            let rawValue = sender.representedObject as? String,
            let corner = CompanionCorner(rawValue: rawValue)
        else { return }

        companionWindow?.move(to: corner)
    }

    @objc private func openAccessibilitySettings() {
        NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!)
    }

    @objc private func openInputMonitoringSettings() {
        NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_ListenEvent")!)
    }

    @objc private func revealRunningApp() {
        NSWorkspace.shared.activateFileViewerSelecting([Bundle.main.bundleURL])
    }

    @objc private func copyDiagnostics() {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(diagnosticReport, forType: .string)
    }

    @objc private func quit() {
        NSApp.terminate(nil)
    }

    private var diagnosticReport: String {
        """
        EarthNaruMac diagnostics
        Key counter: \(keyboardMonitor.isRunning ? "On" : "Off")
        Monitor: \(keyboardMonitor.activeMonitorSummary)
        Permissions: \(keyboardMonitor.permissionSummary)
        Last key: \(keyboardMonitor.lastEventSummary)
        Monitor install: \(keyboardMonitor.installSummary)
        Bundle id: \(keyboardMonitor.bundleIdentifier)
        App path: \(keyboardMonitor.runningAppPath)
        Executable: \(keyboardMonitor.executablePath)
        """
    }
}
