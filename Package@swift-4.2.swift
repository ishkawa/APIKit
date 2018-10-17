// swift-tools-version:4.2
import PackageDescription

let package = Package(
    name: "APIKit",
    products: [
        .library(name: "APIKit", targets: ["APIKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/antitypical/Result.git", from: "4.0.0"),
    ],
    targets: [
        .target(
            name: "APIKit", 
            dependencies: ["Result"],
            exclude: ["BodyParameters/AbstractInputStream.m"]
        ),
         .testTarget(
            name: "APIKitTests",
            dependencies: ["APIKit"]
        ),
    ],
    swiftLanguageVersions: [.v4, .v4_2]
)
