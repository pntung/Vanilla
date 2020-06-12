sudo gem uninstall cocoapods
sudo gem install cocoapods
rm -rf "${HOME}/Library/Caches/CocoaPods"
rm -rf Pods
pod update