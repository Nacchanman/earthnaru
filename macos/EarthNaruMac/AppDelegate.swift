import AppKit
import SwiftUI

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private let game = GameModel()
    private let keyboardMonitor = KeyboardMonitor()
    private var companionWindow: CompanionWindowController?
    private var statusItem: NSStatusItem?
    private var permissionRetryTimer: Timer?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)

        companionWindow = CompanionWindowController(game: game)
        companionWindow?.show()

        configureMenuBar()
        startKeyboardMonitorIfAllowed(promptForPermission: false)
    }

    func applicationWillTerminate(_ notification: Notification) {
        permissionRetryTimer?.invalidate()
        keyboardMonitor.stop()
    }

    private func startKeyboardMonitorIfAllowed(promptForPermission: Bool) {
        keyboardMonitor.onKeyDown = { [weak self] in
            Task { @MainActor in
                self?.game.addKeypress()
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
        item.button?.title = "🌍💪"
        statusItem = item
        rebuildMenu()
    }

    private func rebuildMenu() {
        let menu = NSMenu()

        let statusTitle: String
        if keyboardMonitor.isRunning {
            statusTitle = "Key counter: On (\(keyboardMonitor.activeMonitorSummary))"
        } else {
            statusTitle = keyboardMonitor.lastError ?? "Key counter: Needs permission"
        }

        let status = NSMenuItem(title: statusTitle, action: nil, keyEquivalent: "")
        status.isEnabled = false
        menu.addItem(status)

        menu.addItem(NSMenuItem.separator())

        menu.addItem(NSMenuItem(title: game.isPaused ? "Resume" : "Pause", action: #selector(togglePause), keyEquivalent: "p"))
        menu.addItem(NSMenuItem(title: companionWindow?.isVisible == true ? "Hide Mascot" : "Show Mascot", action: #selector(toggleWindow), keyEquivalent: "m"))
        menu.addItem(NSMenuItem(title: "Reset Progress", action: #selector(resetProgress), keyEquivalent: "r"))
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
        menu.addItem(NSMenuItem(title: "Open Accessibility Settings", action: #selector(openAccessibilitySettings), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Open Input Monitoring Settings", action: #selector(openInputMonitoringSettings), keyEquivalent: ""))
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

    @objc private func quit() {
        NSApp.terminate(nil)
    }
}
