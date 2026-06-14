# JieLiSdkRecorder 0.0.2

Binary Swift Package distribution of JieLiSdkRecorder.

## Installation

Add the following package URL in Xcode:

`https://github.com/caitunai/JieLi-Recorder-iOS-Sdk.git`

Select version `0.0.2` or later and add the `JieLiSdkRecorder` product
to the application target.

The package includes the required JieLi, JLAudioUnitKit, and PNote binary
targets, and declares HuanGeSdk as a Swift Package dependency.

## Platform support

- iOS 16.0 or later
- Simulator support: No. One or more bundled dependencies do not contain a simulator slice.

The application must include `NSBluetoothAlwaysUsageDescription` in its
`Info.plist`.

If the application uses Objective-C categories from the bundled vendor
libraries, add `-ObjC` to the application target's Other Linker Flags.
