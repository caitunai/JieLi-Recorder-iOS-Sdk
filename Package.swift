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
            url: "https://github.com/caitunai/JieLi-Recorder-iOS-Sdk/releases/download/v1.0.5/JieLiSdkRecorder-1.0.5.xcframework.zip",
            checksum: "bfc44d5774bb503c3a1ab391b0e9916ae51fd96dd7f8bf12d34e32b28efacc8a"
        ),
        .binaryTarget(
            name: "JL_AdvParse",
            url: "https://github.com/caitunai/JieLi-Recorder-iOS-Sdk/releases/download/v1.0.5/JL_AdvParse-1.0.5.xcframework.zip",
            checksum: "bf62632faabacab73af5ecf44a184222d269122773ae29e810edcca2b4f5e22f"
        ),
        .binaryTarget(
            name: "JL_HashPair",
            url: "https://github.com/caitunai/JieLi-Recorder-iOS-Sdk/releases/download/v1.0.5/JL_HashPair-1.0.5.xcframework.zip",
            checksum: "6ab04d74dc48ad916eca35185350152c13f2d755829ce2d7b226216f90a5fde1"
        ),
        .binaryTarget(
            name: "JLLogHelper",
            url: "https://github.com/caitunai/JieLi-Recorder-iOS-Sdk/releases/download/v1.0.5/JLLogHelper-1.0.5.xcframework.zip",
            checksum: "75789f43416d0a3dc115b804154265dca294c7a69ad5ef080e7dc5f5c2f80f31"
        ),
        .binaryTarget(
            name: "JL_BLEKit",
            url: "https://github.com/caitunai/JieLi-Recorder-iOS-Sdk/releases/download/v1.0.5/JL_BLEKit-1.0.5.xcframework.zip",
            checksum: "7b9ebc007f326ababa12e048bbdf64ef3b9680c8972d3227267623d711bf22a3"
        ),
        .binaryTarget(
            name: "JL_OTALib",
            url: "https://github.com/caitunai/JieLi-Recorder-iOS-Sdk/releases/download/v1.0.5/JL_OTALib-1.0.5.xcframework.zip",
            checksum: "f286ee8bf6999fdbad26e718db1cafc55550a2f77784057c3814fb17834b2743"
        ),
        .binaryTarget(
            name: "JLAudioUnitKit",
            url: "https://github.com/caitunai/JieLi-Recorder-iOS-Sdk/releases/download/v1.0.5/JLAudioUnitKit-1.0.5.xcframework.zip",
            checksum: "4b7609589d3230af3f147a90bfe1c36fb889c58b39221905c43288cdd6456fb3"
        ),
    ],
    swiftLanguageModes: [.v6]
)
