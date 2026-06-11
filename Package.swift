// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "iOSCleanArchitectureTemplate",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .watchOS(.v8),
        .tvOS(.v15)
    ],
    products: [
        // MARK: - Main Products
        .library(
            name: "iOSCleanArchitectureTemplate",
            targets: ["iOSCleanArchitectureTemplate"]
        ),

        // MARK: - Feature Modules
        .library(name: "Domain", targets: ["Domain"]),
        .library(name: "Data", targets: ["Data"]),
        .library(name: "Presentation", targets: ["Presentation"]),
        .library(name: "Infrastructure", targets: ["Infrastructure"])
    ],
    dependencies: [
        // MARK: - Testing Dependencies
        .package(url: "https://github.com/Quick/Quick.git", from: "7.0.0"),
        .package(url: "https://github.com/Quick/Nimble.git", from: "12.0.0"),
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing.git", from: "1.16.0")
    ],
    targets: [
        // MARK: - Main Target
        .target(
            name: "iOSCleanArchitectureTemplate",
            dependencies: [
                "Domain",
                "Data",
                "Presentation",
                "Infrastructure"
            ],
            path: "Sources",
            exclude: ["Domain", "Data", "Presentation", "Infrastructure", "Core"]
        ),

        // MARK: - Domain Layer
        .target(
            name: "Domain",
            dependencies: [],
            path: "Sources/Domain"
        ),

        // MARK: - Data Layer
        .target(
            name: "Data",
            dependencies: ["Domain"],
            path: "Sources/Data"
        ),

        // MARK: - Presentation Layer
        .target(
            name: "Presentation",
            dependencies: ["Domain"],
            path: "Sources/Presentation"
        ),

        // MARK: - Infrastructure Layer
        .target(
            name: "Infrastructure",
            dependencies: ["Domain"],
            path: "Sources/Infrastructure"
        ),

        // MARK: - Tests
        .testTarget(
            name: "UnitTests",
            dependencies: ["Domain", "Data", "Presentation", "Infrastructure", "Quick", "Nimble"],
            path: "Tests/UnitTests"
        ),

        .testTarget(
            name: "IntegrationTests",
            dependencies: ["Domain", "Data", "Infrastructure", "Quick", "Nimble"],
            path: "Tests/IntegrationTests"
        ),

        .testTarget(
            name: "UITests",
            dependencies: ["Presentation", "Quick", "Nimble"],
            path: "Tests/UITests"
        )
    ]
)