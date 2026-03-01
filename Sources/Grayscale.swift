// Grayscale.swift — Core toggle logic
// See Sources/Bridge.h for details on the private API declarations.

import Foundation

/// Returns true if the system grayscale display filter is currently active.
func grayscaleEnabled() -> Bool {
    return MADisplayFilterPrefGetCategoryEnabled(SYSTEM_FILTER)
        && (MADisplayFilterPrefGetType(SYSTEM_FILTER) == GRAYSCALE_TYPE)
}

/// Enables the system grayscale display filter.
func enableGrayscale() {
    MADisplayFilterPrefSetType(SYSTEM_FILTER, GRAYSCALE_TYPE)
    MADisplayFilterPrefSetCategoryEnabled(SYSTEM_FILTER, true)
    _UniversalAccessDStart(UNIVERSALACCESSD_MAGIC)
}

/// Disables the system grayscale display filter.
func disableGrayscale() {
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
