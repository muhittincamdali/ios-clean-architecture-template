// swift-tools-version: 5.7
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
        .library(
            name: "Domain",
            targets: ["Domain"]
        ),
        .library(
            name: "Data",
            targets: ["Data"]
        ),
        .library(
            name: "Presentation",
            targets: ["Presentation"]
        ),
        .library(
            name: "Infrastructure",
            targets: ["Infrastructure"]
        ),

        // MARK: - Utility Modules
        .library(
            name: "DesignSystem",
            targets: ["DesignSystem"]
        ),
        .library(
            name: "Analytics",
            targets: ["Analytics"]
        ),
        .library(
            name: "Security",
            targets: ["Security"]
        ),
        .library(
            name: "Performance",
            targets: ["Performance"]
        )
    ],
    dependencies: [
        // MARK: - Core Dependencies
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.8.1"),
        .package(url: "https://github.com/onevcat/Kingfisher.git", from: "7.10.1"),
        .package(url: "https://github.com/ReactiveX/RxSwift.git", from: "6.6.0"),
        .package(url: "https://github.com/Quick/Quick.git", from: "7.0.0"),
        .package(url: "https://github.com/Quick/Nimble.git", from: "12.0.0"),

        // MARK: - UI Dependencies
        .package(url: "https://github.com/SnapKit/SnapKit.git", from: "5.6.0"),
        .package(url: "https://github.com/SwiftUIX/SwiftUIX.git", from: "0.1.4"),

        // MARK: - Utility Dependencies
        .package(url: "https://github.com/airbnb/lottie-ios.git", from: "4.3.3"),
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", from: "10.18.0"),
        .package(url: "https://github.com/facebook/facebook-ios-sdk.git", from: "16.1.3"),
        .package(url: "https://github.com/google/GoogleSignIn-iOS.git", from: "7.0.0"),

        // MARK: - Testing Dependencies
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing.git", from: "1.16.0"),
        .package(url: "https://github.com/kstenerud/KSCrash.git", from: "1.15.21")
    ],
    targets: [
        // MARK: - Main Target
        .target(
            name: "iOSCleanArchitectureTemplate",
            dependencies: [
                "Domain",
                "Data",
                "Presentation",
                "Infrastructure",
                "DesignSystem",
                "Analytics",
                "Security",
                "Performance"
            ],
            path: "Sources"
        ),

        // MARK: - Domain Layer
        .target(
            name: "Domain",
            dependencies: [],
            path: "Sources/Domain",
            swiftSettings: [
                .define("DEBUG", .when(configuration: .debug)),
                .define("RELEASE", .when(configuration: .release))
            ]
        ),

        // MARK: - Data Layer
        .target(
            name: "Data",
            dependencies: [
                "Domain",
                .product(name: "Alamofire", package: "Alamofire"),
                .product(name: "Kingfisher", package: "Kingfisher")
            ],
            path: "Sources/Data",
            swiftSettings: [
                .define("DEBUG", .when(configuration: .debug)),
                .define("RELEASE", .when(configuration: .release))
            ]
        ),

        // MARK: - Presentation Layer
        .target(
            name: "Presentation",
            dependencies: [
                "Domain",
                "DesignSystem",
                .product(name: "RxSwift", package: "RxSwift"),
                .product(name: "SwiftUIX", package: "SwiftUIX")
            ],
            path: "Sources/Presentation",
            swiftSettings: [
                .define("DEBUG", .when(configuration: .debug)),
                .define("RELEASE", .when(configuration: .release))
            ]
        ),

        // MARK: - Infrastructure Layer
        .target(
            name: "Infrastructure",
            dependencies: [
                "Domain",
                "Analytics",
                "Security",
                "Performance",
                .product(name: "FirebaseAnalytics", package: "firebase-ios-sdk"),
                .product(name: "FirebaseCrashlytics", package: "firebase-ios-sdk"),
                .product(name: "FirebaseRemoteConfig", package: "firebase-ios-sdk"),
                .product(name: "FacebookCore", package: "facebook-ios-sdk"),
                .product(name: "GoogleSignIn", package: "GoogleSignIn-iOS"),
                .product(name: "Lottie", package: "lottie-ios")
            ],
            path: "Sources/Infrastructure",
            swiftSettings: [
                .define("DEBUG", .when(configuration: .debug)),
                .define("RELEASE", .when(configuration: .release))
            ]
        ),

        // MARK: - Design System
        .target(
            name: "DesignSystem",
            dependencies: [
                .product(name: "Lottie", package: "lottie-ios")
            ],
            path: "Sources/Infrastructure/Design",
            swiftSettings: [
                .define("DEBUG", .when(configuration: .debug)),
                .define("RELEASE", .when(configuration: .release))
            ]
        ),

        // MARK: - Analytics
        .target(
            name: "Analytics",
            dependencies: [
                .product(name: "FirebaseAnalytics", package: "firebase-ios-sdk"),
                .product(name: "FacebookCore", package: "facebook-ios-sdk")
            ],
            path: "Sources/Infrastructure/Analytics",
            swiftSettings: [
                .define("DEBUG", .when(configuration: .debug)),
                .define("RELEASE", .when(configuration: .release))
            ]
        ),

        // MARK: - Security
        .target(
            name: "Security",
            dependencies: [
                .product(name: "GoogleSignIn", package: "GoogleSignIn-iOS")
            ],
            path: "Sources/Infrastructure/Security",
            swiftSettings: [
                .define("DEBUG", .when(configuration: .debug)),
                .define("RELEASE", .when(configuration: .release))
            ]
        ),

        // MARK: - Performance
        .target(
            name: "Performance",
            dependencies: [
                .product(name: "FirebasePerformance", package: "firebase-ios-sdk")
            ],
            path: "Sources/Infrastructure/Performance",
            swiftSettings: [
                .define("DEBUG", .when(configuration: .debug)),
                .define("RELEASE", .when(configuration: .release))
            ]
        ),

        // MARK: - Tests
        .testTarget(
            name: "DomainTests",
            dependencies: [
                "Domain",
                "Quick",
                "Nimble"
            ],
            path: "Tests/UnitTests"
        ),

        .testTarget(
            name: "DataTests",
            dependencies: [
                "Data",
                "Domain",
                "Quick",
                "Nimble"
            ],
            path: "Tests/DataTests"
        ),

        .testTarget(
            name: "PresentationTests",
            dependencies: [
                "Presentation",
                "Domain",
                "Quick",
                "Nimble",
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing")
            ],
            path: "Tests/PresentationTests"
        ),

        .testTarget(
            name: "InfrastructureTests",
            dependencies: [
                "Infrastructure",
                "Domain",
                "Quick",
                "Nimble"
            ],
            path: "Tests/InfrastructureTests"
        ),

        .testTarget(
            name: "UITests",
            dependencies: [
                "Presentation",
                "Domain",
                "Quick",
                "Nimble"
            ],
            path: "Tests/UITests"
        )
    ]
) 