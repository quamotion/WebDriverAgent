#!/bin/sh

# Fail on errors
set -e

rm -rf ./out
mkdir ./out

echo "Listing provisioning profiles"
ls -l ~/Library/MobileDevice/Provisioning\ Profiles

uuid=`/usr/libexec/plistbuddy -c Print:UUID /dev/stdin <<< \
        \`security cms -D -i ~/Library/MobileDevice/Provisioning\ Profiles/adhoc.mobileprovision\``

echo "Using provisionig profile with UUID $uuid"

xcodebuild \
    -project WebDriverAgent.xcodeproj \
    -scheme WebDriverAgentRunner \
    -sdk iphoneos \
    -configuration Release \
    -derivedDataPath ./out \
    -allowProvisioningUpdates \
    CODE_SIGN_IDENTITY="$CODE_SIGN_IDENTITY" \
    CODE_SIGN_STYLE="Manual" \
    PROVISIONING_PROFILE="$uuid"

mkdir -p ./out/ipa/Payload
cp -r ./out/Build/Products/Release-iphoneos/WebDriverAgentRunner-Runner.app ./out/ipa/Payload/
cd ./out/ipa

# Dump basic information about the verison of XCTest embedded in this ipa
/usr/libexec/PlistBuddy -c Print Payload/WebDriverAgentRunner-Runner.app/Frameworks/XCTest.framework/version.plist
/usr/libexec/PlistBuddy -c Print Payload/WebDriverAgentRunner-Runner.app/Frameworks/XCTest.framework/Info.plist

zip -r ../WebDriverAgent-$TRAVIS_BUILD_NUMBER.zip .
cd ../../
