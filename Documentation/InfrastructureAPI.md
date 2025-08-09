# Infrastructure Layer API

<!-- TOC START -->
## Table of Contents
- [Infrastructure Layer API](#infrastructure-layer-api)
- [Overview](#overview)
- [Networking](#networking)
  - [Network Client](#network-client)
  - [Network Error Handling](#network-error-handling)
- [Logging](#logging)
  - [Logger](#logger)
- [Analytics](#analytics)
  - [Analytics Service](#analytics-service)
- [Security](#security)
  - [Security Service](#security-service)
- [Keychain Service](#keychain-service)
- [Testing](#testing)
  - [Infrastructure Tests](#infrastructure-tests)
- [Best Practices](#best-practices)
<!-- TOC END -->


## Overview

The Infrastructure Layer provides external services, utilities, and cross-cutting concerns. It includes networking, logging, analytics, security, and other infrastructure components.

## Networking

### Network Client

```swift
protocol NetworkClient {
    func request<T: Codable>(_ endpoint: APIEndpoint) async throws -> T
    func upload<T: Codable>(_ data: Data, to endpoint: APIEndpoint) async throws -> T
    func download(from endpoint: APIEndpoint) async throws -> Data
}

class NetworkClientImpl: NetworkClient {
    private let session: URLSession
    private let baseURL: URL
    private let headers: [String: String]
    
    init(session: URLSession = .shared, baseURL: URL, headers: [String: String] = [:]) {
        self.session = session
        self.baseURL = baseURL
        self.headers = headers
    }
    
    func request<T: Codable>(_ endpoint: APIEndpoint) async throws -> T {
        let url = baseURL.appendingPathComponent(endpoint.path)
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        
        // Add headers
        headers.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        guard 200...299 ~= httpResponse.statusCode else {
            throw NetworkError.serverError(httpResponse.statusCode)
        }
        
        return try JSONDecoder().decode(T.self, from: data)
    }
    
    func upload<T: Codable>(_ data: Data, to endpoint: APIEndpoint) async throws -> T {
        let url = baseURL.appendingPathComponent(endpoint.path)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = data
        
        // Add headers
        headers.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        let (responseData, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        guard 200...299 ~= httpResponse.statusCode else {
            throw NetworkError.serverError(httpResponse.statusCode)
        }
        
        return try JSONDecoder().decode(T.self, from: responseData)
    }
    
    func download(from endpoint: APIEndpoint) async throws -> Data {
        let url = baseURL.appendingPathComponent(endpoint.path)
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        
        // Add headers
        headers.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        guard 200...299 ~= httpResponse.statusCode else {
            throw NetworkError.serverError(httpResponse.statusCode)
        }
        
        return data
    }
}
```

### Network Error Handling

```swift
enum NetworkError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case serverError(Int)
    case noData
    case decodingError(Error)
    case encodingError(Error)
    case timeout
    case noConnection
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .serverError(let code):
            return "Server error with code: \(code)"
        case .noData:
            return "No data received"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .encodingError(let error):
            return "Failed to encode request: \(error.localizedDescription)"
        case .timeout:
            return "Request timed out"
        case .noConnection:
            return "No internet connection"
        }
    }
}
```

## Logging

### Logger

```swift
protocol Logger {
    func log(_ level: LogLevel, message: String, file: String, function: String, line: Int)
    func log(_ level: LogLevel, message: String, error: Error?, file: String, function: String, line: Int)
}

enum LogLevel: String, CaseIterable {
    case debug = "DEBUG"
    case info = "INFO"
    case warning = "WARNING"
    case error = "ERROR"
    case fatal = "FATAL"
    
    var emoji: String {
        switch self {
        case .debug: return "🔍"
        case .info: return "ℹ️"
        case .warning: return "⚠️"
        case .error: return "❌"
        case .fatal: return "💀"
        }
    }
}

class LoggerImpl: Logger {
    private let dateFormatter: DateFormatter
    private let queue: DispatchQueue
    
    init() {
        self.dateFormatter = DateFormatter()
        self.dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        self.queue = DispatchQueue(label: "com.app.logger", qos: .utility)
    }
    
    func log(_ level: LogLevel, message: String, file: String, function: String, line: Int) {
        log(level, message: message, error: nil, file: file, function: function, line: line)
    }
    
    func log(_ level: LogLevel, message: String, error: Error?, file: String, function: String, line: Int) {
        queue.async {
            let timestamp = self.dateFormatter.string(from: Date())
            let fileName = (file as NSString).lastPathComponent
            
            var logMessage = "\(level.emoji) [\(timestamp)] [\(level.rawValue)] [\(fileName):\(line)] \(function): \(message)"
            
            if let error = error {
                logMessage += " - Error: \(error.localizedDescription)"
            }
            
            #if DEBUG
            print(logMessage)
            #endif
            
            // Send to remote logging service in production
            #if !DEBUG
            self.sendToRemoteService(level: level, message: logMessage)
            #endif
        }
    }
    
    private func sendToRemoteService(level: LogLevel, message: String) {
        // Implementation for remote logging service
    }
}

// Global logger instance
let logger = LoggerImpl()

// Convenience functions
func logDebug(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
    logger.log(.debug, message: message, file: file, function: function, line: line)
}

func logInfo(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
    logger.log(.info, message: message, file: file, function: function, line: line)
}

func logWarning(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
    logger.log(.warning, message: message, file: file, function: function, line: line)
}

func logError(_ message: String, error: Error? = nil, file: String = #file, function: String = #function, line: Int = #line) {
    logger.log(.error, message: message, error: error, file: file, function: function, line: line)
}

func logFatal(_ message: String, error: Error? = nil, file: String = #file, function: String = #function, line: Int = #line) {
    logger.log(.fatal, message: message, error: error, file: file, function: function, line: line)
}
```

## Analytics

### Analytics Service

```swift
protocol AnalyticsService {
    func trackEvent(_ event: AnalyticsEvent)
    func trackScreen(_ screen: AnalyticsScreen)
    func trackUserProperty(_ property: String, value: Any)
    func setUserID(_ userID: String)
}

struct AnalyticsEvent {
    let name: String
    let parameters: [String: Any]
    let timestamp: Date
    
    init(name: String, parameters: [String: Any] = [:]) {
        self.name = name
        self.parameters = parameters
        self.timestamp = Date()
    }
}

struct AnalyticsScreen {
    let name: String
    let parameters: [String: Any]
    let timestamp: Date
    
    init(name: String, parameters: [String: Any] = [:]) {
        self.name = name
        self.parameters = parameters
        self.timestamp = Date()
    }
}

class AnalyticsServiceImpl: AnalyticsService {
    private var userID: String?
    private var userProperties: [String: Any] = [:]
    
    func trackEvent(_ event: AnalyticsEvent) {
        var eventData: [String: Any] = [
            "event_name": event.name,
            "timestamp": event.timestamp.timeIntervalSince1970,
            "parameters": event.parameters
        ]
        
        if let userID = userID {
            eventData["user_id"] = userID
        }
        
        eventData["user_properties"] = userProperties
        
        // Send to analytics service
        sendToAnalyticsService(eventData)
        
        logInfo("Analytics Event: \(event.name) with parameters: \(event.parameters)")
    }
    
    func trackScreen(_ screen: AnalyticsScreen) {
        var screenData: [String: Any] = [
            "screen_name": screen.name,
            "timestamp": screen.timestamp.timeIntervalSince1970,
            "parameters": screen.parameters
        ]
        
        if let userID = userID {
            screenData["user_id"] = userID
        }
        
        screenData["user_properties"] = userProperties
        
        // Send to analytics service
        sendToAnalyticsService(screenData)
        
        logInfo("Analytics Screen: \(screen.name) with parameters: \(screen.parameters)")
    }
    
    func trackUserProperty(_ property: String, value: Any) {
        userProperties[property] = value
        logInfo("Analytics User Property: \(property) = \(value)")
    }
    
    func setUserID(_ userID: String) {
        self.userID = userID
        logInfo("Analytics User ID set: \(userID)")
    }
    
    private func sendToAnalyticsService(_ data: [String: Any]) {
        // Implementation for sending data to analytics service
        // This could be Firebase Analytics, Mixpanel, Amplitude, etc.
    }
}

// Global analytics instance
let analytics = AnalyticsServiceImpl()

// Convenience functions
func trackEvent(_ name: String, parameters: [String: Any] = [:]) {
    let event = AnalyticsEvent(name: name, parameters: parameters)
    analytics.trackEvent(event)
}

func trackScreen(_ name: String, parameters: [String: Any] = [:]) {
    let screen = AnalyticsScreen(name: name, parameters: parameters)
    analytics.trackScreen(screen)
}
```

## Security

### Security Service

```swift
protocol SecurityService {
    func encrypt(_ data: Data) throws -> Data
    func decrypt(_ data: Data) throws -> Data
    func hash(_ data: Data) throws -> String
    func verifyHash(_ data: Data, hash: String) throws -> Bool
    func generateSecureRandomBytes(count: Int) throws -> Data
}

class SecurityServiceImpl: SecurityService {
    private let keychain = KeychainService()
    
    func encrypt(_ data: Data) throws -> Data {
        let key = try getEncryptionKey()
        let algorithm = SecKeyAlgorithm.rsaEncryptionOAEPSHA256
        
        guard let publicKey = try? keychain.getPublicKey() else {
            throw SecurityError.keyNotFound
        }
        
        var error: Unmanaged<CFError>?
        guard let encryptedData = SecKeyCreateEncryptedData(publicKey, algorithm, data as CFData, &error) as Data? else {
            throw SecurityError.encryptionFailed(error?.takeRetainedValue())
        }
        
        return encryptedData
    }
    
    func decrypt(_ data: Data) throws -> Data {
        let key = try getEncryptionKey()
        let algorithm = SecKeyAlgorithm.rsaEncryptionOAEPSHA256
        
        guard let privateKey = try? keychain.getPrivateKey() else {
            throw SecurityError.keyNotFound
        }
        
        var error: Unmanaged<CFError>?
        guard let decryptedData = SecKeyCreateDecryptedData(privateKey, algorithm, data as CFData, &error) as Data? else {
            throw SecurityError.decryptionFailed(error?.takeRetainedValue())
        }
        
        return decryptedData
    }
    
    func hash(_ data: Data) throws -> String {
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        data.withUnsafeBytes { buffer in
            _ = CC_SHA256(buffer.baseAddress, CC_LONG(data.count), &hash)
        }
        return hash.map { String(format: "%02x", $0) }.joined()
    }
    
    func verifyHash(_ data: Data, hash: String) throws -> Bool {
        let calculatedHash = try self.hash(data)
        return calculatedHash == hash
    }
    
    func generateSecureRandomBytes(count: Int) throws -> Data {
        var bytes = [UInt8](repeating: 0, count: count)
        let status = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
        
        guard status == errSecSuccess else {
            throw SecurityError.randomGenerationFailed
        }
        
        return Data(bytes)
    }
    
    private func getEncryptionKey() throws -> SecKey {
        // Implementation for getting encryption key
        throw SecurityError.keyNotFound
    }
}

enum SecurityError: Error, LocalizedError {
    case keyNotFound
    case encryptionFailed(Error?)
    case decryptionFailed(Error?)
    case randomGenerationFailed
    case invalidKey
    
    var errorDescription: String? {
        switch self {
        case .keyNotFound:
            return "Encryption key not found"
        case .encryptionFailed(let error):
            return "Encryption failed: \(error?.localizedDescription ?? "Unknown error")"
        case .decryptionFailed(let error):
            return "Decryption failed: \(error?.localizedDescription ?? "Unknown error")"
        case .randomGenerationFailed:
            return "Failed to generate secure random bytes"
        case .invalidKey:
            return "Invalid encryption key"
        }
    }
}
```

## Keychain Service

```swift
class KeychainService {
    private let service = "com.app.keychain"
    
    func save(_ data: Data, forKey key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        if status == errSecDuplicateItem {
            // Item already exists, update it
            let updateQuery: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: service,
                kSecAttrAccount as String: key
            ]
            
            let updateAttributes: [String: Any] = [
                kSecValueData as String: data
            ]
            
            let updateStatus = SecItemUpdate(updateQuery as CFDictionary, updateAttributes as CFDictionary)
            
            guard updateStatus == errSecSuccess else {
                throw KeychainError.saveFailed(updateStatus)
            }
        } else if status != errSecSuccess {
            throw KeychainError.saveFailed(status)
        }
    }
    
    func load(forKey key: String) throws -> Data {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess else {
            throw KeychainError.loadFailed(status)
        }
        
        guard let data = result as? Data else {
            throw KeychainError.invalidData
        }
        
        return data
    }
    
    func delete(forKey key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.deleteFailed(status)
        }
    }
    
    func getPublicKey() throws -> SecKey {
        // Implementation for getting public key from keychain
        throw KeychainError.keyNotFound
    }
    
    func getPrivateKey() throws -> SecKey {
        // Implementation for getting private key from keychain
        throw KeychainError.keyNotFound
    }
}

enum KeychainError: Error, LocalizedError {
    case saveFailed(OSStatus)
    case loadFailed(OSStatus)
    case deleteFailed(OSStatus)
    case keyNotFound
    case invalidData
    
    var errorDescription: String? {
        switch self {
        case .saveFailed(let status):
            return "Failed to save to keychain: \(status)"
        case .loadFailed(let status):
            return "Failed to load from keychain: \(status)"
        case .deleteFailed(let status):
            return "Failed to delete from keychain: \(status)"
        case .keyNotFound:
            return "Key not found in keychain"
        case .invalidData:
            return "Invalid data in keychain"
        }
    }
}
```

## Testing

### Infrastructure Tests

```swift
class NetworkClientTests: XCTestCase {
    var networkClient: NetworkClient!
    var mockSession: MockURLSession!
    
    override func setUp() {
        super.setUp()
        mockSession = MockURLSession()
        networkClient = NetworkClientImpl(
            session: mockSession,
            baseURL: URL(string: "https://api.example.com")!
        )
    }
    
    func testRequestSuccess() async throws {
        // Given
        let expectedData = User(id: UUID(), email: "test@example.com", name: "Test User")
        let responseData = try JSONEncoder().encode(expectedData)
        mockSession.mockData = responseData
        mockSession.mockResponse = HTTPURLResponse(
            url: URL(string: "https://api.example.com/users/1")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )
        
        // When
        let result: User = try await networkClient.request(.user(id: UUID()))
        
        // Then
        XCTAssertEqual(result.id, expectedData.id)
        XCTAssertEqual(result.email, expectedData.email)
    }
    
    func testRequestFailure() async throws {
        // Given
        mockSession.mockResponse = HTTPURLResponse(
            url: URL(string: "https://api.example.com/users/1")!,
            statusCode: 404,
            httpVersion: nil,
            headerFields: nil
        )
        
        // When & Then
        do {
            let _: User = try await networkClient.request(.user(id: UUID()))
            XCTFail("Expected error but got success")
        } catch NetworkError.serverError(let code) {
            XCTAssertEqual(code, 404)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}
```

## Best Practices

1. **Dependency Injection**: Inject infrastructure dependencies
2. **Error Handling**: Provide specific error types for each service
3. **Logging**: Log all infrastructure operations for debugging
4. **Security**: Use secure methods for sensitive data
5. **Testing**: Mock external services for comprehensive testing
6. **Configuration**: Make infrastructure configurable for different environments 