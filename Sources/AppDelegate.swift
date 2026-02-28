// AppDelegate.swift — Menu bar UI for the Greyscale toggle app
//
// Left-click the status bar icon to toggle grayscale on/off.
// Right-click for a menu with Quit.

import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var grayscaleWasOn = false

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

        if let button = statusItem.button {
            button.action = #selector(statusBarButtonClicked(_:))
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
            button.target = self
        }

        grayscaleWasOn = grayscaleEnabled()
        updateIcon()

        // Update our icon if grayscale is toggled via System Settings
        NSWorkspace.shared.notificationCenter.addObserver(
            self,
            selector: #selector(accessibilityDisplayOptionsChanged),
            name: NSWorkspace.accessibilityDisplayOptionsDidChangeNotification,
            object: nil
        )

        // Re-apply grayscale after wake from sleep (CGDisplayForceToGray
        // doesn't persist through sleep on its own)
        NSWorkspace.shared.notificationCenter.addObserver(
            self,
            selector: #selector(didWake),
            name: NSWorkspace.didWakeNotification,
            object: nil
        )
    }

    @objc private func statusBarButtonClicked(_ sender: Any?) {
        guard let event = NSApp.currentEvent else { return }

        if event.type == .rightMouseUp {
            showMenu()
        } else {
            toggleGrayscale()
            grayscaleWasOn = grayscaleEnabled()
            updateIcon()
        }
    }

    @objc private func accessibilityDisplayOptionsChanged() {
        grayscaleWasOn = grayscaleEnabled()
        updateIcon()
    }

    @objc private func didWake() {
        if grayscaleWasOn {
            enableGrayscale()
        }
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

        // Try SF Symbols (macOS 11+), fall back to text
        var image: NSImage? = nil
        if #available(macOS 11.0, *) {
            let symbolName = isOn ? "circle.lefthalf.filled" : "circle"
            image = NSImage(systemSymbolName: symbolName, accessibilityDescription: "Greyscale")
        }

        if let image = image {
            button.image = image
            button.title = ""
        } else {
            button.image = nil
            button.title = isOn ? "●" : "○"
        }

        button.toolTip = isOn ? "Greyscale: ON (click to toggle)" : "Greyscale: OFF (click to toggle)"
    }

    func applicationWillTerminate(_ notification: Notification) {
        NSWorkspace.shared.notificationCenter.removeObserver(self)
    }
}
