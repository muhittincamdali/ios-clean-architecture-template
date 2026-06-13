// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "iOSCleanArchitectureTemplate",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
        .library(name: "iOSCleanArchitectureTemplate", targets: ["iOSCleanArchitectureTemplate"]),
        .library(name: "Domain", targets: ["Domain"]),
        .library(name: "Data", targets: ["Data"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "iOSCleanArchitectureTemplate",
            dependencies: ["Domain", "Data"],
            path: "Sources/iOSCleanArchitectureTemplate"
        ),
        .target(
            name: "Domain",
            path: "Sources/Domain"
        ),
        .target(
            name: "Data",
            dependencies: ["Domain"],
            path: "Sources/Data"
        )
    ]
)
