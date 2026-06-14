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
            url: "https://github.com/caitunai/JieLi-Recorder-iOS-Sdk/releases/download/v0.0.4/JieLiSdkRecorder-0.0.4.xcframework.zip",
            checksum: "53c61e48b9a457c339e4996bf4e94e149713ce4de9ee8567c9bb8271247a2a2d"
        ),
        .binaryTarget(
            name: "JL_AdvParse",
            url: "https://github.com/caitunai/JieLi-Recorder-iOS-Sdk/releases/download/v0.0.4/JL_AdvParse-0.0.4.xcframework.zip",
            checksum: "f2431c0edbf9903b39f7b12e073b6341c5f8c5d935da38bcb4acd9256b65df42"
        ),
        .binaryTarget(
            name: "JL_HashPair",
            url: "https://github.com/caitunai/JieLi-Recorder-iOS-Sdk/releases/download/v0.0.4/JL_HashPair-0.0.4.xcframework.zip",
            checksum: "5023d85a94ba94ddf87c6ca6aaa2015389c44c5eb1dc42a6e45c8f9f8de3970f"
        ),
        .binaryTarget(
            name: "JLLogHelper",
            url: "https://github.com/caitunai/JieLi-Recorder-iOS-Sdk/releases/download/v0.0.4/JLLogHelper-0.0.4.xcframework.zip",
            checksum: "0c879a095f198a16cdc9b1d81631733b3668d90bc9652b1e13173810011effa5"
        ),
        .binaryTarget(
            name: "JL_BLEKit",
            url: "https://github.com/caitunai/JieLi-Recorder-iOS-Sdk/releases/download/v0.0.4/JL_BLEKit-0.0.4.xcframework.zip",
            checksum: "ab3887d7a8e7c4e1dc6b2a26d9c1c5938118fe7c992a2c3715c4cdc09439f9ee"
        ),
        .binaryTarget(
            name: "JL_OTALib",
            url: "https://github.com/caitunai/JieLi-Recorder-iOS-Sdk/releases/download/v0.0.4/JL_OTALib-0.0.4.xcframework.zip",
            checksum: "735864c2420df4b72e9dc98e3a27c62c9a92303bb59930c56f89ee3b2aef8608"
        ),
        .binaryTarget(
            name: "JLAudioUnitKit",
            url: "https://github.com/caitunai/JieLi-Recorder-iOS-Sdk/releases/download/v0.0.4/JLAudioUnitKit-0.0.4.xcframework.zip",
            checksum: "4bf311d8931717581540ad122cd756c090d976b2361c7893d3ad4f829673d340"
        ),
    ],
    swiftLanguageModes: [.v6]
)
