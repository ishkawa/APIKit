// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "APIKit",
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
            dependencies: ["APIKit"]
        ),
    ],
    swiftLanguageVersions: [.v5]
)
