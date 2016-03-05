import PackageDescription

let package = Package(
    name: "APIKit",
    dependencies: [
        .Package(url: "https://github.com/antitypical/Result.git", majorVersion: 1),
    ]
)
