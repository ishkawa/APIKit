import PackageDescription

let package = Package(
    name: "APIKit",
    dependencies: [
        .Package(url: "https://github.com/antitypical/Result.git", majorVersion: 3),
    ],
    exclude: ["Sources/APIKit/BodyParameters/AbstractInputStream.m"]
)
