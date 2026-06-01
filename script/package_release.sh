#!/usr/bin/env bash
set -euo pipefail

APP_EXECUTABLE="QuotaCalendar"
APP_DISPLAY_NAME="Codex Quota Calendar"
BUNDLE_ID="com.maohuhu.QuotaCalendar"
MIN_SYSTEM_VERSION="14.0"

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERSION_FILE="$ROOT_DIR/VERSION"
RELEASE_DIR="$ROOT_DIR/release"
WORK_DIR="$RELEASE_DIR/build"
DMG_ROOT="$WORK_DIR/dmg-root"
DMG_BACKGROUND="$ROOT_DIR/Sources/QuotaCalendar/Resources/DmgBackground.png"
APP_BUNDLE="$WORK_DIR/$APP_DISPLAY_NAME.app"
APP_CONTENTS="$APP_BUNDLE/Contents"
APP_MACOS="$APP_CONTENTS/MacOS"
APP_RESOURCES="$APP_CONTENTS/Resources"
APP_BINARY="$APP_MACOS/$APP_EXECUTABLE"
INFO_PLIST="$APP_CONTENTS/Info.plist"
APP_ICON="$ROOT_DIR/Sources/QuotaCalendar/Resources/AppIcon.icns"

NOTARIZE=1
while [[ $# -gt 0 ]]; do
  case "$1" in
    --notarize)
      NOTARIZE=1
      shift
      ;;
    --no-notarize)
      NOTARIZE=0
      shift
      ;;
    *)
      echo "usage: $0 [--notarize|--no-notarize]" >&2
      exit 2
      ;;
  esac
done

ENV_FILE="${QUOTA_CALENDAR_RELEASE_ENV_FILE:-$ROOT_DIR/.env.release.local}"
if [[ -f "$ENV_FILE" ]]; then
  set -a
  # shellcheck disable=SC1090
  source "$ENV_FILE"
  set +a
fi

VERSION="${QUOTA_CALENDAR_VERSION:-$(tr -d '[:space:]' < "$VERSION_FILE")}"
BUILD_NUMBER="${QUOTA_CALENDAR_BUILD:-$(date -u +%Y%m%d%H%M)}"
DMG_BASENAME="${APP_EXECUTABLE}-${VERSION}-${BUILD_NUMBER}"
DMG_PATH="$RELEASE_DIR/$DMG_BASENAME.dmg"
DMG_TMP_DIR="/private/tmp/quota-calendar-release-$DMG_BASENAME"
DMG_RW_PATH="$DMG_TMP_DIR/$DMG_BASENAME.rw.dmg"

auto_signing_identity() {
  security find-identity -p codesigning -v 2>/dev/null \
    | sed -n 's/.*"\(Developer ID Application:.*\)"/\1/p' \
    | head -n 1
}

SIGNING_IDENTITY="${QUOTA_CALENDAR_SIGNING_IDENTITY:-$(auto_signing_identity)}"
if [[ -z "$SIGNING_IDENTITY" ]]; then
  cat >&2 <<'MSG'
Missing Developer ID signing identity.
Set QUOTA_CALENDAR_SIGNING_IDENTITY or install a Developer ID Application certificate.
MSG
  exit 1
fi

if [[ -f "$ROOT_DIR/Sources/QuotaCalendar/Resources/AppIconSource.png" ]]; then
  echo "Regenerating app icon from source image..."
  (cd "$ROOT_DIR" && swift script/generate_app_icon.swift)
fi

notary_args=()
if [[ -n "${QUOTA_CALENDAR_NOTARY_PROFILE:-}" ]]; then
  notary_args=(--keychain-profile "$QUOTA_CALENDAR_NOTARY_PROFILE")
elif [[ -n "${ASC_KEY_ID:-}" && -n "${ASC_ISSUER_ID:-}" && -n "${ASC_KEY_PATH:-}" ]]; then
  notary_args=(--key "$ASC_KEY_PATH" --key-id "$ASC_KEY_ID" --issuer "$ASC_ISSUER_ID")
elif [[ -n "${APPLE_ID:-}" && -n "${APPLE_TEAM_ID:-}" && -n "${APPLE_APP_SPECIFIC_PASSWORD:-}" ]]; then
  notary_args=(--apple-id "$APPLE_ID" --team-id "$APPLE_TEAM_ID" --password "$APPLE_APP_SPECIFIC_PASSWORD")
elif [[ "$NOTARIZE" == "1" ]]; then
  cat >&2 <<'MSG'
Missing notarization credentials.
Use one of:
  QUOTA_CALENDAR_NOTARY_PROFILE
  ASC_KEY_ID + ASC_ISSUER_ID + ASC_KEY_PATH
  APPLE_ID + APPLE_TEAM_ID + APPLE_APP_SPECIFIC_PASSWORD

Secrets can live in ignored .env.release.local or in your shell environment.
MSG
  exit 1
fi

echo "Building release binary..."
swift build -c release
BUILD_BINARY="$(swift build -c release --show-bin-path)/$APP_EXECUTABLE"

rm -rf "$WORK_DIR"
mkdir -p "$APP_MACOS" "$APP_RESOURCES" "$RELEASE_DIR"
cp "$BUILD_BINARY" "$APP_BINARY"
chmod +x "$APP_BINARY"
if [[ -f "$APP_ICON" ]]; then
  cp "$APP_ICON" "$APP_RESOURCES/AppIcon.icns"
fi

cat >"$INFO_PLIST" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleDevelopmentRegion</key>
  <string>en</string>
  <key>CFBundleDisplayName</key>
  <string>$APP_DISPLAY_NAME</string>
  <key>CFBundleExecutable</key>
  <string>$APP_EXECUTABLE</string>
  <key>CFBundleIconFile</key>
  <string>AppIcon.icns</string>
  <key>CFBundleIdentifier</key>
  <string>$BUNDLE_ID</string>
  <key>CFBundleName</key>
  <string>$APP_DISPLAY_NAME</string>
  <key>CFBundlePackageType</key>
  <string>APPL</string>
  <key>CFBundleShortVersionString</key>
  <string>$VERSION</string>
  <key>CFBundleVersion</key>
  <string>$BUILD_NUMBER</string>
  <key>LSMinimumSystemVersion</key>
  <string>$MIN_SYSTEM_VERSION</string>
  <key>LSUIElement</key>
  <true/>
  <key>NSPrincipalClass</key>
  <string>NSApplication</string>
</dict>
</plist>
PLIST

echo "Signing app with Developer ID..."
codesign --force --timestamp --options runtime --sign "$SIGNING_IDENTITY" "$APP_BUNDLE"
codesign --verify --deep --strict --verbose=2 "$APP_BUNDLE"

rm -rf "$DMG_TMP_DIR"
mkdir -p "$DMG_TMP_DIR"
rm -f "$DMG_PATH"
echo "Creating DMG..."
hdiutil create \
  -size 32m \
  -fs HFS+ \
  -volname "$APP_DISPLAY_NAME" \
  -type UDIF \
  -ov \
  "$DMG_RW_PATH" >/dev/null

echo "Populating and styling DMG window..."
MOUNT_DIR="$(mktemp -d /tmp/quota-calendar-dmg.XXXXXX)"
cleanup_mount() {
  if mount | grep -q "on $MOUNT_DIR "; then
    hdiutil detach "$MOUNT_DIR" -quiet || true
  fi
  rm -rf "$MOUNT_DIR"
}
trap cleanup_mount EXIT
hdiutil attach "$DMG_RW_PATH" -mountpoint "$MOUNT_DIR" -nobrowse -quiet
ditto "$APP_BUNDLE" "$MOUNT_DIR/$APP_DISPLAY_NAME.app"
ln -s /Applications "$MOUNT_DIR/Applications"
mkdir -p "$MOUNT_DIR/.background"
if [[ -f "$DMG_BACKGROUND" ]]; then
  cp "$DMG_BACKGROUND" "$MOUNT_DIR/.background/background.png"
fi
sleep 1
osascript <<APPLESCRIPT
set dmgFolder to (POSIX file "$MOUNT_DIR" as alias)
set bgFile to (POSIX file "$MOUNT_DIR/.background/background.png" as alias)
tell application "Finder"
  open dmgFolder
  delay 1
  set win to front Finder window
  set current view of win to icon view
  set toolbar visible of win to false
  set statusbar visible of win to false
  set bounds of win to {160, 120, 880, 540}
  set theViewOptions to the icon view options of win
  set arrangement of theViewOptions to not arranged
  set icon size of theViewOptions to 96
  set background picture of theViewOptions to bgFile
  set position of item "$APP_DISPLAY_NAME.app" of dmgFolder to {180, 208}
  set position of item "Applications" of dmgFolder to {540, 208}
  update dmgFolder without registering applications
  delay 1
  close win
end tell
APPLESCRIPT
SetFile -a V "$MOUNT_DIR/.background" >/dev/null 2>&1 || true
sync
hdiutil detach "$MOUNT_DIR" -quiet
rm -rf "$MOUNT_DIR"
trap - EXIT

hdiutil convert "$DMG_RW_PATH" -format UDZO -imagekey zlib-level=9 -o "$DMG_PATH" >/dev/null
rm -rf "$DMG_TMP_DIR"

echo "Signing DMG..."
codesign --force --timestamp --sign "$SIGNING_IDENTITY" "$DMG_PATH"
codesign --verify --verbose=2 "$DMG_PATH"

if [[ "$NOTARIZE" == "1" ]]; then
  echo "Submitting DMG for notarization..."
  xcrun notarytool submit "$DMG_PATH" "${notary_args[@]}" --wait

  echo "Stapling notarization ticket..."
  xcrun stapler staple "$DMG_PATH"
  xcrun stapler validate "$DMG_PATH"
fi

echo "Release artifact:"
echo "$DMG_PATH"
