#!/bin/sh

# -------------
# Prerequisites
# -------------
# Android SDK
# Xcode 9 beta
# Eclipse for Android

# ----------
# Edit these
# -------------
APP_NAME="MyLibGDXGame"
APP_FOLDER="mylibgdxgame"
BUNDLE_ID="com.maestun.mylibgdxgame"
MAIN_CLASS="MyLibGDXGame"
ANDROID_SDK_LOCATION=~/dev/android/sdk
# end edit

APP_FOLDER_XCODE=$APP_FOLDER-xcode


echo "*************************"
echo "*** Installing Homebrew *"
echo "*************************"
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"


echo "*****************************"
echo "*** Installing dependencies *"
echo "*****************************"
brew install gnutls libgcrypt curl git cocoapods usbmuxd automake libtool libzip pkg-config
brew cask install java


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
echo "*** Android: accept licenses *"
echo "******************************"
sh $ANDROID_SDK_LOCATION/tools/bin/sdkmanager --licenses


echo "****************************"
echo "*** libgdx: generating app *"
echo "****************************"
curl -O https://libgdx.badlogicgames.com/nightlies/dist/gdx-setup.jar
java -jar gdx-setup.jar --dir $APP_FOLDER --name $APP_NAME --package $BUNDLE_ID --mainClass $MAIN_CLASS --sdkLocation $ANDROID_SDK_LOCATION


echo "*************************************************************************"
echo "*** Please create a dummy Xcode project named --->"$APP_FOLDER_XCODE"<--- with bundleID --->"$BUNDLE_ID"<---"
echo "*** The app should be signed with a distribution certificate, then try to run it on the device."
echo "*** In Xcode, right click on "$APP_FOLDER_XCODE".app (under 'Products'), show in Finder, then copy it into" $(pwd)
echo "*************************************************************************"
read -p "Press any key when ready."


echo "****************************************************************"
echo "*** Packaging Xcode app / try to install thru ideviceinstaller *"
echo "****************************************************************"
mkdir Payload
cp -r $APP_FOLDER_XCODE.app ./Payload
zip -r $APP_FOLDER_XCODE.ipa ./Payload/
ideviceinstaller -i $APP_FOLDER_XCODE.ipa
read -p "Press any key to continue."


# echo "********************************************************************************"
# echo "*** Please import your gradle project into eclipse, configure ios app then run *"
# echo "********************************************************************************"
# read -p "Press any key when done."

# in ios/build.gradle file, modify "robovm" section:
# robovm {
# 	archs = "thumbv7:arm64"
# 	iosSignIdentity = "iPhone Developer: maestun@free.fr (F6RA4543C3)" <--- get this from 'trousseau d'accès'
# 	iosSkipSigning = false
# }

echo "*************************************"
echo "*** Building libgdx app with gradle *"
echo "*************************************"
cd $APP_FOLDER
./gradlew ios:createIPA --info
read -p "Press any key to continue."

# echo "************************"
# echo "*** signing libgdx app *"
# echo "************************"
# codesign -f -s A6B05506E31885C820E6E4587151A550E88F9801 --entitlements /Users/tisseodev/dev/eclipse/workspace/.metadata/.plugins/org.robovm.eclipse.ui/build/maestun-game-ios/maestun-game-ios/ios/arm64/Entitlements.plist /Users/tisseodev/dev/eclipse/workspace/.metadata/.plugins/org.robovm.eclipse.ui/build/maestun-game-ios/maestun-game-ios/ios/arm64/IOSLauncher.app


# echo "***********************************"
# echo "*** checking libgdx app signature *"
# echo "***********************************"
# codesign -dvvv /Users/tisseodev/dev/eclipse/workspace/.metadata/.plugins/org.robovm.eclipse.ui/build/maestun-game-ios/maestun-game-ios/ios/arm64/IOSLauncher.app


# echo "**************************************"
# echo "*** packaging libgdx app for install *"
# echo "**************************************"
# mkdir Payload
# cp -r /Users/tisseodev/dev/eclipse/workspace/.metadata/.plugins/org.robovm.eclipse.ui/build/maestun-game-ios/maestun-game-ios/ios/arm64/IOSLauncher.app ./Payload/IOSLauncher.app
# zip ./Payload/IOSLauncher.app
# mv ./Payload/IOSLauncher.zip ./IOSLauncher.ipa
# rm -r ./Payload


echo "*************************************"
echo "*** installing libgdx app on device *"
echo "*************************************"
ideviceinstaller -i ios/build/robovm/IOSLauncher.ipa
cd ..

echo "***********"
echo "*** done. *"
echo "***********"