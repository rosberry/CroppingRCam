// swift-tools-version:5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CroppingRCam",
    defaultLocalization: "en",
    platforms: [.iOS(.v11), .macOS(.v10_12), .tvOS(.v10), .watchOS(.v2)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "CroppingRCam",
            targets: ["CroppingRCam"])
    ],
    dependencies: [
        .package(url: "https://github.com/rosberry/Framezilla", from: "5.1.1"),
        .package(url: "https://github.com/rosberry/Cripper", .branch("master")),
        .package(name: "Rcam", url: "https://github.com/rosberry/rcam", .branch("master"))
    ],
    targets: [
        .target(
            name: "CroppingRCam",
            dependencies: ["Framezilla", "Cripper", "Rcam"])
    ]
)
