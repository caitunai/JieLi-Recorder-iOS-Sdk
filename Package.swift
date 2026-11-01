// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "JieLiSdkRecorder",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "JieLiSdkRecorder",
            targets: ["JieLiSdkRecorder", "JieLiSdkRecorderDependencies"]
        )
    ],
    targets: [
        .target(
            name: "JieLiSdkRecorderDependencies",
            dependencies: [
                "JieLiSdkRecorder",
                "JL_AdvParse",
                "JL_HashPair",
                "JLLogHelper",
                "JL_BLEKit",
                "JL_OTALib",
                "JLAudioUnitKit"
            ],
            linkerSettings: [
                .linkedLibrary("c++")
            ]
        ),
        .binaryTarget(
            name: "JieLiSdkRecorder",
            url: "https://github.com/caitunai/JieLi-Recorder-iOS-Sdk/releases/download/v1.0.8/JieLiSdkRecorder-1.0.8.xcframework.zip",
            checksum: "1140b1beee204e04aeed41ba0c3a0ae5a8fc22c6e69750d46ed5acf771d1ab4d"
        ),
        .binaryTarget(
            name: "JL_AdvParse",
            url: "https://github.com/caitunai/JieLi-Recorder-iOS-Sdk/releases/download/v1.0.8/JL_AdvParse-1.0.8.xcframework.zip",
            checksum: "e6e5f97e987fea6297ee3ef72fa6c15d71fa7790f2090676f317f0eeaa357ed7"
        ),
        .binaryTarget(
            name: "JL_HashPair",
            url: "https://github.com/caitunai/JieLi-Recorder-iOS-Sdk/releases/download/v1.0.8/JL_HashPair-1.0.8.xcframework.zip",
            checksum: "0daf137a43b1a9d1aae20ae2c496346e51faecba3637483a6ce68b11174122be"
        ),
        .binaryTarget(
            name: "JLLogHelper",
            url: "https://github.com/caitunai/JieLi-Recorder-iOS-Sdk/releases/download/v1.0.8/JLLogHelper-1.0.8.xcframework.zip",
            checksum: "1a1754629baa59b135ecea7aed7e0f6a565a7fc3ec04f52a94f5de1bd5c0cdca"
        ),
        .binaryTarget(
            name: "JL_BLEKit",
            url: "https://github.com/caitunai/JieLi-Recorder-iOS-Sdk/releases/download/v1.0.8/JL_BLEKit-1.0.8.xcframework.zip",
            checksum: "f01910f49f5c1fe7f1b6716390bb3e40ab7ae4bb792bd8ba029376f3dd20da6c"
        ),
        .binaryTarget(
            name: "JL_OTALib",
            url: "https://github.com/caitunai/JieLi-Recorder-iOS-Sdk/releases/download/v1.0.8/JL_OTALib-1.0.8.xcframework.zip",
            checksum: "107ade032ab11057d934f11a46f0a7b1d9f323dd5799eea035d333098ec84c91"
        ),
        .binaryTarget(
            name: "JLAudioUnitKit",
            url: "https://github.com/caitunai/JieLi-Recorder-iOS-Sdk/releases/download/v1.0.8/JLAudioUnitKit-1.0.8.xcframework.zip",
            checksum: "dce5a0279066f32626c6d05bbb89822892841e04a6e60cdd575a65f175620c37"
        ),
    ],
    swiftLanguageModes: [.v6]
)
