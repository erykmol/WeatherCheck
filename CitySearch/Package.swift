// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CitySearch",
    platforms: [.iOS(.v17)],
    products: [
        .library(
            name: "CitySearch",
            targets: ["CitySearch"]
        ),
    ],
    dependencies: [
        .package(path: "../Networking"),
        .package(path: "../Persistence"),
    ],
    targets: [
        .target(
            name: "CitySearch",
            dependencies: [
                .product(name: "Networking", package: "Networking"),
                .product(name: "Persistence", package: "Persistence"),
            ],
            swiftSettings: [
                .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
                .enableUpcomingFeature("InferIsolatedConformances"),
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
            ],
        ),
    ]
)
