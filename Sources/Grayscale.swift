// Grayscale.swift — Core toggle logic using MediaAccessibility framework
// See Sources/Bridge.h for details on the private API declarations.

import Foundation

/// Returns true if the system grayscale display filter is currently active.
func grayscaleEnabled() -> Bool {
    return MADisplayFilterPrefGetCategoryEnabled(SYSTEM_FILTER)
        && (MADisplayFilterPrefGetType(SYSTEM_FILTER) == GRAYSCALE_TYPE)
}

/// Enables the system grayscale display filter.
func enableGrayscale() {
    // Instant visual change (no system dialog)
    CGDisplayForceToGray(true)
    // Write preferences so System Settings stays in sync
    // and the daemon restores grayscale after sleep/wake
    MADisplayFilterPrefSetType(SYSTEM_FILTER, GRAYSCALE_TYPE)
    MADisplayFilterPrefSetCategoryEnabled(SYSTEM_FILTER, true)
}

/// Disables the system grayscale display filter.
func disableGrayscale() {
    CGDisplayForceToGray(false)
    MADisplayFilterPrefSetCategoryEnabled(SYSTEM_FILTER, false)
}

/// Toggles the system grayscale display filter.
func toggleGrayscale() {
    if grayscaleEnabled() {
        disableGrayscale()
    } else {
        enableGrayscale()
    }
}
