import AppKit
import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate {
    private let game = GameModel()
    private let keyboardMonitor = KeyboardMonitor()
    private var companionWindow: CompanionWindowController?
    private var statusItem: NSStatusItem?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)

        companionWindow = CompanionWindowController(game: game)
        companionWindow?.show()

        configureMenuBar()
        startKeyboardMonitorIfAllowed()
    }

    func applicationWillTerminate(_ notification: Notification) {
        keyboardMonitor.stop()
    }

    private func startKeyboardMonitorIfAllowed() {
        keyboardMonitor.onKeyDown = { [weak self] in
            DispatchQueue.main.async {
                self?.game.addKeypress()
            }
        }

        if KeyboardMonitor.isAccessibilityTrusted(prompt: true) {
            keyboardMonitor.start()
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

        let statusTitle = keyboardMonitor.isRunning ? "Key counter: On" : "Key counter: Needs permission"
        let status = NSMenuItem(title: statusTitle, action: nil, keyEquivalent: "")
        status.isEnabled = false
        menu.addItem(status)

        menu.addItem(NSMenuItem.separator())

        menu.addItem(NSMenuItem(title: game.isPaused ? "Resume" : "Pause", action: #selector(togglePause), keyEquivalent: "p"))
        menu.addItem(NSMenuItem(title: companionWindow?.isVisible == true ? "Hide Mascot" : "Show Mascot", action: #selector(toggleWindow), keyEquivalent: "m"))
        menu.addItem(NSMenuItem(title: "Reset Progress", action: #selector(resetProgress), keyEquivalent: "r"))

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
        menu.addItem(NSMenuItem(title: "Open Accessibility Settings", action: #selector(openAccessibilitySettings), keyEquivalent: ""))
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

    @objc private func quit() {
        NSApp.terminate(nil)
    }
}
