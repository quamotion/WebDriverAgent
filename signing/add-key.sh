#!/bin/sh

# Create a custom keychain
security create-keychain -p travis ios-build.keychain

# Make the custom keychain default, so xcodebuild will use it for signing
security default-keychain -s ios-build.keychain

# Unlock the keychain
security unlock-keychain -p travis ios-build.keychain

# Set the keychain timeout to 1 hour (for long builds)
security set-keychain-settings -t 3600 -l ~/Library/Keychains/ios-build.keychain

# Decrypt the certificate and provisioning profile
openssl aes-256-cbc -k "$KEY_PASSWORD" -in ./signing/adhoc.cer.enc -d -a -out ./signing/adhoc.cer
openssl aes-256-cbc -k "$KEY_PASSWORD" -in ./signing/adhoc.mobileprovision.enc -d -a -out ./signing/adhoc.mobileprovision

# Add certificates to keychain and allow codesign to access them
security import ./signing/apple.cer -k ~/Library/Keychains/ios-build.keychain -A /usr/bin/codesign
security import ./signing/adhoc.cer -k ~/Library/Keychains/ios-build.keychain -A /usr/bin/codesign
security import ./signing/adhoc.p12 -k ~/Library/Keychains/ios-build.keychain -P $KEY_PASSWORD -A /usr/bin/codesign

security set-key-partition-list -S apple-tool:,apple: -s -k travis ios-build.keychain

# Import the provisioning profile
mkdir -p ~/Library/MobileDevice/Provisioning\ Profiles
cp ./signing/adhoc.mobileprovision ~/Library/MobileDevice/Provisioning\ Profiles
