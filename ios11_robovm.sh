#!/bin/sh

# edit this
APP_NAME="MyLibGDXGame"
APP_FOLDER="mylibgdxgame"
BUNDLE_ID="com.maestun.mylibgdxgame"
MAIN_CLASS="MyLibGDXGame"
ANDROID_SDK_LOCATION=~/dev/android/sdk
# end edit


APP_NAME_XCODE=$APP_NAME-xcode
APP_FOLDER_XCODE=$APP_FOLDER-xcode


echo "*************************"
echo "*** installing Homebrew *"
echo "*************************"
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"


echo "*****************************"
echo "*** installing dependencies *"
echo "*****************************"
brew install gnutls libgcrypt curl git cocoapods usbmuxd automake libtool libzip pkg-config
brew cask install java
# export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig


echo "***********************************************"
echo "*** libplist: cloning / building / installing *"
echo "***********************************************"
git clone https://github.com/libimobiledevice/libplist.git
cd libplist
./autogen.sh
make 
make install
make clean
cd ..


echo "*************************************************"
echo "*** libusbmuxd: cloning / building / installing *"
echo "*************************************************"
git clone https://github.com/libimobiledevice/libusbmuxd.git
cd libusbmuxd
./autogen.sh
make 
make install
make clean
cd ..


echo "******************************************************************"
echo "*** libimobiledevice: cloning / patching / building / installing *"
echo "******************************************************************"
git clone https://github.com/libimobiledevice/libimobiledevice.git
cd libimobiledevice
curl -O https://gist.githubusercontent.com/nikias/b351bf633d62703e0ff4f2fee9628401/raw/dbdf7bed1bb416ab0c1b80d32056591ad1bf3e7f/validate_pair_fix.diff
git apply validate_pair_fix.diff
./autogen.sh --disable-openssl --enable-debug-code
# ./configure
make
make install
make clean
cd ..


echo "******************************************************************"
echo "*** ideviceinstaller: cloning / patching / building / installing *"
echo "******************************************************************"
git clone https://github.com/libimobiledevice/ideviceinstaller.git
cd ideviceinstaller
curl -O https://gist.githubusercontent.com/anonymous/9cc8230872b41923b603160616a3a6be/raw/b202226dc14551f86751f92045d101ebb98e30be/ideviceinstaller_long_format.diff
git apply ideviceinstaller_long_format.diff
./autogen.sh
# ./configure
make
make install
make clean
cd ..


echo "******************************"
echo "*** android: accept licenses *"
echo "******************************"
sh $ANDROID_SDK_LOCATION/tools/bin/sdkmanager --licenses


echo "****************************"
echo "*** libgdx: generating app *"
echo "****************************"
curl -O https://libgdx.badlogicgames.com/nightlies/dist/gdx-setup.jar
java -jar gdx-setup.jar --dir $APP_FOLDER --name $APP_NAME --package $BUNDLE_ID --mainClass $MAIN_CLASS --sdkLocation $ANDROID_SDK_LOCATION


echo "********************************************************************************************************************************"
echo "*** Please create fake Xcode project named --->"$APP_FOLDER_XCODE"<--- with bundleID --->"$BUNDLE_ID"<--- , then deploy on device."
echo "*** Then convert the resulting product ("APP_FOLDER_XCODE".app) file into "APP_FOLDER_XCODE".ipa thru the Payload folder."
echo "********************************************************************************************************************************"
read -p "Press any key when done."


echo "********************************************************************************"
echo "*** Please import your gradle project into eclipse, configure ios app then run *"
echo "********************************************************************************"
read -p "Press any key when done."

# in ios/build.gradle file, modify "robovm" section:
# robovm {
# 	archs = "thumbv7:arm64"
# 	iosSignIdentity = "iPhone Developer: maestun@free.fr (F6RA4543C3)" <--- get this from 'trousseau d'accès'
# 	iosSkipSigning = false
# }

echo "*************************************"
echo "*** building libgdx app with gradle *"
echo "*************************************"
./$APP_FOLDER/gradlew ios:createIPA


echo "************************"
echo "*** signing libgdx app *"
echo "************************"
codesign -f -s A6B05506E31885C820E6E4587151A550E88F9801 --entitlements /Users/tisseodev/dev/eclipse/workspace/.metadata/.plugins/org.robovm.eclipse.ui/build/maestun-game-ios/maestun-game-ios/ios/arm64/Entitlements.plist /Users/tisseodev/dev/eclipse/workspace/.metadata/.plugins/org.robovm.eclipse.ui/build/maestun-game-ios/maestun-game-ios/ios/arm64/IOSLauncher.app


echo "***********************************"
echo "*** checking libgdx app signature *"
echo "***********************************"
codesign -dvvv /Users/tisseodev/dev/eclipse/workspace/.metadata/.plugins/org.robovm.eclipse.ui/build/maestun-game-ios/maestun-game-ios/ios/arm64/IOSLauncher.app


echo "**************************************"
echo "*** packaging libgdx app for install *"
echo "**************************************"
mkdir Payload
cp -r /Users/tisseodev/dev/eclipse/workspace/.metadata/.plugins/org.robovm.eclipse.ui/build/maestun-game-ios/maestun-game-ios/ios/arm64/IOSLauncher.app ./Payload/IOSLauncher.app
zip ./Payload/IOSLauncher.app
mv ./Payload/IOSLauncher.zip ./IOSLauncher.ipa
rm -r ./Payload


echo "*************************************"
echo "*** installing libgdx app on device *"
echo "*************************************"
ideviceinstaller -i $APP_FOLDER/ios/build/robovm/IOSLauncher.ipa


echo "***********"
echo "*** done. *"
echo "***********"