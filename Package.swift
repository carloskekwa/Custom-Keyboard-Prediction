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
            url: "https://youtakeadvantage.s3.eu-central-1.amazonaws.com/PredictionKeyboard.zip",
            checksum: "dda327f08c4b67628ff0235aa40faa7b905e5b8702bc4d3aba4dfd9ab8c9c70a"
        ),
    ]
)
