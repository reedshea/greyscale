# Greyscale

A macOS menu bar app that toggles your display between color and greyscale with a single click.

**[Download the latest release](https://github.com/reedshea/greyscale/releases/latest)** — grab the DMG, drag to Applications, and go.

Greyscale mode makes your screen feel more like a newspaper than a television — technology is available but fades into the background. This app makes it trivial to flip back and forth.

## How it works

The app uses the macOS MediaAccessibility framework to control the system display color filter — the same mechanism that System Settings uses internally. Unlike the old AppleScript approach, this does not require Accessibility permissions or manual System Settings configuration, and it persists through sleep/wake.

## Build

Requires Xcode Command Line Tools (`xcode-select --install`):

```
make
```

This produces `build/Greyscale.app`.

## Install

```
make install
```

Or drag `build/Greyscale.app` to your Applications folder.

If you download the DMG from the [Releases page](https://github.com/reedshea/greyscale/releases/latest), the app is signed and notarized — it will open without any Gatekeeper warnings. If you build from source, right-click the app and select "Open" to bypass Gatekeeper once.

## Usage

- **Left-click** the menu bar icon to toggle greyscale on/off
- **Right-click** for a menu with Quit

The icon reflects the current state and stays in sync if you toggle greyscale via System Settings.

## Release

To build a signed, notarized DMG for distribution:

```
brew install create-dmg   # one-time, for the drag-to-Applications DMG layout
make release IDENTITY="Developer ID Application: Your Name (TEAMID)"
```

This runs `sign` → `dmg` → `notarize` and produces `build/Greyscale-2.0.dmg`.

Before your first notarization, store your App Store Connect credentials:

```
xcrun notarytool store-credentials notary \
  --apple-id you@example.com \
  --team-id TEAMID \
  --password <app-specific-password>
```

You can also run the targets individually (`make sign`, `make dmg`, `make notarize`).

### App icon

Place your icon at `Resources/AppIcon.icns`. To generate from a 1024x1024 PNG:

```
mkdir AppIcon.iconset
for size in 16 32 128 256 512; do
  sips -z $size $size icon.png --out AppIcon.iconset/icon_${size}x${size}.png
  sips -z $((size*2)) $((size*2)) icon.png --out AppIcon.iconset/icon_${size}x${size}@2x.png
done
iconutil -c icns AppIcon.iconset -o AppIcon.icns
```

### DMG background

Optionally place a `Resources/dmg-background.png` (typically 540x380) to use as the DMG window background.

## Requirements

- macOS 10.15 (Catalina) or later
- Xcode Command Line Tools

## Previous version

The original AppleScript approach is preserved in the `script` file for reference. It required manual configuration of Accessibility shortcuts and permissions, and broke across macOS updates.

## Credits

- The logo (`greyscale.webp`) is from [Gray-Switch](https://play.google.com/store/apps/details?id=com.vegardit.grayswitch)
- The MediaAccessibility approach is based on research from [brettferdosi/grayscale](https://github.com/brettferdosi/grayscale)
