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
            checksum: "cca9d5da671f2417d8bef0cf2391ecc6d1deb4303323d752cf35751f61f8a1be"
        ),
    ]
)

