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
            checksum: "e7f8e325f4d05ca16a15dde3d1d7f5111a87d86f1202eb794377dbdb8658b96c"
        ),
    ]
)

