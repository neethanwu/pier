APP_NAME = Pier
BUILD_DIR = .build/release
APP_BUNDLE = $(APP_NAME).app
DMG_NAME = $(APP_NAME).dmg
VERSION = 0.1.0

# Set your Developer ID identity (find yours with: security find-identity -v -p codesigning)
# Example: SIGN_IDENTITY = Developer ID Application: Your Org Name (TEAMID)
SIGN_IDENTITY ?= -

.PHONY: build bundle run release dmg sign notarize clean

build:
	swift build -c release

bundle: build
	rm -rf $(APP_BUNDLE)
	mkdir -p $(APP_BUNDLE)/Contents/MacOS
	mkdir -p $(APP_BUNDLE)/Contents/Resources
	cp $(BUILD_DIR)/$(APP_NAME) $(APP_BUNDLE)/Contents/MacOS/
	cp SupportFiles/Info.plist $(APP_BUNDLE)/Contents/
	cp SupportFiles/AppIcon.icns $(APP_BUNDLE)/Contents/Resources/

sign: bundle
	codesign --force --options runtime --sign "$(SIGN_IDENTITY)" $(APP_BUNDLE)
	@echo "Signed $(APP_BUNDLE) with: $(SIGN_IDENTITY)"

dmg: sign
	rm -f $(DMG_NAME)
	create-dmg \
		--volname "$(APP_NAME)" \
		--window-pos 200 120 \
		--window-size 480 300 \
		--icon-size 256 \
		--icon "$(APP_BUNDLE)" 120 130 \
		--app-drop-link 360 130 \
		--hide-extension "$(APP_BUNDLE)" \
		--no-internet-enable \
		$(DMG_NAME) \
		$(APP_BUNDLE) || true
	codesign --force --sign "$(SIGN_IDENTITY)" $(DMG_NAME)
	@echo "Created $(DMG_NAME)"

notarize: dmg
	xcrun notarytool submit $(DMG_NAME) --keychain-profile "pier-notarize" --wait
	xcrun stapler staple $(APP_BUNDLE)
	xcrun stapler staple $(DMG_NAME)
	@echo "Notarized and stapled $(APP_BUNDLE) and $(DMG_NAME)"

release: notarize
	@echo "Release build complete: $(DMG_NAME)"

run: bundle
	codesign --force --sign - $(APP_BUNDLE)
	open $(APP_BUNDLE)

clean:
	rm -rf .build $(APP_BUNDLE) $(DMG_NAME)
