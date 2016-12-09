#!/bin/sh

# Fail on errors
set -e

rm -rf ./out
mkdir ./out

bundle_identifier=$(xmllint --xpath 'substring(//key[text()="Entitlements"]/following::dict[1]/key[text()="application-identifier"]/following::string[1]/text(), 12)' ./signing/adhoc.mobileprovision.xml)
uuid=$(xmllint --xpath '//key[text()="UUID"]/following::string[1]/text()' ./signing/adhoc.mobileprovision.xml)
echo "Using application identifier ${bundle_identifier}, provisioning profile ${uuid}"

xcodebuild \
    -project WebDriverAgent.xcodeproj \
    -scheme WebDriverAgentRunner \
    -sdk iphoneos \
    -configuration Release \
    -derivedDataPath ./out \
    -allowProvisioningUpdates \
    PRODUCT_BUNDLE_IDENTIFIER=${bundle_identifier}

mkdir -p ./out/ipa/Payload
cp -r ./out/Build/Products/Release-iphoneos/WebDriverAgentRunner-Runner.app ./out/ipa/Payload/
cd ./out/ipa

# Dump basic information about the verison of XCTest embedded in this ipa
/usr/libexec/PlistBuddy -c Print Payload/WebDriverAgentRunner-Runner.app/Frameworks/XCTest.framework/version.plist
/usr/libexec/PlistBuddy -c Print Payload/WebDriverAgentRunner-Runner.app/Frameworks/XCTest.framework/Info.plist

zip -r ../WebDriverAgent-$TRAVIS_BUILD_NUMBER.zip .
cd ../../
