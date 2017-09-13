#!/bin/sh

# Create a custom keychain
security create-keychain -p travis ios-build.keychain

# Make the custom keychain default, so xcodebuild will use it for signing
security default-keychain -s ios-build.keychain

# Unlock the keychain
security unlock-keychain -p travis ios-build.keychain

# Set the keychain timeout to 1 hour (for long builds)
security set-keychain-settings -t 3600 -l ~/Library/Keychains/ios-build.keychain

# Add certificates to keychain and allow codesign to access them
security import ./signing/apple.cer -k ~/Library/Keychains/ios-build.keychain -T /usr/bin/codesign
security import ./signing/adhoc.cer -k ~/Library/Keychains/ios-build.keychain -T /usr/bin/codesign
security import ./signing/adhoc.p12 -k ~/Library/Keychains/ios-build.keychian -P $KEY_PASSWORD -T /usr/bin/codesign

# Import the provisioning profile
mkdir -p ~/Library/MobileDevice/Provisioning\ Profiles
cp ./signing/adhoc.mobileprovision ~/Library/MobileDevice/Provisioning\ Profiles
