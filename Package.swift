// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ZiweiGhibliApp",
    defaultLocalization: "zh-Hant",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "ZiweiGhibliApp",
            targets: ["ZiweiGhibliApp"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "ZiweiGhibliApp",
            path: "ZiweiGhibliApp"
        ),
        .testTarget(
            name: "ZiweiGhibliAppTests",
            dependencies: ["ZiweiGhibliApp"],
            path: "Tests"
        ),
    ]
)
