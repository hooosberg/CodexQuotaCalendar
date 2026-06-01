# Release Signing and Notarization

This project ships outside the Mac App Store using Developer ID signing and Apple notarization.

Secrets must stay in environment variables or in `.env.release.local`, which is ignored by git.

Required for signing:

```bash
export QUOTA_CALENDAR_SIGNING_IDENTITY="Developer ID Application: Your Name (TEAMID)"
```

Recommended one-time setup:

```bash
./script/setup_notary_profile.sh
```

This stores notarization credentials in macOS Keychain and writes only the
profile name plus signing identity to ignored `.env.release.local`. The
app-specific password is entered into `notarytool`'s secure prompt and is not
stored in this repository.

Notarization options:

```bash
# Preferred if you already stored credentials in Keychain:
export QUOTA_CALENDAR_NOTARY_PROFILE="quota-calendar-notary"
```

Or use Apple ID credentials:

```bash
export APPLE_ID="you@example.com"
export APPLE_TEAM_ID="TEAMID"
export APPLE_APP_SPECIFIC_PASSWORD="xxxx-xxxx-xxxx-xxxx"
```

Or use an App Store Connect API key:

```bash
export ASC_KEY_ID="XXXXXXXXXX"
export ASC_ISSUER_ID="xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
export ASC_KEY_PATH="$HOME/private/AuthKey_XXXXXXXXXX.p8"
```

Build, sign, create a DMG, notarize, and staple:

```bash
./script/package_release.sh --notarize
```

Build and sign without notarization for local validation:

```bash
./script/package_release.sh --no-notarize
```
