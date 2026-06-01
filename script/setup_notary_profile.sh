#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROFILE_NAME="${1:-quota-calendar-notary}"
ENV_FILE="$ROOT_DIR/.env.release.local"

auto_signing_identity() {
  security find-identity -p codesigning -v 2>/dev/null \
    | sed -n 's/.*"\(Developer ID Application:.*\)"/\1/p' \
    | head -n 1
}

SIGNING_IDENTITY="${QUOTA_CALENDAR_SIGNING_IDENTITY:-$(auto_signing_identity)}"
if [[ -z "$SIGNING_IDENTITY" ]]; then
  cat >&2 <<'MSG'
Missing Developer ID Application certificate.
Install one first, then run this script again.
MSG
  exit 1
fi

echo "This stores notarization credentials in macOS Keychain profile: $PROFILE_NAME"
echo "Do not paste these credentials into chat or commit them to git."
echo

read -r -p "Apple ID email: " APPLE_ID_INPUT
read -r -p "Apple Team ID: " TEAM_ID_INPUT
if [[ -z "$TEAM_ID_INPUT" ]]; then
  echo "Apple Team ID is required." >&2
  exit 1
fi
echo

xcrun notarytool store-credentials "$PROFILE_NAME" \
  --apple-id "$APPLE_ID_INPUT" \
  --team-id "$TEAM_ID_INPUT"

umask 077
cat >"$ENV_FILE" <<ENV
QUOTA_CALENDAR_SIGNING_IDENTITY="$SIGNING_IDENTITY"
QUOTA_CALENDAR_NOTARY_PROFILE="$PROFILE_NAME"
ENV

echo
echo "Wrote ignored release env file: $ENV_FILE"
echo "Next command:"
echo "  ./script/package_release.sh --notarize"
