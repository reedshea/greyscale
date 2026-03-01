# Greyscale

A macOS menu bar app that toggles your display between color and greyscale with a single click.

Greyscale mode makes your screen feel more like a newspaper than a television — technology is available but fades into the background. This app makes it trivial to flip back and forth.

## Download & Install

**[Download the latest release](https://github.com/reedshea/greyscale/releases/latest)** — grab the DMG, drag to Applications, and go.

## Usage

**Click** the menu bar icon to toggle greyscale on/off:

&nbsp;&nbsp;&nbsp;&nbsp;<img src="Resources/swatchpalette.fill.svg" width="16" />&nbsp;&nbsp;Color mode

&nbsp;&nbsp;&nbsp;&nbsp;<img src="Resources/swatchpalette.svg" width="16" />&nbsp;&nbsp;Greyscale mode

**Right-click** for a menu with an option to quit.

## How it works

The app uses the macOS MediaAccessibility framework to control the system display color filter — the same mechanism that System Settings uses internally. This does not require Accessibility permissions or manual System Settings configuration, and it persists through sleep/wake.

## Building from source

```
make
```

Produces `build/Greyscale.app`. For signed builds, use `make release`. See the Makefile for details.
