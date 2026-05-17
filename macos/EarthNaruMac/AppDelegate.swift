import AppKit
import SwiftUI

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var companionWindow: CompanionWindowController?
    private var statusItem: NSStatusItem?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)

        companionWindow = CompanionWindowController()
        companionWindow?.show()

        configureMenuBar()
    }

    private func configureMenuBar() {
        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        item.button?.title = "🌍"
        statusItem = item
        rebuildMenu()
    }

    private func rebuildMenu() {
        let menu = NSMenu()

        menu.addItem(NSMenuItem(
            title: companionWindow?.isVisible == true ? "Hide Companion" : "Show Companion",
            action: #selector(toggleWindow),
            keyEquivalent: "m"
        ))

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
        menu.addItem(NSMenuItem(title: "Quit EarthNaru", action: #selector(quit), keyEquivalent: "q"))

        statusItem?.menu = menu
    }

    @objc private func toggleWindow() {
        if companionWindow?.isVisible == true {
            companionWindow?.hide()
        } else {
            companionWindow?.show()
        }
        rebuildMenu()
    }

    @objc private func moveWindow(_ sender: NSMenuItem) {
        guard
            let rawValue = sender.representedObject as? String,
            let corner = CompanionCorner(rawValue: rawValue)
        else { return }

        companionWindow?.move(to: corner)
    }

    @objc private func quit() {
        NSApp.terminate(nil)
    }
}
