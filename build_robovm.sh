# commit of 2.3.1 release
# ROBOVM_COMMIT="8284bb8802113be0067cd7f425a4b2ea18c531b7"
ROBOVM_VERSION="robovm-2.3.1"

brew install maven cmake 
git clone https://github.com/maestun/robovm.git
cd robovm
git checkout tags/$ROBOVM_VERSION .
chmod +x build.sh
./build.sh

