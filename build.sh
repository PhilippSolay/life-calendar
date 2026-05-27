#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

CONFIG="${CONFIG:-release}"
APP_NAME="Life Calendar"
BUNDLE_ID="com.philippsolay.LifeCalendar"
EXEC_NAME="LifeCalendar"

# Use the full Xcode toolchain (CommandLineTools alone can't link SwiftPM manifests
# on some macOS versions). Override with DEVELOPER_DIR=... if needed.
if [ -z "${DEVELOPER_DIR:-}" ] && [ -d "/Applications/Xcode.app/Contents/Developer" ]; then
    export DEVELOPER_DIR="/Applications/Xcode.app/Contents/Developer"
fi

echo "Building (${CONFIG})…"
swift build -c "$CONFIG"

BIN_PATH=$(swift build -c "$CONFIG" --show-bin-path)
APP_BUNDLE="build/${APP_NAME}.app"

rm -rf "$APP_BUNDLE"
mkdir -p "$APP_BUNDLE/Contents/MacOS"
mkdir -p "$APP_BUNDLE/Contents/Resources"
mkdir -p "$APP_BUNDLE/Contents/Library/LaunchAgents"

cp "$BIN_PATH/$EXEC_NAME" "$APP_BUNDLE/Contents/MacOS/$EXEC_NAME"
cp "Resources/Info.plist" "$APP_BUNDLE/Contents/Info.plist"
cp "Resources/com.philippsolay.LifeCalendar.plist" "$APP_BUNDLE/Contents/Library/LaunchAgents/com.philippsolay.LifeCalendar.plist"

# Ad-hoc sign so macOS will let us run the unbundled app locally
codesign --force --deep --sign - "$APP_BUNDLE" >/dev/null

echo "Built: $APP_BUNDLE"
echo "Run with: open \"$APP_BUNDLE\""
