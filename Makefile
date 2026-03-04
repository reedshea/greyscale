APP_NAME = Greyscale
VERSION  = 2.2
BUILD_DIR = build
BUNDLE = $(BUILD_DIR)/$(APP_NAME).app
BUNDLE_CONTENTS = $(BUNDLE)/Contents
BUNDLE_MACOS = $(BUNDLE_CONTENTS)/MacOS
BUNDLE_RESOURCES = $(BUNDLE_CONTENTS)/Resources

SWIFT_FILES = Sources/main.swift Sources/AppDelegate.swift Sources/Grayscale.swift
BRIDGE_HEADER = Sources/Bridge.h

SWIFTC = swiftc
SWIFTFLAGS = -O \
	-import-objc-header $(BRIDGE_HEADER) \
	-framework Cocoa \
	-framework MediaAccessibility \
	-framework ServiceManagement \
	-F/System/Library/PrivateFrameworks \
	-framework CoreBrightness \
	-lUniversalAccess

# Load .env if present (see .env.example for template)
-include .env
export

# Release settings
SIGNING_IDENTITY ?= Developer ID Application
NOTARY_PROFILE ?= notary
DMG = $(BUILD_DIR)/$(APP_NAME)-$(VERSION).dmg

ICON_SOURCE = Resources/icon.png
ICONSET = Resources/AppIcon.iconset
ICNS = Resources/AppIcon.icns

.PHONY: all clean install sign dmg notarize release icon

all: $(BUNDLE)

$(ICNS): $(ICON_SOURCE)
	@mkdir -p $(ICONSET)
	sips -z 16 16     $(ICON_SOURCE) --out $(ICONSET)/icon_16x16.png
	sips -z 32 32     $(ICON_SOURCE) --out $(ICONSET)/icon_16x16@2x.png
	sips -z 32 32     $(ICON_SOURCE) --out $(ICONSET)/icon_32x32.png
	sips -z 64 64     $(ICON_SOURCE) --out $(ICONSET)/icon_32x32@2x.png
	sips -z 128 128   $(ICON_SOURCE) --out $(ICONSET)/icon_128x128.png
	sips -z 256 256   $(ICON_SOURCE) --out $(ICONSET)/icon_128x128@2x.png
	sips -z 256 256   $(ICON_SOURCE) --out $(ICONSET)/icon_256x256.png
	sips -z 512 512   $(ICON_SOURCE) --out $(ICONSET)/icon_256x256@2x.png
	sips -z 512 512   $(ICON_SOURCE) --out $(ICONSET)/icon_512x512.png
	sips -z 1024 1024 $(ICON_SOURCE) --out $(ICONSET)/icon_512x512@2x.png
	iconutil -c icns $(ICONSET) -o $(ICNS)
	@echo "Generated $(ICNS)"

icon: $(ICNS)

$(BUNDLE): $(SWIFT_FILES) $(BRIDGE_HEADER) Resources/Info.plist $(ICNS)
	@mkdir -p $(BUILD_DIR)
	$(SWIFTC) $(SWIFTFLAGS) $(SWIFT_FILES) -o $(BUILD_DIR)/$(APP_NAME)
	@mkdir -p $(BUNDLE_MACOS)
	@mkdir -p $(BUNDLE_RESOURCES)
	@mv $(BUILD_DIR)/$(APP_NAME) $(BUNDLE_MACOS)/$(APP_NAME)
	@cp Resources/Info.plist $(BUNDLE_CONTENTS)/Info.plist
	@cp $(ICNS) $(BUNDLE_RESOURCES)/AppIcon.icns
	@echo "Built $(BUNDLE)"

clean:
	rm -rf $(BUILD_DIR)

install: $(BUNDLE)
	cp -R $(BUNDLE) /Applications/$(APP_NAME).app
	@echo "Installed to /Applications/$(APP_NAME).app"

# --- Release targets ---

sign: $(BUNDLE)
	codesign --force --deep --options runtime \
		--sign "$(SIGNING_IDENTITY)" \
		$(BUNDLE)
	codesign --verify --verbose $(BUNDLE)
	@echo "Signed $(BUNDLE)"

dmg: $(BUNDLE)
	@rm -rf $(BUILD_DIR)/dmg_staging $(DMG)
	@mkdir -p $(BUILD_DIR)/dmg_staging
	@cp -R $(BUNDLE) $(BUILD_DIR)/dmg_staging/
	@if command -v create-dmg >/dev/null 2>&1; then \
		create-dmg \
			--volname "$(APP_NAME)" \
			--window-pos 200 120 \
			--window-size 540 380 \
			--icon-size 128 \
			--icon "$(APP_NAME).app" 130 175 \
			--hide-extension "$(APP_NAME).app" \
			--app-drop-link 410 175 \
			$(if $(wildcard Resources/dmg-background.png),--background Resources/dmg-background.png) \
			"$(DMG)" \
			$(BUILD_DIR)/dmg_staging || true; \
	else \
		ln -s /Applications $(BUILD_DIR)/dmg_staging/Applications; \
		hdiutil create -volname "$(APP_NAME)" \
			-srcfolder $(BUILD_DIR)/dmg_staging \
			-ov -format UDZO \
			"$(DMG)"; \
		@echo "Tip: brew install create-dmg for a styled drag-to-Applications DMG"; \
	fi
	@rm -rf $(BUILD_DIR)/dmg_staging
	@echo "Created $(DMG)"

notarize: $(DMG)
	xcrun notarytool submit "$(DMG)" \
		--keychain-profile "$(NOTARY_PROFILE)" \
		--wait
	xcrun stapler staple "$(DMG)"
	@echo "Notarized and stapled $(DMG)"

release: sign dmg notarize
	@echo "Release complete: $(DMG)"
