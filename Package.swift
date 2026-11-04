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
            url: "https://github.com/caitunai/JieLi-Recorder-iOS-Sdk/releases/download/v1.0.9/JieLiSdkRecorder-1.0.9.xcframework.zip",
            checksum: "64a3fe8f274c555b5b145d15a641b3588f90ef8579f7e9e2d26d9177adabd78a"
        ),
        .binaryTarget(
            name: "JL_AdvParse",
            url: "https://github.com/caitunai/JieLi-Recorder-iOS-Sdk/releases/download/v1.0.9/JL_AdvParse-1.0.9.xcframework.zip",
            checksum: "bd18c4c05a735150bed543ef5e4604415e80c1f9c41731e4bfddd2c5e6451440"
        ),
        .binaryTarget(
            name: "JL_HashPair",
            url: "https://github.com/caitunai/JieLi-Recorder-iOS-Sdk/releases/download/v1.0.9/JL_HashPair-1.0.9.xcframework.zip",
            checksum: "719e0bdec19a33ca96414f2e20d356b89f8ccd686062d992916a38a8ce7ab4ed"
        ),
        .binaryTarget(
            name: "JLLogHelper",
            url: "https://github.com/caitunai/JieLi-Recorder-iOS-Sdk/releases/download/v1.0.9/JLLogHelper-1.0.9.xcframework.zip",
            checksum: "419776a5f7a8526812268ce573705770921faaadb7ddb6c2af3d8ffd7078c57d"
        ),
        .binaryTarget(
            name: "JL_BLEKit",
            url: "https://github.com/caitunai/JieLi-Recorder-iOS-Sdk/releases/download/v1.0.9/JL_BLEKit-1.0.9.xcframework.zip",
            checksum: "c7e5cd7b4ff6c8cedc3b3920a035d80d9053af6711b0de9cd62760a6897bae2c"
        ),
        .binaryTarget(
            name: "JL_OTALib",
            url: "https://github.com/caitunai/JieLi-Recorder-iOS-Sdk/releases/download/v1.0.9/JL_OTALib-1.0.9.xcframework.zip",
            checksum: "dcfc2dfd0deb0b7f9dfbf46b341bd89f5bee26e7d497892f5f10cc593e66e3e8"
        ),
        .binaryTarget(
            name: "JLAudioUnitKit",
            url: "https://github.com/caitunai/JieLi-Recorder-iOS-Sdk/releases/download/v1.0.9/JLAudioUnitKit-1.0.9.xcframework.zip",
            checksum: "416a5c3f41f6ce7d866cc969d70f6f10f8fee6ce40d76e86da119d4f353eaa58"
        ),
    ],
    swiftLanguageModes: [.v6]
)
