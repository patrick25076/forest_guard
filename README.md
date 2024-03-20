# forest_guard

A new Flutter project.

Important initial Setup!
Android & iOS 
Examples and support now support dynamic library downloads! iOS samples can be run with the commands
flutter build ios & flutter install ios from their respective iOS folders.
Android can be run with the commands
flutter build android & flutter install android
while devices are plugged in.
Note: This requires a device with a minimum API level of 26.
Note: TFLite may not work in the iOS simulator. It's recommended that you test with a physical device.

When creating a release archive (IPA), the symbols are stripped by Xcode, so the command flutter build ipa may throw a Failed to lookup symbol ... symbol not found error. To work around this:

In Xcode, go to Target Runner > Build Settings > Strip Style
Change from All Symbols to Non-Global Symbols



This Version works because of tflite only with minSDK 26