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
            url: "https://github.com/caitunai/JieLi-Recorder-iOS-Sdk/releases/download/v1.0.0/JieLiSdkRecorder-1.0.0.xcframework.zip",
            checksum: "e067d037a0e7f0f4f95ec35df491057855d216459b90523a5a774579ccaf3f79"
        ),
        .binaryTarget(
            name: "JL_AdvParse",
            url: "https://github.com/caitunai/JieLi-Recorder-iOS-Sdk/releases/download/v1.0.0/JL_AdvParse-1.0.0.xcframework.zip",
            checksum: "f92daa4d392fd5db292d17a335febece57f089132c0cb3c8f70be9be8bc6c89f"
        ),
        .binaryTarget(
            name: "JL_HashPair",
            url: "https://github.com/caitunai/JieLi-Recorder-iOS-Sdk/releases/download/v1.0.0/JL_HashPair-1.0.0.xcframework.zip",
            checksum: "5023d85a94ba94ddf87c6ca6aaa2015389c44c5eb1dc42a6e45c8f9f8de3970f"
        ),
        .binaryTarget(
            name: "JLLogHelper",
            url: "https://github.com/caitunai/JieLi-Recorder-iOS-Sdk/releases/download/v1.0.0/JLLogHelper-1.0.0.xcframework.zip",
            checksum: "0c879a095f198a16cdc9b1d81631733b3668d90bc9652b1e13173810011effa5"
        ),
        .binaryTarget(
            name: "JL_BLEKit",
            url: "https://github.com/caitunai/JieLi-Recorder-iOS-Sdk/releases/download/v1.0.0/JL_BLEKit-1.0.0.xcframework.zip",
            checksum: "ab3887d7a8e7c4e1dc6b2a26d9c1c5938118fe7c992a2c3715c4cdc09439f9ee"
        ),
        .binaryTarget(
            name: "JL_OTALib",
            url: "https://github.com/caitunai/JieLi-Recorder-iOS-Sdk/releases/download/v1.0.0/JL_OTALib-1.0.0.xcframework.zip",
            checksum: "735864c2420df4b72e9dc98e3a27c62c9a92303bb59930c56f89ee3b2aef8608"
        ),
        .binaryTarget(
            name: "JLAudioUnitKit",
            url: "https://github.com/caitunai/JieLi-Recorder-iOS-Sdk/releases/download/v1.0.0/JLAudioUnitKit-1.0.0.xcframework.zip",
            checksum: "4bf311d8931717581540ad122cd756c090d976b2361c7893d3ad4f829673d340"
        ),
    ],
    swiftLanguageModes: [.v6]
)
