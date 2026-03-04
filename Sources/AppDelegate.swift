// AppDelegate.swift — Menu bar UI for the Greyscale toggle app
//
// Left-click the status bar icon to toggle grayscale on/off.
// Right-click for a menu with Quit.

import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var blueLightClient: CBBlueLightClient?

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

        // Monitor Night Shift status changes (schedule toggles, strength changes)
        blueLightClient = CBBlueLightClient()
        blueLightClient?.setStatusNotificationBlock { [weak self] in
            self?.nightShiftStatusChanged()
        }

        // Apply warm gamma if greyscale is already on at launch
        if grayscaleEnabled() && nightShiftActive() {
            applyWarmGamma()
        }

        // Re-apply after display reconfiguration (sleep/wake resets gamma + ForceToGray)
        CGDisplayRegisterReconfigurationCallback({ _, flags, _ in
            guard flags.contains(.addFlag) else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                guard grayscaleEnabled() else { return }
                CGDisplayForceToGray(true)
                if nightShiftActive() {
                    applyWarmGamma()
                }
            }
        }, nil)
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
        // Re-apply warm gamma after universalaccessd has finished applying
        // its filter (which may have reset the gamma LUT).
        if grayscaleEnabled() && nightShiftActive() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                applyWarmGamma()
            }
        }
    }

    private func nightShiftStatusChanged() {
        guard grayscaleEnabled() else { return }
        if nightShiftActive() {
            CGDisplayForceToGray(true)
            applyWarmGamma()
        } else {
            removeWarmGamma()
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
            let symbolName = isOn ? "swatchpalette" : "swatchpalette.fill"
            image = NSImage(systemSymbolName: symbolName, accessibilityDescription: "Greyscale")
        }

        if let image = image {
            button.image = image
            button.title = ""
        } else {
            button.image = nil
            button.title = isOn ? "●" : "○"
        }

        // button.toolTip = isOn ? "Greyscale: ON (click to toggle)" : "Greyscale: OFF (click to toggle)"
    }

    func applicationWillTerminate(_ notification: Notification) {
        NSWorkspace.shared.notificationCenter.removeObserver(self)
        removeWarmGamma()
    }
}
