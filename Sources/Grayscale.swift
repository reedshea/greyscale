// Grayscale.swift — Core toggle logic using CGDisplayForceToGray
// See Sources/Bridge.h for details on the private API declarations.

import Foundation

/// Returns true if the system grayscale display filter is currently active.
func grayscaleEnabled() -> Bool {
    return CGDisplayUsesForceToGray()
}

/// Enables the system grayscale display filter.
func enableGrayscale() {
    CGDisplayForceToGray(true)
}

/// Disables the system grayscale display filter.
func disableGrayscale() {
    CGDisplayForceToGray(false)
}

/// Toggles the system grayscale display filter.
func toggleGrayscale() {
    if grayscaleEnabled() {
        disableGrayscale()
    } else {
        enableGrayscale()
    }
}
