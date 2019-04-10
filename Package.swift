// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "APIKit",
    products: [
        .library(name: "APIKit", targets: ["APIKit"]),
    ],
    targets: [
        .target(
            name: "APIKit",
            exclude: ["BodyParameters/AbstractInputStream.m"]
        ),
         .testTarget(
            name: "APIKitTests",
            dependencies: ["APIKit"]
        ),
    ],
    swiftLanguageVersions: [.v5]
)
