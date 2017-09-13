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
    CODE_SIGN_IDENTITY="iPhone Developer: Frederik Carlier (8T9UKUBGY9)" \
    CODE_SIGN_STYLE="Manual" \
    DEVELOPMENT_TEAM="TCDK5ELAH7"

mkdir -p ./out/ipa/Payload
cp -r ./out/Build/Products/Release-iphoneos/WebDriverAgentRunner-Runner.app ./out/ipa/Payload/
cd ./out/ipa
zip -r ../WebDriverAgent-$TRAVIS_BUILD_NUMBER.zip .
cd ../../
