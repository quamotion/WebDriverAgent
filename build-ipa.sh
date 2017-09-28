rm -rf ./out
mkdir ./out
xcodebuild -project WebDriverAgent.xcodeproj -scheme WebDriverAgentRunner -sdk iphoneos -configuration Release -derivedDataPath ./out
mkdir -p ./out/ipa/Payload
cp -r ./out/Build/Products/Release-iphoneos/WebDriverAgentRunner-Runner.app ./out/ipa/Payload/
cd ./out/ipa
zip -r ../WebDriverAgent-$TRAVIS_BUILD_NUMBER.zip .
cd ../../
