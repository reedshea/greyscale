APP_NAME = Greyscale
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
	-lUniversalAccess

.PHONY: all clean install

all: $(BUNDLE)

$(BUNDLE): $(SWIFT_FILES) $(BRIDGE_HEADER) Resources/Info.plist
	@mkdir -p $(BUILD_DIR)
	$(SWIFTC) $(SWIFTFLAGS) $(SWIFT_FILES) -o $(BUILD_DIR)/$(APP_NAME)
	@mkdir -p $(BUNDLE_MACOS)
	@mkdir -p $(BUNDLE_RESOURCES)
	@mv $(BUILD_DIR)/$(APP_NAME) $(BUNDLE_MACOS)/$(APP_NAME)
	@cp Resources/Info.plist $(BUNDLE_CONTENTS)/Info.plist
	@echo "Built $(BUNDLE)"

clean:
	rm -rf $(BUILD_DIR)

install: $(BUNDLE)
	cp -R $(BUNDLE) /Applications/$(APP_NAME).app
	@echo "Installed to /Applications/$(APP_NAME).app"
