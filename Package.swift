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
            url: "https://github.com/caitunai/JieLi-Recorder-iOS-Sdk/releases/download/v1.0.2/JieLiSdkRecorder-1.0.2.xcframework.zip",
            checksum: "308b223ce62e492b8b5b6c90c2b037f2bd342f0a90c2e78b8c051c5474f20079"
        ),
        .binaryTarget(
            name: "JL_AdvParse",
            url: "https://github.com/caitunai/JieLi-Recorder-iOS-Sdk/releases/download/v1.0.2/JL_AdvParse-1.0.2.xcframework.zip",
            checksum: "06ca2362949e73c6711654e7a12b42a6362f927a9c775cd922557221314898c9"
        ),
        .binaryTarget(
            name: "JL_HashPair",
            url: "https://github.com/caitunai/JieLi-Recorder-iOS-Sdk/releases/download/v1.0.2/JL_HashPair-1.0.2.xcframework.zip",
            checksum: "625c3cc7044b5411521206fa359d11d58ba99fdc8eb41116545ed040cdb41121"
        ),
        .binaryTarget(
            name: "JLLogHelper",
            url: "https://github.com/caitunai/JieLi-Recorder-iOS-Sdk/releases/download/v1.0.2/JLLogHelper-1.0.2.xcframework.zip",
            checksum: "9a5951712fe33ec4d0a6a167bdfe50b9b86b0067c123cf634d19e1898cd99022"
        ),
        .binaryTarget(
            name: "JL_BLEKit",
            url: "https://github.com/caitunai/JieLi-Recorder-iOS-Sdk/releases/download/v1.0.2/JL_BLEKit-1.0.2.xcframework.zip",
            checksum: "1307cda52aad95b7747d41d58241f246b02bbc25ee92cec646038e6dbb1cf137"
        ),
        .binaryTarget(
            name: "JL_OTALib",
            url: "https://github.com/caitunai/JieLi-Recorder-iOS-Sdk/releases/download/v1.0.2/JL_OTALib-1.0.2.xcframework.zip",
            checksum: "5322a695d3cc78a86a86f38845f60cc82ab93cd6368733b42d9f661ef67f89f8"
        ),
        .binaryTarget(
            name: "JLAudioUnitKit",
            url: "https://github.com/caitunai/JieLi-Recorder-iOS-Sdk/releases/download/v1.0.2/JLAudioUnitKit-1.0.2.xcframework.zip",
            checksum: "0ed32138d4c3579ea7f7675998d6cb70ae9f000dd618110fd026718da52d5c11"
        ),
    ],
    swiftLanguageModes: [.v6]
)
