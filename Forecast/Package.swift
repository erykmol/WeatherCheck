// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Forecast",
    defaultLocalization: "pl",
    platforms: [.iOS(.v17)],
    products: [
        .library(
            name: "Forecast",
            targets: ["Forecast"]
        ),
    ],
    dependencies: [
        .package(path: "../Networking"),
        .package(path: "../DesignSystem"),
    ],
    targets: [
        .target(
            name: "Forecast",
            dependencies: [
                .product(name: "Networking", package: "Networking"),
                .product(name: "DesignSystem", package: "DesignSystem"),
            ],
            resources: [.process("Resources")],
            swiftSettings: [
                .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
                .enableUpcomingFeature("InferIsolatedConformances"),
                .enableUpcomingFeature("ExistentialAny"),
            ],
        ),
        .testTarget(
            name: "ForecastTests",
            dependencies: [
                "Forecast",
                .product(name: "NetworkingTestHelpers", package: "Networking"),
            ],
            swiftSettings: [
                .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
                .enableUpcomingFeature("InferIsolatedConformances"),
                .enableUpcomingFeature("ExistentialAny"),
            ],
        ),
    ]
)
