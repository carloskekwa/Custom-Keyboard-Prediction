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
            checksum: "3a883307edc644e77e170159e2a147e878b3650af20803af4e2833106bf4f5be"
        ),
    ]
)
