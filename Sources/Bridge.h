//
//  Bridge.h
//  Greyscale
//
//  Bridging header declaring private macOS framework functions for
//  controlling the system display color filter (grayscale mode).
//
//  The MediaAccessibility functions write preferences to
//  com.apple.mediaaccessibility, and the universalaccessd daemon
//  listens for changes and applies the actual display filter.
//
//  Reference: https://github.com/brettferdosi/grayscale
//

#ifndef Bridge_h
#define Bridge_h

#include <stdbool.h>

// --- MediaAccessibility.framework ---
// Located at: /System/Library/Frameworks/MediaAccessibility.framework

extern bool MADisplayFilterPrefGetCategoryEnabled(int filter)
    __attribute__((weak_import));

extern void MADisplayFilterPrefSetCategoryEnabled(int filter, bool enabled)
    __attribute__((weak_import));

extern int MADisplayFilterPrefGetType(int filter)
    __attribute__((weak_import));

extern void MADisplayFilterPrefSetType(int filter, int type)
    __attribute__((weak_import));

// --- /usr/lib/libUniversalAccess.dylib ---
// After changing MediaAccessibility preferences, the universalaccessd
// daemon must be woken to actually apply the display filter change.

extern void _UniversalAccessDStart(int magic)
    __attribute__((weak_import));

// --- Constants ---

static const int SYSTEM_FILTER = 0x1;
static const int GRAYSCALE_TYPE = 0x1;
static const int UNIVERSALACCESSD_MAGIC = 0x8;

#endif /* Bridge_h */
