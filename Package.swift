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
            url: "https://github.com/caitunai/JieLi-Recorder-iOS-Sdk/releases/download/v0.0.2/JieLiSdkRecorder-0.0.2.xcframework.zip",
            checksum: "e65f7157f22a1e32c81570700da53092002644c7277aa8483c438c97d418a25d"
        ),
        .binaryTarget(
            name: "JL_AdvParse",
            url: "https://github.com/caitunai/JieLi-Recorder-iOS-Sdk/releases/download/v0.0.2/JL_AdvParse-0.0.2.xcframework.zip",
            checksum: "7e6461c62786db250e8207147a989280b46699891aa5103afbb305c7e050b9c3"
        ),
        .binaryTarget(
            name: "JL_HashPair",
            url: "https://github.com/caitunai/JieLi-Recorder-iOS-Sdk/releases/download/v0.0.2/JL_HashPair-0.0.2.xcframework.zip",
            checksum: "5023d85a94ba94ddf87c6ca6aaa2015389c44c5eb1dc42a6e45c8f9f8de3970f"
        ),
        .binaryTarget(
            name: "JLLogHelper",
            url: "https://github.com/caitunai/JieLi-Recorder-iOS-Sdk/releases/download/v0.0.2/JLLogHelper-0.0.2.xcframework.zip",
            checksum: "0c879a095f198a16cdc9b1d81631733b3668d90bc9652b1e13173810011effa5"
        ),
        .binaryTarget(
            name: "JL_BLEKit",
            url: "https://github.com/caitunai/JieLi-Recorder-iOS-Sdk/releases/download/v0.0.2/JL_BLEKit-0.0.2.xcframework.zip",
            checksum: "3ab828b35e27ac767dcb931d5b39623ffe8154d6b83f201a07d2e5f3fa5af3c1"
        ),
        .binaryTarget(
            name: "JL_OTALib",
            url: "https://github.com/caitunai/JieLi-Recorder-iOS-Sdk/releases/download/v0.0.2/JL_OTALib-0.0.2.xcframework.zip",
            checksum: "735864c2420df4b72e9dc98e3a27c62c9a92303bb59930c56f89ee3b2aef8608"
        ),
        .binaryTarget(
            name: "JLAudioUnitKit",
            url: "https://github.com/caitunai/JieLi-Recorder-iOS-Sdk/releases/download/v0.0.2/JLAudioUnitKit-0.0.2.xcframework.zip",
            checksum: "4bf311d8931717581540ad122cd756c090d976b2361c7893d3ad4f829673d340"
        ),
        .binaryTarget(
            name: "PNote",
            url: "https://github.com/caitunai/JieLi-Recorder-iOS-Sdk/releases/download/v0.0.2/PNote-0.0.2.xcframework.zip",
            checksum: "a5e3807cbf224b9decf61479b5cc187958ad91bfcec48e15fc461406bc4b62f1"
        ),
    ],
    swiftLanguageModes: [.v6]
)
