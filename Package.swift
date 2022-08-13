// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "APIKit",
    platforms: [
        .macOS(.v10_10), .iOS(.v9), .tvOS(.v9), .watchOS(.v2)
    ],
    products: [
        .library(name: "APIKit", targets: ["APIKit"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "APIKit", 
            dependencies: [],
            exclude: ["BodyParameters/AbstractInputStream.m"]
        ),
         .testTarget(
            name: "APIKitTests",
            dependencies: ["APIKit"],
            resources: [.process("Resources")]
        ),
    ],
    swiftLanguageVersions: [.v5]
)
