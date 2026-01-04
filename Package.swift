// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "PredictionKeyboard",
    platforms: [
        .iOS(.v12)
    ],
    products: [
        .library(
            name: "PredictionKeyboard",
            targets: ["PredictionKeyboard"]
        ),
    ],
    targets: [
        .binaryTarget(
            name: "PredictionKeyboard",
            url: "https://youtakeadvantage.s3.eu-central-1.amazonaws.com/PredictionKeyboard_spm.zip",
            checksum: "b3c82626fa0c15c17a92c384fafa927962ebccb78fc48070bbc2952035b7508b"
        ),
    ]
)
