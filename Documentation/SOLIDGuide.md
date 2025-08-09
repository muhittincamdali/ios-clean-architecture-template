# SOLID Principles Guide

<!-- TOC START -->
## Table of Contents
- [SOLID Principles Guide](#solid-principles-guide)
- [Overview](#overview)
- [Single Responsibility Principle (SRP)](#single-responsibility-principle-srp)
- [Open/Closed Principle (OCP)](#openclosed-principle-ocp)
- [Liskov Substitution Principle (LSP)](#liskov-substitution-principle-lsp)
- [Interface Segregation Principle (ISP)](#interface-segregation-principle-isp)
- [Dependency Inversion Principle (DIP)](#dependency-inversion-principle-dip)
- [SOLID in Clean Architecture](#solid-in-clean-architecture)
  - [Domain Layer](#domain-layer)
  - [Data Layer](#data-layer)
  - [Presentation Layer](#presentation-layer)
- [Testing SOLID Principles](#testing-solid-principles)
- [Best Practices](#best-practices)
- [Conclusion](#conclusion)
<!-- TOC END -->


## Overview

This guide demonstrates how to implement SOLID principles in iOS development using Clean Architecture.

## Single Responsibility Principle (SRP)

A class should have only one reason to change.

```swift
// ❌ Bad: Multiple responsibilities
class UserManager {
    func createUser(_ user: User) { }
    func validateEmail(_ email: String) -> Bool { }
    func sendEmail(_ email: String) { }
}

// ✅ Good: Single responsibility
class UserRepository {
    func createUser(_ user: User) async throws -> User
}

class EmailValidator {
    func validateEmail(_ email: String) -> Bool
}

class EmailService {
    func sendEmail(_ email: String) async throws
}
```

## Open/Closed Principle (OCP)

Software entities should be open for extension but closed for modification.

```swift
protocol PaymentProcessor {
    func processPayment(_ amount: Double) async throws
}

class CreditCardProcessor: PaymentProcessor {
    func processPayment(_ amount: Double) async throws { }
}

class PayPalProcessor: PaymentProcessor {
    func processPayment(_ amount: Double) async throws { }
}

// New payment methods can be added without modifying existing code
class ApplePayProcessor: PaymentProcessor {
    func processPayment(_ amount: Double) async throws { }
}
```

## Liskov Substitution Principle (LSP)

Derived classes must be substitutable for their base classes.

```swift
protocol Flyable {
    func fly()
}

protocol Swimmable {
    func swim()
}

class Sparrow: Flyable, Swimmable {
    func fly() { }
    func swim() { }
}

class Penguin: Swimmable {
    func swim() { }
}
```

## Interface Segregation Principle (ISP)

Clients should not be forced to depend on interfaces they don't use.

```swift
// ✅ Good: Segregated interfaces
protocol Workable {
    func work()
}

protocol Eatable {
    func eat()
}

class Human: Workable, Eatable {
    func work() { }
    func eat() { }
}

class Robot: Workable {
    func work() { }
}
```

## Dependency Inversion Principle (DIP)

High-level modules should not depend on low-level modules. Both should depend on abstractions.

```swift
protocol UserRepository {
    func save(_ user: User) async throws -> User
}

class UserService {
    private let repository: UserRepository
    
    init(repository: UserRepository) {
        self.repository = repository
    }
    
    func createUser(_ user: User) async throws {
        try await repository.save(user)
    }
}

class MySQLUserRepository: UserRepository {
    func save(_ user: User) async throws -> User { }
}

class CoreDataUserRepository: UserRepository {
    func save(_ user: User) async throws -> User { }
}
```

## SOLID in Clean Architecture

### Domain Layer

```swift
protocol UserUseCase {
    func createUser(_ user: User) async throws -> User
}

class CreateUserUseCase: UserUseCase {
    private let repository: UserRepository
    
    init(repository: UserRepository) {
        self.repository = repository
    }
    
    func createUser(_ user: User) async throws -> User {
        return try await repository.save(user)
    }
}
```

### Data Layer

```swift
class UserRepositoryImpl: UserRepository {
    private let remoteDataSource: UserRemoteDataSource
    private let localDataSource: UserLocalDataSource
    
    init(remoteDataSource: UserRemoteDataSource, localDataSource: UserLocalDataSource) {
        self.remoteDataSource = remoteDataSource
        self.localDataSource = localDataSource
    }
    
    func save(_ user: User) async throws -> User {
        let savedUser = try await localDataSource.save(user)
        return try await remoteDataSource.save(savedUser)
    }
}
```

### Presentation Layer

```swift
class UserListViewModel: ObservableObject {
    @Published var users: [User] = []
    private let userUseCase: UserUseCase
    
    init(userUseCase: UserUseCase) {
        self.userUseCase = userUseCase
    }
    
    func loadUsers() async {
        // Implementation
    }
}
```

## Testing SOLID Principles

```swift
class UserUseCaseTests: XCTestCase {
    var userUseCase: CreateUserUseCase!
    var mockRepository: MockUserRepository!
    
    override func setUp() {
        super.setUp()
        mockRepository = MockUserRepository()
        userUseCase = CreateUserUseCase(repository: mockRepository)
    }
    
    func testCreateUserSuccess() async throws {
        let user = User(id: UUID(), email: "test@example.com", name: "Test User", createdAt: Date())
        mockRepository.mockUser = user
        
        let result = try await userUseCase.createUser(user)
        
        XCTAssertEqual(result.email, user.email)
        XCTAssertTrue(mockRepository.saveCalled)
    }
}
```

## Best Practices

1. **Start with Interfaces**: Define protocols first
2. **Use Dependency Injection**: Inject dependencies through constructors
3. **Keep Classes Small**: Each class should have a single responsibility
4. **Use Composition Over Inheritance**: Prefer composition for flexibility
5. **Write Tests First**: TDD helps enforce SOLID principles

## Conclusion

SOLID principles create maintainable, scalable, and testable iOS applications by promoting:
- Single responsibility for each class
- Open for extension, closed for modification
- Liskov substitution for type safety
- Interface segregation for focused APIs
- Dependency inversion for flexibility
