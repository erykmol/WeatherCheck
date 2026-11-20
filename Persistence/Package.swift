// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Persistence",
    platforms: [.iOS(.v17)],
    products: [
        .library(
            name: "Persistence",
            targets: ["Persistence"]
        ),
        .library(
            name: "PersistenceTestHelpers",
            targets: ["PersistenceTestHelpers"]
        ),
    ],
    targets: [
        .target(
            name: "Persistence",
            swiftSettings: [
                .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
                .enableUpcomingFeature("InferIsolatedConformances"),
                .enableUpcomingFeature("ExistentialAny"),
            ],
        ),
        .target(
            name: "PersistenceTestHelpers",
            dependencies: ["Persistence"],
            swiftSettings: [
                .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
                .enableUpcomingFeature("InferIsolatedConformances"),
                .enableUpcomingFeature("ExistentialAny"),
            ],
        ),
        .target(
            name: "PersistenceTestFixtures",
            dependencies: ["Persistence"],
            swiftSettings: [
                .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
                .enableUpcomingFeature("InferIsolatedConformances"),
                .enableUpcomingFeature("ExistentialAny"),
            ],
        ),
        .testTarget(
            name: "PersistenceTests",
            dependencies: ["Persistence", "PersistenceTestFixtures"],
            swiftSettings: [
                .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
                .enableUpcomingFeature("InferIsolatedConformances"),
                .enableUpcomingFeature("ExistentialAny"),
            ],
        ),
    ]
)
