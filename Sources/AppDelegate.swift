// AppDelegate.swift — Menu bar UI for the Greyscale toggle app
//
// Left-click the status bar icon to toggle grayscale on/off.
// Right-click for a menu with Quit.

import AppKit
import ServiceManagement

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var blueLightClient: CBBlueLightClient?

    private static let showInDockKey = "ShowInDock"
    private static let hasLaunchedBeforeKey = "HasLaunchedBefore"

    private var showInDock: Bool {
        get { UserDefaults.standard.bool(forKey: Self.showInDockKey) }
        set {
            UserDefaults.standard.set(newValue, forKey: Self.showInDockKey)
            NSApp.setActivationPolicy(newValue ? .regular : .accessory)
        }
    }

    @available(macOS 13.0, *)
    private var openAtLogin: Bool {
        get { SMAppService.mainApp.status == .enabled }
        set {
            do {
                if newValue {
                    try SMAppService.mainApp.register()
                } else {
                    try SMAppService.mainApp.unregister()
                }
            } catch {}
        }
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Apply dock visibility setting
        if showInDock {
            NSApp.setActivationPolicy(.regular)
        }

        // Enable "Open at Login" by default on first launch
        if !UserDefaults.standard.bool(forKey: Self.hasLaunchedBeforeKey) {
            UserDefaults.standard.set(true, forKey: Self.hasLaunchedBeforeKey)
            if #available(macOS 13.0, *) {
                openAtLogin = true
            }
        }
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

        if #available(macOS 13.0, *) {
            let loginItem = NSMenuItem(title: "Open at Login", action: #selector(toggleOpenAtLogin), keyEquivalent: "")
            loginItem.target = self
            loginItem.state = openAtLogin ? .on : .off
            menu.addItem(loginItem)
        }

        let dockItem = NSMenuItem(title: "Show in Dock", action: #selector(toggleShowInDock), keyEquivalent: "")
        dockItem.target = self
        dockItem.state = showInDock ? .on : .off
        menu.addItem(dockItem)

        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit Greyscale", action: #selector(NSApplication.terminate(_:)), keyEquivalent: ""))
        statusItem.menu = menu
        statusItem.button?.performClick(nil)
        statusItem.menu = nil
    }

    @available(macOS 13.0, *)
    @objc private func toggleOpenAtLogin() {
        openAtLogin.toggle()
    }

    @objc private func toggleShowInDock() {
        showInDock.toggle()
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

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        toggleGrayscale()
        updateIcon()
        return false
    }

    func applicationWillTerminate(_ notification: Notification) {
        NSWorkspace.shared.notificationCenter.removeObserver(self)
        removeWarmGamma()
    }
}
