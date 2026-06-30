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
            url: "https://github.com/caitunai/JieLi-Recorder-iOS-Sdk/releases/download/v1.0.1/JieLiSdkRecorder-1.0.1.xcframework.zip",
            checksum: "ff9c33918ea9273dd9dc67a016e6f3e34490714d9ddba7faf2335dcf289da00c"
        ),
        .binaryTarget(
            name: "JL_AdvParse",
            url: "https://github.com/caitunai/JieLi-Recorder-iOS-Sdk/releases/download/v1.0.1/JL_AdvParse-1.0.1.xcframework.zip",
            checksum: "021ba31ae20214c609f2bee85c7b6cce219d96905f7b792a050ea089f1cedc3c"
        ),
        .binaryTarget(
            name: "JL_HashPair",
            url: "https://github.com/caitunai/JieLi-Recorder-iOS-Sdk/releases/download/v1.0.1/JL_HashPair-1.0.1.xcframework.zip",
            checksum: "625c3cc7044b5411521206fa359d11d58ba99fdc8eb41116545ed040cdb41121"
        ),
        .binaryTarget(
            name: "JLLogHelper",
            url: "https://github.com/caitunai/JieLi-Recorder-iOS-Sdk/releases/download/v1.0.1/JLLogHelper-1.0.1.xcframework.zip",
            checksum: "9a5951712fe33ec4d0a6a167bdfe50b9b86b0067c123cf634d19e1898cd99022"
        ),
        .binaryTarget(
            name: "JL_BLEKit",
            url: "https://github.com/caitunai/JieLi-Recorder-iOS-Sdk/releases/download/v1.0.1/JL_BLEKit-1.0.1.xcframework.zip",
            checksum: "1307cda52aad95b7747d41d58241f246b02bbc25ee92cec646038e6dbb1cf137"
        ),
        .binaryTarget(
            name: "JL_OTALib",
            url: "https://github.com/caitunai/JieLi-Recorder-iOS-Sdk/releases/download/v1.0.1/JL_OTALib-1.0.1.xcframework.zip",
            checksum: "5322a695d3cc78a86a86f38845f60cc82ab93cd6368733b42d9f661ef67f89f8"
        ),
        .binaryTarget(
            name: "JLAudioUnitKit",
            url: "https://github.com/caitunai/JieLi-Recorder-iOS-Sdk/releases/download/v1.0.1/JLAudioUnitKit-1.0.1.xcframework.zip",
            checksum: "0ed32138d4c3579ea7f7675998d6cb70ae9f000dd618110fd026718da52d5c11"
        ),
    ],
    swiftLanguageModes: [.v6]
)
