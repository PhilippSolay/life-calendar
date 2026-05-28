#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

APP_NAME="Life Calendar"
APP_BUNDLE="build/${APP_NAME}.app"

# Read the marketing version out of Info.plist so the zip is named clearly.
VERSION=$(/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" "Resources/Info.plist" 2>/dev/null || echo "0.0.0")
ZIP_PATH="build/Life Calendar ${VERSION}.zip"

# Always build fresh so the artifact matches HEAD.
./build.sh

echo "Packaging…"
rm -f "$ZIP_PATH"

# ditto preserves the bundle structure, the ad-hoc signature, and extended
# attributes — a plain `zip` corrupts code-signed .app bundles.
ditto -c -k --sequesterRsrc --keepParent "$APP_BUNDLE" "$ZIP_PATH"

# Drop a copy in ~/Downloads for easy sharing.
DOWNLOADS="$HOME/Downloads/Life Calendar ${VERSION}.zip"
cp "$ZIP_PATH" "$DOWNLOADS"

SIZE=$(du -h "$ZIP_PATH" | cut -f1)
echo ""
echo "Packaged: $ZIP_PATH (${SIZE})"
echo "Copied to: $DOWNLOADS"
echo ""
echo "Note: the app is ad-hoc signed, not notarized. A recipient must"
echo "right-click → Open the first time to get past Gatekeeper."
