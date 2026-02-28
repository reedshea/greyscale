// main.swift — App entry point for Greyscale menu bar toggle

import AppKit

let app = NSApplication.shared
app.setActivationPolicy(.accessory)

let delegate = AppDelegate()
app.delegate = delegate
app.run()
