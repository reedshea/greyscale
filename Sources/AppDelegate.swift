// AppDelegate.swift — Menu bar UI for the Greyscale toggle app
//
// Left-click the status bar icon to toggle grayscale on/off.
// Right-click for a menu with Quit.

import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

        if let button = statusItem.button {
            button.action = #selector(statusBarButtonClicked(_:))
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
            button.target = self
        }

        updateIcon()

        // Update our icon if grayscale is toggled via System Settings
        NSWorkspace.shared.notificationCenter.addObserver(
            self,
            selector: #selector(accessibilityDisplayOptionsChanged),
            name: NSWorkspace.accessibilityDisplayOptionsDidChangeNotification,
            object: nil
        )
    }

    @objc private func statusBarButtonClicked(_ sender: Any?) {
        guard let event = NSApp.currentEvent else { return }

        if event.type == .rightMouseUp {
            showMenu()
        } else {
            toggleGrayscale()
            updateIcon()
        }
    }

    @objc private func accessibilityDisplayOptionsChanged() {
        updateIcon()
    }

    private func showMenu() {
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Quit Greyscale", action: #selector(NSApplication.terminate(_:)), keyEquivalent: ""))
        statusItem.menu = menu
        statusItem.button?.performClick(nil)
        statusItem.menu = nil
    }

    private func updateIcon() {
        guard let button = statusItem.button else { return }
        let isOn = grayscaleEnabled()

        if #available(macOS 11.0, *) {
            let symbolName = isOn ? "circle.lefthalf.filled" : "circle.lefthalf.strikethrough"
            let config = NSImage.SymbolConfiguration(pointSize: 16, weight: .regular)
            button.image = NSImage(systemSymbolName: symbolName, accessibilityDescription: "Greyscale")?
                .withSymbolConfiguration(config)
        } else {
            button.title = isOn ? "●" : "○"
            button.image = nil
        }

        button.toolTip = isOn ? "Greyscale: ON (click to toggle)" : "Greyscale: OFF (click to toggle)"
    }

    func applicationWillTerminate(_ notification: Notification) {
        NSWorkspace.shared.notificationCenter.removeObserver(self)
    }
}
