# Domain Layer API

## Overview

The Domain Layer is the core of the Clean Architecture, containing business logic, entities, and use cases. This layer is independent of external frameworks and libraries.

## Entities

### User Entity

```swift
struct User: Codable, Identifiable {
    let id: UUID
    let email: String
    let name: String
    let profileImage: String?
    let createdAt: Date
    let updatedAt: Date
}
```

### Product Entity

```swift
struct Product: Codable, Identifiable {
    let id: UUID
    let name: String
    let description: String
    let price: Decimal
    let category: ProductCategory
    let images: [String]
    let isAvailable: Bool
    let createdAt: Date
    let updatedAt: Date
}
```

## Use Cases

### User Management Use Cases

```swift
protocol UserUseCase {
    func getUser(id: UUID) async throws -> User
    func updateUser(_ user: User) async throws -> User
    func deleteUser(id: UUID) async throws
    func searchUsers(query: String) async throws -> [User]
}
```

### Product Management Use Cases

```swift
protocol ProductUseCase {
    func getProduct(id: UUID) async throws -> Product
    func getProducts(category: ProductCategory?) async throws -> [Product]
    func createProduct(_ product: Product) async throws -> Product
    func updateProduct(_ product: Product) async throws -> Product
    func deleteProduct(id: UUID) async throws
}
```

## Repositories

### User Repository

```swift
protocol UserRepository {
    func fetchUser(id: UUID) async throws -> User
    func saveUser(_ user: User) async throws
    func deleteUser(id: UUID) async throws
    func searchUsers(query: String) async throws -> [User]
}
```

### Product Repository

```swift
protocol ProductRepository {
    func fetchProduct(id: UUID) async throws -> Product
    func fetchProducts(category: ProductCategory?) async throws -> [Product]
    func saveProduct(_ product: Product) async throws
    func deleteProduct(id: UUID) async throws
}
```

## Business Rules

### Validation Rules

```swift
struct UserValidationRules {
    static func validateEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    static func validatePassword(_ password: String) -> Bool {
        return password.count >= 8
    }
}
```

### Business Logic

```swift
struct ProductBusinessRules {
    static func calculateDiscount(price: Decimal, discountPercentage: Decimal) -> Decimal {
        return price * (1 - discountPercentage / 100)
    }
    
    static func isProductAvailable(_ product: Product) -> Bool {
        return product.isAvailable && product.price > 0
    }
}
```

## Error Handling

### Domain Errors

```swift
enum DomainError: Error, LocalizedError {
    case userNotFound
    case productNotFound
    case invalidEmail
    case invalidPassword
    case networkError
    case serverError
    
    var errorDescription: String? {
        switch self {
        case .userNotFound:
            return "User not found"
        case .productNotFound:
            return "Product not found"
        case .invalidEmail:
            return "Invalid email format"
        case .invalidPassword:
            return "Password must be at least 8 characters"
        case .networkError:
            return "Network connection error"
        case .serverError:
            return "Server error occurred"
        }
    }
}
```

## Testing

### Unit Tests

```swift
class UserUseCaseTests: XCTestCase {
    var userUseCase: UserUseCase!
    var mockRepository: MockUserRepository!
    
    override func setUp() {
        super.setUp()
        mockRepository = MockUserRepository()
        userUseCase = UserUseCaseImpl(repository: mockRepository)
    }
    
    func testGetUserSuccess() async throws {
        // Given
        let expectedUser = User(id: UUID(), email: "test@example.com", name: "Test User")
        mockRepository.mockUser = expectedUser
        
        // When
        let result = try await userUseCase.getUser(id: expectedUser.id)
        
        // Then
        XCTAssertEqual(result.id, expectedUser.id)
        XCTAssertEqual(result.email, expectedUser.email)
    }
}
```

## Best Practices

1. **Keep Domain Layer Pure**: No dependencies on external frameworks
2. **Use Protocols**: Define contracts with protocols
3. **Immutable Entities**: Make entities immutable when possible
4. **Business Rules**: Centralize business logic in the domain layer
5. **Error Handling**: Define domain-specific errors
6. **Testing**: Write comprehensive unit tests for all business logic 