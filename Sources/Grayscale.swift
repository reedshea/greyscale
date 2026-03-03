// Grayscale.swift — Core toggle logic
// See Sources/Bridge.h for details on the private API declarations.

import Foundation
import CoreGraphics

/// Returns true if the system grayscale display filter is currently active.
func grayscaleEnabled() -> Bool {
    return MADisplayFilterPrefGetCategoryEnabled(SYSTEM_FILTER)
        && (MADisplayFilterPrefGetType(SYSTEM_FILTER) == GRAYSCALE_TYPE)
}

/// Returns true if Night Shift is currently active.
func nightShiftActive() -> Bool {
    let client = CBBlueLightClient()
    var status = CBBlueLightClient_StatusData_t()
    guard client.getBlueLightStatus(&status) else { return false }
    return status.active.boolValue
}

/// Returns the current Night Shift strength (0.0–1.0). Returns 0 if inactive.
func nightShiftStrength() -> Float {
    let client = CBBlueLightClient()
    var strength: Float = 0
    guard client.getStrength(&strength) else { return 0 }
    return strength
}

/// Applies warm gamma curves to simulate Night Shift warmth on a greyscale display.
/// The public gamma API applies at the hardware LUT level (after accessibility
/// filters), so this re-tints the already-greyscale output into warm greys.
func applyWarmGamma() {
    let strength = nightShiftStrength()
    guard strength > 0 else { return }

    let blueMax = CGGammaValue(1.0 - strength * 0.45)
    let greenMax = CGGammaValue(1.0 - strength * 0.15)

    CGSetDisplayTransferByFormula(
        CGMainDisplayID(),
        0, 1.0, 1.0,        // Red: unchanged
        0, greenMax, 1.0,    // Green: slightly reduced
        0, blueMax, 1.0      // Blue: significantly reduced
    )
}

/// Removes custom warm gamma, restoring ColorSync defaults.
func removeWarmGamma() {
    CGDisplayRestoreColorSyncSettings()
}

/// Enables the system grayscale display filter.
func enableGrayscale() {
    // CGDisplayForceToGray applies greyscale at the compositor level.
    // The hardware gamma LUT (CGSetDisplayTransferByFormula) applies after
    // the compositor, so warm gamma curves survive on top of this greyscale.
    CGDisplayForceToGray(true)

    // Also persist via MediaAccessibility so System Settings stays in sync
    // and universalaccessd restores greyscale on wake.
    MADisplayFilterPrefSetType(SYSTEM_FILTER, GRAYSCALE_TYPE)
    MADisplayFilterPrefSetCategoryEnabled(SYSTEM_FILTER, true)
    _UniversalAccessDStart(UNIVERSALACCESSD_MAGIC)

    if nightShiftActive() {
        // Delay to ensure universalaccessd has finished before we set gamma,
        // in case it resets the gamma LUT as part of applying its filter.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            applyWarmGamma()
        }
    }
}

/// Disables the system grayscale display filter.
func disableGrayscale() {
    CGDisplayForceToGray(false)
    MADisplayFilterPrefSetCategoryEnabled(SYSTEM_FILTER, false)
    _UniversalAccessDStart(UNIVERSALACCESSD_MAGIC)
    removeWarmGamma()
}

/// Toggles the system grayscale display filter.
func toggleGrayscale() {
    if grayscaleEnabled() {
        disableGrayscale()
    } else {
        enableGrayscale()
    }
}
