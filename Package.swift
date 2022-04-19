// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CroppingRCam",
    platforms: [.iOS(.v11)],
    products: [
        .library(name: "CroppingRCam", targets: ["CroppingRCam"]),
    ],
    targets: [
        .target(name: "CroppingRCam", path: "CroppingRCam/Sources"),
        .testTarget(name: "CroppingRCamTests", dependencies: ["CroppingRCam"], path: "CroppingRCam/Tests")
    ]
)
