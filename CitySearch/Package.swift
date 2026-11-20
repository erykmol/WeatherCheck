// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CitySearch",
    defaultLocalization: "pl",
    platforms: [.iOS(.v17)],
    products: [
        .library(
            name: "CitySearch",
            targets: ["CitySearch"]
        ),
        .library(
            name: "CitySearchStorage",
            targets: ["CitySearchStorage"]
        ),
    ],
    dependencies: [
        .package(path: "../Networking"),
        .package(path: "../DesignSystem"),
        .package(path: "../Persistence"),
    ],
    targets: [
        .target(
            name: "CitySearch",
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
        .target(
            name: "CitySearchStorage",
            dependencies: [
                "CitySearch",
                .product(name: "Persistence", package: "Persistence"),
            ],
            swiftSettings: [
                .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
                .enableUpcomingFeature("InferIsolatedConformances"),
                .enableUpcomingFeature("ExistentialAny"),
            ],
        ),
        .testTarget(
            name: "CitySearchTests",
            dependencies: [
                "CitySearch",
                .product(name: "NetworkingTestHelpers", package: "Networking"),
            ],
            swiftSettings: [
                .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
                .enableUpcomingFeature("InferIsolatedConformances"),
                .enableUpcomingFeature("ExistentialAny"),
            ],
        ),
        .testTarget(
            name: "CitySearchStorageTests",
            dependencies: [
                "CitySearchStorage",
                .product(name: "Persistence", package: "Persistence"),
            ],
            swiftSettings: [
                .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
                .enableUpcomingFeature("InferIsolatedConformances"),
                .enableUpcomingFeature("ExistentialAny"),
            ],
        ),
        .testTarget(
            name: "CitySearchStorageIntegrationTests",
            dependencies: [
                "CitySearch",
                "CitySearchStorage",
                .product(name: "Persistence", package: "Persistence"),
            ],
            swiftSettings: [
                .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
                .enableUpcomingFeature("InferIsolatedConformances"),
                .enableUpcomingFeature("ExistentialAny"),
            ],
        ),
    ]
)
