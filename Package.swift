// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Confetti",
    platforms: [
        .macOS(.v15),
        .iOS(.v18),
    ],
    products: [
        // ConfettiCore is an internal module (not exposed as a product)
        // Users should import ConfettiPlayback or ConfettiUI instead
        .library(name: "ConfettiPlayback", targets: ["ConfettiPlayback"]),
        .library(name: "ConfettiUI", targets: ["ConfettiUI"]),
    ],
    targets: [
        .target(
            name: "ConfettiCore"
        ),
        .target(
            name: "ConfettiPlayback",
            dependencies: ["ConfettiCore"],
            resources: [
                .process("Resources"),
            ]
        ),
        .target(
            name: "ConfettiUI",
            dependencies: ["ConfettiPlayback"]
        ),
        .testTarget(
            name: "ConfettiCoreTests",
            dependencies: ["ConfettiCore"]
        ),
        .testTarget(
            name: "ConfettiUITests",
            dependencies: ["ConfettiPlayback", "ConfettiUI"]
        ),
    ]
)
