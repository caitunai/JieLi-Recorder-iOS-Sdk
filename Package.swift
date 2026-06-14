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
    dependencies: [
        .package(
            url: "https://github.com/caitunai/HuanGe-iOS-sdk.git",
            from: "1.0.0"
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
                "JLAudioUnitKit",
                "PNote",
                .product(name: "HuanGeSdk", package: "HuanGe-iOS-sdk")
            ],
            linkerSettings: [
                .linkedLibrary("c++")
            ]
        ),
        .binaryTarget(
            name: "JieLiSdkRecorder",
            url: "https://github.com/caitunai/JieLi-Recorder-iOS-Sdk/releases/download/v0.0.1/JieLiSdkRecorder-0.0.1.xcframework.zip",
            checksum: "5255b4bdb08e01c3cd65178e32963188091dd832dd6e0046c28dbea4cf7e8b75"
        ),
        .binaryTarget(
            name: "JL_AdvParse",
            url: "https://github.com/caitunai/JieLi-Recorder-iOS-Sdk/releases/download/v0.0.1/JL_AdvParse-0.0.1.xcframework.zip",
            checksum: "7725dd3abad1c3f2e31bc22f03a448f3f304441c0f587546cc3c9608ee91486d"
        ),
        .binaryTarget(
            name: "JL_HashPair",
            url: "https://github.com/caitunai/JieLi-Recorder-iOS-Sdk/releases/download/v0.0.1/JL_HashPair-0.0.1.xcframework.zip",
            checksum: "5023d85a94ba94ddf87c6ca6aaa2015389c44c5eb1dc42a6e45c8f9f8de3970f"
        ),
        .binaryTarget(
            name: "JLLogHelper",
            url: "https://github.com/caitunai/JieLi-Recorder-iOS-Sdk/releases/download/v0.0.1/JLLogHelper-0.0.1.xcframework.zip",
            checksum: "0c879a095f198a16cdc9b1d81631733b3668d90bc9652b1e13173810011effa5"
        ),
        .binaryTarget(
            name: "JL_BLEKit",
            url: "https://github.com/caitunai/JieLi-Recorder-iOS-Sdk/releases/download/v0.0.1/JL_BLEKit-0.0.1.xcframework.zip",
            checksum: "3ab828b35e27ac767dcb931d5b39623ffe8154d6b83f201a07d2e5f3fa5af3c1"
        ),
        .binaryTarget(
            name: "JL_OTALib",
            url: "https://github.com/caitunai/JieLi-Recorder-iOS-Sdk/releases/download/v0.0.1/JL_OTALib-0.0.1.xcframework.zip",
            checksum: "735864c2420df4b72e9dc98e3a27c62c9a92303bb59930c56f89ee3b2aef8608"
        ),
        .binaryTarget(
            name: "JLAudioUnitKit",
            url: "https://github.com/caitunai/JieLi-Recorder-iOS-Sdk/releases/download/v0.0.1/JLAudioUnitKit-0.0.1.xcframework.zip",
            checksum: "4bf311d8931717581540ad122cd756c090d976b2361c7893d3ad4f829673d340"
        ),
        .binaryTarget(
            name: "PNote",
            url: "https://github.com/caitunai/JieLi-Recorder-iOS-Sdk/releases/download/v0.0.1/PNote-0.0.1.xcframework.zip",
            checksum: "3db7616e31a1b0c57127194a8abfe6861659119562c8a336b4ebf78b66bc1dbb"
        ),
    ],
    swiftLanguageModes: [.v6]
)
