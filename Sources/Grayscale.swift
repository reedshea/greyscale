// Grayscale.swift — Core toggle logic
// See Sources/Bridge.h for details on the private API declarations.
//
// Uses CGDisplayForceToGray for instant visual change, then writes
// MediaAccessibility preferences so the state persists through sleep
// and stays in sync with System Settings.

import Foundation

/// Returns true if the system grayscale display filter is currently active.
func grayscaleEnabled() -> Bool {
    return CGDisplayUsesForceToGray()
}

/// Enables the system grayscale display filter.
func enableGrayscale() {
    CGDisplayForceToGray(true)
    MADisplayFilterPrefSetType(SYSTEM_FILTER, GRAYSCALE_TYPE)
    MADisplayFilterPrefSetCategoryEnabled(SYSTEM_FILTER, true)
    _UniversalAccessDStart(UNIVERSALACCESSD_MAGIC)
}

/// Disables the system grayscale display filter.
func disableGrayscale() {
    CGDisplayForceToGray(false)
    MADisplayFilterPrefSetCategoryEnabled(SYSTEM_FILTER, false)
    _UniversalAccessDStart(UNIVERSALACCESSD_MAGIC)
}

/// Toggles the system grayscale display filter.
func toggleGrayscale() {
    if grayscaleEnabled() {
        disableGrayscale()
    } else {
        enableGrayscale()
    }
}
