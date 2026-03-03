APP_NAME = Pier
BUILD_DIR = .build/release
APP_BUNDLE = $(APP_NAME).app
DMG_NAME = $(APP_NAME).dmg
VERSION = 0.1.0

# Set your Developer ID identity (find yours with: security find-identity -v -p codesigning)
# Example: SIGN_IDENTITY = Developer ID Application: Your Org Name (TEAMID)
SIGN_IDENTITY ?= -

.PHONY: build bundle run release dmg sign notarize regen-icon clean

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
	hdiutil create -volname "$(APP_NAME)" \
		-srcfolder $(APP_BUNDLE) \
		-ov -format UDZO \
		$(DMG_NAME)
	codesign --force --sign "$(SIGN_IDENTITY)" $(DMG_NAME)
	@echo "Created $(DMG_NAME)"

notarize: dmg
	xcrun notarytool submit $(DMG_NAME) --keychain-profile "pier-notarize" --wait
	xcrun stapler staple $(DMG_NAME)
	@echo "Notarized and stapled $(DMG_NAME)"

release: sign dmg
	@echo "Release build complete: $(DMG_NAME)"

run: bundle
	codesign --force --sign - $(APP_BUNDLE)
	open $(APP_BUNDLE)

# Regenerate AppIcon.icns from the script (only needed if icon design changes)
regen-icon:
	swift Scripts/generate-icon.swift

clean:
	rm -rf .build $(APP_BUNDLE) $(DMG_NAME)
