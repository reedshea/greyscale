# Greyscale

A macOS menu bar app that toggles your display between color and greyscale with a single click.

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

On first launch, macOS Gatekeeper will block the unsigned app. Right-click the app and select "Open" to bypass this once.

## Usage

- **Left-click** the menu bar icon to toggle greyscale on/off
- **Right-click** for a menu with Quit

The icon reflects the current state and stays in sync if you toggle greyscale via System Settings.

## Requirements

- macOS 10.15 (Catalina) or later
- Xcode Command Line Tools

## Previous version

The original AppleScript approach is preserved in the `script` file for reference. It required manual configuration of Accessibility shortcuts and permissions, and broke across macOS updates.

## Credits

- The logo (`greyscale.webp`) is from [Gray-Switch](https://play.google.com/store/apps/details?id=com.vegardit.grayswitch)
- The MediaAccessibility approach is based on research from [brettferdosi/grayscale](https://github.com/brettferdosi/grayscale)
