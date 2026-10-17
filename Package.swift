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
            url: "https://github.com/caitunai/JieLi-Recorder-iOS-Sdk/releases/download/v1.0.7/JieLiSdkRecorder-1.0.7.xcframework.zip",
            checksum: "ca55c291aa9acfeb0c8000d767aa9efdf9e676b82bd72cce81f1a8f3275588f7"
        ),
        .binaryTarget(
            name: "JL_AdvParse",
            url: "https://github.com/caitunai/JieLi-Recorder-iOS-Sdk/releases/download/v1.0.7/JL_AdvParse-1.0.7.xcframework.zip",
            checksum: "9c1d6c00975fec07034aa5bdb292981291211da2a5da53f1a5e2525927229e88"
        ),
        .binaryTarget(
            name: "JL_HashPair",
            url: "https://github.com/caitunai/JieLi-Recorder-iOS-Sdk/releases/download/v1.0.7/JL_HashPair-1.0.7.xcframework.zip",
            checksum: "ef494662b5392538f743482bf417d835ad6a2f9688c14d9d85610a93aba7d3dd"
        ),
        .binaryTarget(
            name: "JLLogHelper",
            url: "https://github.com/caitunai/JieLi-Recorder-iOS-Sdk/releases/download/v1.0.7/JLLogHelper-1.0.7.xcframework.zip",
            checksum: "831027479e723ecf1533b169714d2d31ffbf550c4f351dec7a5996927b6a8d79"
        ),
        .binaryTarget(
            name: "JL_BLEKit",
            url: "https://github.com/caitunai/JieLi-Recorder-iOS-Sdk/releases/download/v1.0.7/JL_BLEKit-1.0.7.xcframework.zip",
            checksum: "93861249066a1f9914c56fda7805c7644a489e8285f04e7bf9a77f54c6b43816"
        ),
        .binaryTarget(
            name: "JL_OTALib",
            url: "https://github.com/caitunai/JieLi-Recorder-iOS-Sdk/releases/download/v1.0.7/JL_OTALib-1.0.7.xcframework.zip",
            checksum: "c0f8f223af3b27f03ac542835257f9fca0d9ab3385058937e9ae78583b369e85"
        ),
        .binaryTarget(
            name: "JLAudioUnitKit",
            url: "https://github.com/caitunai/JieLi-Recorder-iOS-Sdk/releases/download/v1.0.7/JLAudioUnitKit-1.0.7.xcframework.zip",
            checksum: "277f7184f7747208594bf2bd2ddfc4cd811777c741188c9362c48ce0cd0b8a50"
        ),
    ],
    swiftLanguageModes: [.v6]
)
