#!/bin/sh

# Fail on errors
set -e

rm -rf ./out
mkdir ./out

xcodebuild \
    -project WebDriverAgent.xcodeproj \
    -scheme WebDriverAgentRunner \
    -sdk iphoneos \
    -configuration Release \
    -derivedDataPath ./out \
    -allowProvisioningUpdates \
    CODE_SIGN_IDENTITY="$CODE_SIGN_IDENTITY" \
    CODE_SIGN_STYLE="Manual" \
    DEVELOPMENT_TEAM="$DEVELOPMENT_TEAM"

mkdir -p ./out/ipa/Payload
cp -r ./out/Build/Products/Release-iphoneos/WebDriverAgentRunner-Runner.app ./out/ipa/Payload/
cd ./out/ipa

# Dump basic information about the verison of XCTest embedded in this ipa
/usr/libexec/PlistBuddy -c Print Payload/WebDriverAgentRunner-Runner.app/Frameworks/XCTest.framework/version.plist
/usr/libexec/PlistBuddy -c Print Payload/WebDriverAgentRunner-Runner.app/Frameworks/XCTest.framework/Info.plist

zip -r ../WebDriverAgent-$TRAVIS_BUILD_NUMBER.zip .
cd ../../
