APIKit
======

[![Build Status](https://travis-ci.org/ishkawa/APIKit.svg?branch=master)](https://travis-ci.org/ishkawa/APIKit)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

APIKit is a type-safe networking abstraction layer that associates request type with response type.

```swift
let request = SearchRepositoriesRequest(query: "APIKit", sort: .Stars)

Session.sendRequest(request) { result in
    switch result {
    case .Success(let repositories):
        // Type of `repositories` is `[Repository]`,
        // which is inferred from `SearchRepositoriesRequest`.
        print(repositories)

    case .Failure(let error):
        print(error)
    }
}
```

## Requirements

- Swift 2.1+
- iOS 8.0+ / Mac OS 10.10+ / watchOS 2.0+ / tvOS 9.0+

## Installation

#### [Carthage](https://github.com/Carthage/Carthage)

- Insert `github "ishkawa/APIKit" ~> 1.2.1` to your Cartfile.
- Run `carthage update`.
- Link your app with `APIKit.framework` and `Result.framework` in `Carthage/Checkouts`.

#### [CocoaPods](https://github.com/cocoapods/cocoapods)

- Insert `pod 'APIKit', '~> 1.2.1'` to your Podfile.
- Run `pod install`.

## Documentation

### Basic Usage

- [Getting started](Documentation/GettingStarted.md)
- [Defining Request Protocol for Web Service](Documentation/DefiningRequestProtocolForWebService.md)
- [Convenience Parameters and Actual Parameters](Documentation/ConvenienceParametersAndActualParameters.md)

### Advanced Usage

- Customizing Networking Backend

### Migration

- [APIKit 2 Migration Guide](Documentation/APIKit2MigrationGuide.md)
