// swift-tools-version:5.0
import PackageDescription

var platforms: [SupportedPlatform] {
    #if compiler(<5.3)
        return [
            .macOS(.v10_10), .iOS(.v8), .tvOS(.v9), .watchOS(.v2)
        ]
    #else
        // Xcode 12 (which ships with Swift 5.3) drops support for iOS 8
        return [
            .macOS(.v10_10), .iOS(.v9), .tvOS(.v9), .watchOS(.v2)
        ]
    #endif
}

let package = Package(
    name: "APIKit",
    platforms: platforms,
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
