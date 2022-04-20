// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CroppingRCam",
    platforms: [.iOS(.v11)],
    products: [
        .library(
            name: "CroppingRCam",
            targets: ["CroppingRCam"]),
    ],
    dependencies: [
            // Dependencies declare other packages that this package depends on.
            // .package(url: /* package url */, from: "1.0.0"),
            .package(url: "https://github.com/rosberry/rcam",
                        .branch("master")),
            .package(url: "https://github.com/rosberry/Cripper",
                        .branch("master")),
            .package(url: "https://github.com/rosberry/Bin-iOS",
                        .branch("no-xcframeworks")),
        ],
    targets: [
        .target(name: "CroppingRCam",
                dependencies: ["Rcam", "Cripper"],
                path: "CroppingRCam/Sources"),
        .testTarget(name: "CroppingRCamTests",
                    dependencies: ["CroppingRCam"],
                    path: "CroppingRCam/Tests")
    ]
)
