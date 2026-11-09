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
            url: "https://github.com/caitunai/JieLi-Recorder-iOS-Sdk/releases/download/v1.0.10/JieLiSdkRecorder-1.0.10.xcframework.zip",
            checksum: "cd2d7c3b5d0795609412276f130f2129ed427ae18389f1a36669459d19a947de"
        ),
        .binaryTarget(
            name: "JL_AdvParse",
            url: "https://github.com/caitunai/JieLi-Recorder-iOS-Sdk/releases/download/v1.0.10/JL_AdvParse-1.0.10.xcframework.zip",
            checksum: "e871e487cdcb4c200338e66b621df550809792dcf62e0c245b0ff742118a8431"
        ),
        .binaryTarget(
            name: "JL_HashPair",
            url: "https://github.com/caitunai/JieLi-Recorder-iOS-Sdk/releases/download/v1.0.10/JL_HashPair-1.0.10.xcframework.zip",
            checksum: "8952115f96334234984f8bcb517933751612d6d5b59e8c355de3036852fa0f86"
        ),
        .binaryTarget(
            name: "JLLogHelper",
            url: "https://github.com/caitunai/JieLi-Recorder-iOS-Sdk/releases/download/v1.0.10/JLLogHelper-1.0.10.xcframework.zip",
            checksum: "6615cb16ac8cf690ab51dfff4f16727bf104ea2655ad33883d6185f1572db851"
        ),
        .binaryTarget(
            name: "JL_BLEKit",
            url: "https://github.com/caitunai/JieLi-Recorder-iOS-Sdk/releases/download/v1.0.10/JL_BLEKit-1.0.10.xcframework.zip",
            checksum: "1eea138d64ef9960ef86fc3c5847c7da21a484aa689cfb8b58b26e3fc7841bbf"
        ),
        .binaryTarget(
            name: "JL_OTALib",
            url: "https://github.com/caitunai/JieLi-Recorder-iOS-Sdk/releases/download/v1.0.10/JL_OTALib-1.0.10.xcframework.zip",
            checksum: "ecb0b3b905ad1203403e021ea424ce072f25ed686025d58b07aa4adf0d60d4ae"
        ),
        .binaryTarget(
            name: "JLAudioUnitKit",
            url: "https://github.com/caitunai/JieLi-Recorder-iOS-Sdk/releases/download/v1.0.10/JLAudioUnitKit-1.0.10.xcframework.zip",
            checksum: "49c868e85b1ed89a72814a41c89c69ba44c4c56c8fb49e5026bfd1aaddf241d6"
        ),
    ],
    swiftLanguageModes: [.v6]
)
