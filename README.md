APIKit
======

[![Build Status](https://travis-ci.org/ishkawa/APIKit.svg?branch=master)](https://travis-ci.org/ishkawa/APIKit)
[![codecov](https://codecov.io/gh/ishkawa/APIKit/branch/master/graph/badge.svg)](https://codecov.io/gh/ishkawa/APIKit)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Version](https://img.shields.io/cocoapods/v/APIKit.svg?style=flat)](http://cocoadocs.org/docsets/APIKit)
[![Platform](https://img.shields.io/cocoapods/p/APIKit.svg?style=flat)](http://cocoadocs.org/docsets/APIKit)


APIKit is a type-safe networking abstraction layer that associates request type with response type.

```swift
// SearchRepositoriesRequest conforms to Request protocol.
let request = SearchRepositoriesRequest(query: "swift")

// Session receives an instance of a type that conforms to Request.
Session.send(request) { result in
    switch result {
    case .success(let response):
        // Type of `response` is `[Repository]`,
        // which is inferred from `SearchRepositoriesRequest`.
        print(response)

    case .failure(let error):
        self.printError(error)
    }
}
```

## Requirements

- Swift 3.0
- iOS 8.0 or later
- Mac OS 10.10 or later
- watchOS 2.0 or later
- tvOS 9.0 or later

If you use Swift 2.2 or 2.3, try [APIKit 2.0.5](https://github.com/ishkawa/APIKit/tree/2.0.5).

## Installation

#### [Carthage](https://github.com/Carthage/Carthage)

- Insert `github "ishkawa/APIKit" ~> 3.0` to your Cartfile.
- Run `carthage update`.
- Link your app with `APIKit.framework` and `Result.framework` in `Carthage/Build`.

#### [CocoaPods](https://github.com/cocoapods/cocoapods)

- Insert `pod 'APIKit', '~> 3.0'` to your Podfile.
- Run `pod install`.

Note: CocoaPods 1.1.0 is required to install APIKit 3.

## Documentation

- [Getting started](Documentation/GettingStarted.md)
- [Defining Request Protocol for Web Service](Documentation/DefiningRequestProtocolForWebService.md)
- [Convenience Parameters and Actual Parameters](Documentation/ConvenienceParametersAndActualParameters.md)

### Advanced Guides

- [Customizing Networking Backend](Documentation/CustomizingNetworkingBackend.md)

### Migration Guides

- [APIKit 3 Migration Guide](Documentation/APIKit3MigrationGuide.md)
- [APIKit 2 Migration Guide](Documentation/APIKit2MigrationGuide.md)
