# API Reference

## Core Classes

### Main Framework

The main entry point for the ios-clean-architecture-template framework.

```swift
public class ios-clean-architecture-template {
    public init()
    public func configure()
    public func reset()
}
```

## Configuration

### Options

```swift
public struct Configuration {
    public var debugMode: Bool
    public var logLevel: LogLevel
    public var cacheEnabled: Bool
}
```

## Error Handling

```swift
public enum ios-clean-architecture-templateError: Error {
    case configurationFailed
    case initializationError
    case runtimeError(String)
}
