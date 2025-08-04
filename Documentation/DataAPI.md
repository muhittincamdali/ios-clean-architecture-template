# Data Layer API

## Overview

The Data Layer is responsible for data access and persistence. It implements the repository pattern and provides data sources for the domain layer.

## Data Sources

### Remote Data Source

```swift
protocol RemoteDataSource {
    func fetch<T: Codable>(_ endpoint: APIEndpoint) async throws -> T
    func post<T: Codable, R: Codable>(_ endpoint: APIEndpoint, data: T) async throws -> R
    func put<T: Codable, R: Codable>(_ endpoint: APIEndpoint, data: T) async throws -> R
    func delete(_ endpoint: APIEndpoint) async throws
}
```

### Local Data Source

```swift
protocol LocalDataSource {
    func save<T: Codable>(_ data: T, forKey key: String) async throws
    func load<T: Codable>(_ type: T.Type, forKey key: String) async throws -> T?
    func delete(forKey key: String) async throws
    func clear() async throws
}
```

## Repository Implementations

### User Repository Implementation

```swift
class UserRepositoryImpl: UserRepository {
    private let remoteDataSource: RemoteDataSource
    private let localDataSource: LocalDataSource
    
    init(remoteDataSource: RemoteDataSource, localDataSource: LocalDataSource) {
        self.remoteDataSource = remoteDataSource
        self.localDataSource = localDataSource
    }
    
    func fetchUser(id: UUID) async throws -> User {
        // Try local first
        if let cachedUser: User = try await localDataSource.load(User.self, forKey: "user_\(id)") {
            return cachedUser
        }
        
        // Fetch from remote
        let user: User = try await remoteDataSource.fetch(.user(id: id))
        
        // Cache locally
        try await localDataSource.save(user, forKey: "user_\(id)")
        
        return user
    }
    
    func saveUser(_ user: User) async throws {
        // Save to remote
        let savedUser: User = try await remoteDataSource.put(.user(id: user.id), data: user)
        
        // Update local cache
        try await localDataSource.save(savedUser, forKey: "user_\(user.id)")
    }
    
    func deleteUser(id: UUID) async throws {
        // Delete from remote
        try await remoteDataSource.delete(.user(id: id))
        
        // Remove from local cache
        try await localDataSource.delete(forKey: "user_\(id)")
    }
    
    func searchUsers(query: String) async throws -> [User] {
        let users: [User] = try await remoteDataSource.fetch(.searchUsers(query: query))
        return users
    }
}
```

### Product Repository Implementation

```swift
class ProductRepositoryImpl: ProductRepository {
    private let remoteDataSource: RemoteDataSource
    private let localDataSource: LocalDataSource
    
    init(remoteDataSource: RemoteDataSource, localDataSource: LocalDataSource) {
        self.remoteDataSource = remoteDataSource
        self.localDataSource = localDataSource
    }
    
    func fetchProduct(id: UUID) async throws -> Product {
        // Try local first
        if let cachedProduct: Product = try await localDataSource.load(Product.self, forKey: "product_\(id)") {
            return cachedProduct
        }
        
        // Fetch from remote
        let product: Product = try await remoteDataSource.fetch(.product(id: id))
        
        // Cache locally
        try await localDataSource.save(product, forKey: "product_\(id)")
        
        return product
    }
    
    func fetchProducts(category: ProductCategory?) async throws -> [Product] {
        let products: [Product] = try await remoteDataSource.fetch(.products(category: category))
        return products
    }
    
    func saveProduct(_ product: Product) async throws {
        // Save to remote
        let savedProduct: Product = try await remoteDataSource.put(.product(id: product.id), data: product)
        
        // Update local cache
        try await localDataSource.save(savedProduct, forKey: "product_\(product.id)")
    }
    
    func deleteProduct(id: UUID) async throws {
        // Delete from remote
        try await remoteDataSource.delete(.product(id: id))
        
        // Remove from local cache
        try await localDataSource.delete(forKey: "product_\(id)")
    }
}
```

## API Endpoints

### Endpoint Definition

```swift
enum APIEndpoint {
    case user(id: UUID)
    case searchUsers(query: String)
    case product(id: UUID)
    case products(category: ProductCategory?)
    
    var path: String {
        switch self {
        case .user(let id):
            return "/users/\(id)"
        case .searchUsers(let query):
            return "/users/search?q=\(query)"
        case .product(let id):
            return "/products/\(id)"
        case .products(let category):
            if let category = category {
                return "/products?category=\(category.rawValue)"
            } else {
                return "/products"
            }
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .user, .searchUsers, .product, .products:
            return .GET
        }
    }
}
```

## Data Models

### API Response Models

```swift
struct APIResponse<T: Codable>: Codable {
    let data: T
    let message: String?
    let success: Bool
}

struct PaginatedResponse<T: Codable>: Codable {
    let data: [T]
    let pagination: Pagination
    let message: String?
    let success: Bool
}

struct Pagination: Codable {
    let page: Int
    let limit: Int
    let total: Int
    let totalPages: Int
}
```

## Error Handling

### Data Layer Errors

```swift
enum DataError: Error, LocalizedError {
    case networkError(Error)
    case decodingError(Error)
    case encodingError(Error)
    case cacheError(Error)
    case serverError(Int)
    case noData
    
    var errorDescription: String? {
        switch self {
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .decodingError(let error):
            return "Data decoding error: \(error.localizedDescription)"
        case .encodingError(let error):
            return "Data encoding error: \(error.localizedDescription)"
        case .cacheError(let error):
            return "Cache error: \(error.localizedDescription)"
        case .serverError(let code):
            return "Server error with code: \(code)"
        case .noData:
            return "No data available"
        }
    }
}
```

## Caching Strategy

### Cache Implementation

```swift
class CacheManager {
    private let cache = NSCache<NSString, AnyObject>()
    private let fileManager = FileManager.default
    private let cacheDirectory: URL
    
    init() {
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        cacheDirectory = documentsPath.appendingPathComponent("Cache")
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }
    
    func save<T: Codable>(_ object: T, forKey key: String) async throws {
        let data = try JSONEncoder().encode(object)
        let fileURL = cacheDirectory.appendingPathComponent("\(key).json")
        try data.write(to: fileURL)
        cache.setObject(data as AnyObject, forKey: key as NSString)
    }
    
    func load<T: Codable>(_ type: T.Type, forKey key: String) async throws -> T? {
        // Check memory cache first
        if let cachedData = cache.object(forKey: key as NSString) as? Data {
            return try JSONDecoder().decode(type, from: cachedData)
        }
        
        // Check file cache
        let fileURL = cacheDirectory.appendingPathComponent("\(key).json")
        guard fileManager.fileExists(atPath: fileURL.path) else { return nil }
        
        let data = try Data(contentsOf: fileURL)
        let object = try JSONDecoder().decode(type, from: data)
        
        // Update memory cache
        cache.setObject(data as AnyObject, forKey: key as NSString)
        
        return object
    }
    
    func delete(forKey key: String) async throws {
        cache.removeObject(forKey: key as NSString)
        let fileURL = cacheDirectory.appendingPathComponent("\(key).json")
        try? fileManager.removeItem(at: fileURL)
    }
    
    func clear() async throws {
        cache.removeAllObjects()
        let contents = try fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: nil)
        for fileURL in contents {
            try fileManager.removeItem(at: fileURL)
        }
    }
}
```

## Testing

### Repository Tests

```swift
class UserRepositoryTests: XCTestCase {
    var userRepository: UserRepository!
    var mockRemoteDataSource: MockRemoteDataSource!
    var mockLocalDataSource: MockLocalDataSource!
    
    override func setUp() {
        super.setUp()
        mockRemoteDataSource = MockRemoteDataSource()
        mockLocalDataSource = MockLocalDataSource()
        userRepository = UserRepositoryImpl(
            remoteDataSource: mockRemoteDataSource,
            localDataSource: mockLocalDataSource
        )
    }
    
    func testFetchUserFromCache() async throws {
        // Given
        let expectedUser = User(id: UUID(), email: "test@example.com", name: "Test User")
        mockLocalDataSource.mockUser = expectedUser
        
        // When
        let result = try await userRepository.fetchUser(id: expectedUser.id)
        
        // Then
        XCTAssertEqual(result.id, expectedUser.id)
        XCTAssertEqual(result.email, expectedUser.email)
        XCTAssertFalse(mockRemoteDataSource.fetchCalled)
    }
    
    func testFetchUserFromRemote() async throws {
        // Given
        let expectedUser = User(id: UUID(), email: "test@example.com", name: "Test User")
        mockRemoteDataSource.mockUser = expectedUser
        
        // When
        let result = try await userRepository.fetchUser(id: expectedUser.id)
        
        // Then
        XCTAssertEqual(result.id, expectedUser.id)
        XCTAssertEqual(result.email, expectedUser.email)
        XCTAssertTrue(mockRemoteDataSource.fetchCalled)
    }
}
```

## Best Practices

1. **Repository Pattern**: Implement repositories to abstract data sources
2. **Caching Strategy**: Use memory and disk caching for better performance
3. **Error Handling**: Define specific error types for data layer
4. **Testing**: Mock data sources for comprehensive testing
5. **Offline Support**: Handle offline scenarios gracefully
6. **Data Validation**: Validate data before caching or processing 