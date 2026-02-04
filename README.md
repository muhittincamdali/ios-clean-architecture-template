# iOS Clean Architecture Template

<p align="center">
  <a href="README.md">🇺🇸 English</a> |
  <a href="README_TR.md">🇹🇷 Türkçe</a>
</p>


```
   _____ _      ______          _   _            _____   _____ _    _ _____ _______ ______ _____ _______ _    _ _____  ______ 
  / ____| |    |  ____|   /\   | \ | |     /\   |  __ \ / ____| |  | |_   _|__   __|  ____/ ____|__   __| |  | |  __ \|  ____|
 | |    | |    | |__     /  \  |  \| |    /  \  | |__) | |    | |__| | | |    | |  | |__ | |       | |  | |  | | |__) | |__   
 | |    | |    |  __|   / /\ \ | . ` |   / /\ \ |  _  /| |    |  __  | | |    | |  |  __|| |       | |  | |  | |  _  /|  __|  
 | |____| |____| |____ / ____ \| |\  |  / ____ \| | \ \| |____| |  | |_| |_   | |  | |___| |____   | |  | |__| | | \ \| |____ 
  \_____|______|______/_/    \_\_| \_| /_/    \_\_|  \_\\_____|_|  |_|_____|  |_|  |______\_____|  |_|   \____/|_|  \_\______|
```

<p align="center">
  <strong>Production-ready iOS architecture template implementing Uncle Bob's Clean Architecture principles</strong>
</p>

<p align="center">
  <a href="https://swift.org"><img src="https://img.shields.io/badge/Swift-5.9+-F05138?style=for-the-badge&logo=swift&logoColor=white" alt="Swift"></a>
  <a href="https://developer.apple.com/ios/"><img src="https://img.shields.io/badge/iOS-15.0+-000000?style=for-the-badge&logo=apple&logoColor=white" alt="iOS"></a>
  <a href="https://developer.apple.com/xcode/"><img src="https://img.shields.io/badge/Xcode-15+-147EFB?style=for-the-badge&logo=xcode&logoColor=white" alt="Xcode"></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-green?style=for-the-badge" alt="License"></a>
</p>

<p align="center">
  <a href="https://github.com/muhittincamdali/ios-clean-architecture-template/actions"><img src="https://img.shields.io/github/actions/workflow/status/muhittincamdali/ios-clean-architecture-template/ci.yml?branch=main&style=flat-square&label=CI" alt="CI"></a>
  <a href="https://github.com/muhittincamdali/ios-clean-architecture-template/stargazers"><img src="https://img.shields.io/github/stars/muhittincamdali/ios-clean-architecture-template?style=flat-square" alt="Stars"></a>
  <a href="https://github.com/muhittincamdali/ios-clean-architecture-template/issues"><img src="https://img.shields.io/github/issues/muhittincamdali/ios-clean-architecture-template?style=flat-square" alt="Issues"></a>
  <a href="https://swiftpackageindex.com/muhittincamdali/ios-clean-architecture-template"><img src="https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fmuhittincamdali%2Fios-clean-architecture-template%2Fbadge%3Ftype%3Dplatforms&style=flat-square" alt="Platforms"></a>
</p>

---

## Overview

A battle-tested iOS project template that enforces strict separation of concerns through Clean Architecture layers. Built with **SOLID principles**, **Protocol-Oriented Programming**, and **modern Swift concurrency**. Perfect for scalable apps that need to evolve with changing requirements.

### Why This Template?

| Problem | Solution |
|---------|----------|
| Spaghetti code in ViewControllers | Strict layer separation |
| Untestable business logic | Protocol-based dependencies |
| Hard to swap frameworks | Framework-agnostic Domain layer |
| Difficult onboarding | Consistent, documented structure |
| Breaking changes cascade | Dependency Rule enforcement |

---

## Architecture Diagram

```mermaid
graph TB
    subgraph Presentation["🎨 Presentation Layer"]
        V[Views<br/>SwiftUI/UIKit]
        VM[ViewModels<br/>@Observable]
        C[Coordinators<br/>Navigation]
    end

    subgraph Domain["⚙️ Domain Layer"]
        UC[Use Cases<br/>Business Logic]
        E[Entities<br/>Business Models]
        RP[Repository<br/>Protocols]
    end

    subgraph Data["💾 Data Layer"]
        R[Repositories<br/>Implementation]
        RDS[Remote<br/>Data Source]
        LDS[Local<br/>Data Source]
    end

    subgraph Infrastructure["🔧 Infrastructure Layer"]
        DI[Dependency<br/>Injection]
        NET[Network<br/>Client]
        DB[Database<br/>CoreData]
        CACHE[Cache<br/>Manager]
    end

    V --> VM
    VM --> UC
    C --> VM
    UC --> E
    UC --> RP
    R -.implements.-> RP
    R --> RDS
    R --> LDS
    RDS --> NET
    LDS --> DB
    LDS --> CACHE
    DI -.configures.-> R
    DI -.configures.-> UC

    style Presentation fill:#a8d5ba,stroke:#2d6a4f
    style Domain fill:#ffd6a5,stroke:#e85d04
    style Data fill:#bde0fe,stroke:#0077b6
    style Infrastructure fill:#e5e5e5,stroke:#6c757d
```

### The Dependency Rule

> **Dependencies point inward.** Nothing in an inner circle can know anything about something in an outer circle.

```
┌─────────────────────────────────────────────────────────────┐
│                    Infrastructure                            │
│  ┌───────────────────────────────────────────────────────┐  │
│  │                      Data                              │  │
│  │  ┌─────────────────────────────────────────────────┐  │  │
│  │  │                  Presentation                    │  │  │
│  │  │  ┌───────────────────────────────────────────┐  │  │  │
│  │  │  │                  Domain                    │  │  │  │
│  │  │  │              (Business Logic)              │  │  │  │
│  │  │  │                                           │  │  │  │
│  │  │  │         Entities + Use Cases              │  │  │  │
│  │  │  └───────────────────────────────────────────┘  │  │  │
│  │  └─────────────────────────────────────────────────┘  │  │
│  └───────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

---

## Layer Responsibilities

| Layer | Purpose | Contains | Depends On |
|-------|---------|----------|------------|
| **🎨 Presentation** | UI & User Interaction | Views, ViewModels, Coordinators | Domain |
| **⚙️ Domain** | Business Rules | Entities, Use Cases, Repository Protocols | Nothing |
| **💾 Data** | Data Operations | Repository Implementations, DTOs, Data Sources | Domain |
| **🔧 Infrastructure** | Technical Concerns | DI, Networking, Database, Cache, Logging | All Layers |

### Layer Details

<details>
<summary><strong>🎨 Presentation Layer</strong></summary>

Handles everything the user sees and interacts with.

- **Views**: SwiftUI views or UIKit view controllers
- **ViewModels**: Presentation logic, state management
- **Coordinators**: Navigation flow between screens

```swift
@MainActor
final class UserListViewModel: ObservableObject {
    @Published private(set) var users: [User] = []
    @Published private(set) var isLoading = false
    
    private let getUsersUseCase: GetUsersUseCaseProtocol
    
    func loadUsers() async {
        isLoading = true
        defer { isLoading = false }
        users = (try? await getUsersUseCase.execute()) ?? []
    }
}
```

</details>

<details>
<summary><strong>⚙️ Domain Layer</strong></summary>

The heart of your application - pure business logic with zero framework dependencies.

- **Entities**: Core business objects
- **Use Cases**: Application-specific business rules
- **Repository Protocols**: Abstract data access

```swift
// Entity - Pure Swift, no imports needed
struct User: Identifiable, Equatable {
    let id: UUID
    let name: String
    let email: String
}

// Use Case - Single responsibility
final class GetUserUseCase: GetUserUseCaseProtocol {
    private let repository: UserRepositoryProtocol
    
    func execute(id: UUID) async throws -> User {
        try await repository.fetchUser(id: id)
    }
}
```

</details>

<details>
<summary><strong>💾 Data Layer</strong></summary>

Implements the repository protocols defined in Domain, handling actual data operations.

- **Repositories**: Coordinate between data sources
- **Data Sources**: Remote (API) and Local (DB/Cache)
- **DTOs**: Data Transfer Objects for mapping

```swift
final class UserRepository: UserRepositoryProtocol {
    private let remote: UserRemoteDataSourceProtocol
    private let local: UserLocalDataSourceProtocol
    
    func fetchUser(id: UUID) async throws -> User {
        if let cached = try? await local.getUser(id: id) {
            return cached.toDomain()
        }
        let dto = try await remote.fetchUser(id: id)
        try await local.saveUser(dto)
        return dto.toDomain()
    }
}
```

</details>

<details>
<summary><strong>🔧 Infrastructure Layer</strong></summary>

Cross-cutting concerns and framework integrations.

- **Dependency Injection**: Wire up all dependencies
- **Networking**: HTTP client, API configuration
- **Persistence**: CoreData, UserDefaults, Keychain
- **Services**: Analytics, Crash Reporting, Logging

</details>

---

## Project Structure

```
ios-clean-architecture-template/
│
├── Sources/
│   │
│   ├── Domain/                          # ⚙️ Business Logic (Framework-Free)
│   │   ├── Entities/
│   │   │   └── User.swift               # Core business objects
│   │   ├── UseCases/
│   │   │   ├── GetUserUseCase.swift     # Single-purpose operations
│   │   │   └── GetUsersUseCase.swift
│   │   ├── Protocols/
│   │   │   ├── UserRepositoryProtocol.swift
│   │   │   ├── GetUserUseCaseProtocol.swift
│   │   │   └── GetUsersUseCaseProtocol.swift
│   │   └── Validators/
│   │       └── UserValidator.swift
│   │
│   ├── Data/                            # 💾 Data Access
│   │   ├── Repositories/
│   │   │   └── UserRepository.swift     # Protocol implementations
│   │   ├── DataSources/
│   │   │   ├── Remote/
│   │   │   │   ├── APIService.swift
│   │   │   │   └── UserRemoteDataSource.swift
│   │   │   └── Local/
│   │   │       ├── CoreDataManager.swift
│   │   │       └── UserLocalDataSource.swift
│   │   ├── Models/
│   │   │   └── UserDTO.swift            # Data Transfer Objects
│   │   └── Protocols/
│   │       ├── UserRemoteDataSourceProtocol.swift
│   │       └── UserLocalDataSourceProtocol.swift
│   │
│   ├── Presentation/                    # 🎨 UI Layer
│   │   ├── Views/
│   │   │   ├── UserView.swift
│   │   │   └── UserListView.swift
│   │   ├── ViewModels/
│   │   │   ├── UserViewModel.swift
│   │   │   └── UserListViewModel.swift
│   │   └── Components/
│   │       └── CustomButton.swift
│   │
│   ├── Infrastructure/                  # 🔧 Technical Concerns
│   │   ├── DI/
│   │   │   └── DependencyContainer.swift
│   │   ├── Network/
│   │   │   └── NetworkMonitor.swift
│   │   ├── Security/
│   │   │   └── SecureStorage.swift
│   │   ├── Cache/
│   │   │   └── CacheManager.swift
│   │   ├── Analytics/
│   │   │   └── AnalyticsService.swift
│   │   └── Protocols/
│   │       └── *.swift
│   │
│   └── Core/
│       └── MainFramework.swift
│
├── Tests/
│   ├── UnitTests/
│   │   ├── GetUserUseCaseTests.swift
│   │   └── UserUseCaseTests.swift
│   ├── IntegrationTests/
│   │   └── UserRepositoryIntegrationTests.swift
│   └── UITests/
│       └── UserListViewUITests.swift
│
├── Examples/
│   ├── BasicExample.swift
│   ├── AdvancedExample.swift
│   └── EnterpriseExample.swift
│
└── Documentation/
    └── *.md
```

---

## Getting Started

### Installation

**Swift Package Manager**

```swift
dependencies: [
    .package(
        url: "https://github.com/muhittincamdali/ios-clean-architecture-template.git",
        from: "1.0.0"
    )
]
```

**Clone as Starter**

```bash
git clone https://github.com/muhittincamdali/ios-clean-architecture-template.git MyApp
cd MyApp
rm -rf .git && git init
```

### Quick Start Guide

#### Step 1: Define Your Entity

```swift
// Sources/Domain/Entities/Product.swift
struct Product: Identifiable, Equatable, Sendable {
    let id: UUID
    let name: String
    let price: Decimal
    let category: Category
    
    enum Category: String, Sendable {
        case electronics, clothing, food
    }
}
```

#### Step 2: Create Repository Protocol

```swift
// Sources/Domain/Protocols/ProductRepositoryProtocol.swift
protocol ProductRepositoryProtocol: Sendable {
    func fetchAll() async throws -> [Product]
    func fetch(id: UUID) async throws -> Product
    func save(_ product: Product) async throws
    func delete(id: UUID) async throws
}
```

#### Step 3: Implement Use Case

```swift
// Sources/Domain/UseCases/GetProductsUseCase.swift
protocol GetProductsUseCaseProtocol: Sendable {
    func execute() async throws -> [Product]
    func execute(category: Product.Category) async throws -> [Product]
}

final class GetProductsUseCase: GetProductsUseCaseProtocol {
    private let repository: ProductRepositoryProtocol
    
    init(repository: ProductRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute() async throws -> [Product] {
        try await repository.fetchAll()
    }
    
    func execute(category: Product.Category) async throws -> [Product] {
        try await repository.fetchAll().filter { $0.category == category }
    }
}
```

#### Step 4: Implement Repository

```swift
// Sources/Data/Repositories/ProductRepository.swift
final class ProductRepository: ProductRepositoryProtocol {
    private let remote: ProductRemoteDataSource
    private let cache: CacheManager
    
    init(remote: ProductRemoteDataSource, cache: CacheManager) {
        self.remote = remote
        self.cache = cache
    }
    
    func fetchAll() async throws -> [Product] {
        if let cached: [Product] = cache.get(key: "products") {
            return cached
        }
        let products = try await remote.fetchProducts()
        cache.set(key: "products", value: products)
        return products
    }
    
    // ... other methods
}
```

#### Step 5: Create ViewModel

```swift
// Sources/Presentation/ViewModels/ProductListViewModel.swift
@MainActor
final class ProductListViewModel: ObservableObject {
    @Published private(set) var products: [Product] = []
    @Published private(set) var state: ViewState = .idle
    
    private let getProductsUseCase: GetProductsUseCaseProtocol
    
    enum ViewState: Equatable {
        case idle, loading, loaded, error(String)
    }
    
    init(getProductsUseCase: GetProductsUseCaseProtocol) {
        self.getProductsUseCase = getProductsUseCase
    }
    
    func loadProducts() async {
        state = .loading
        do {
            products = try await getProductsUseCase.execute()
            state = .loaded
        } catch {
            state = .error(error.localizedDescription)
        }
    }
}
```

#### Step 6: Build the View

```swift
// Sources/Presentation/Views/ProductListView.swift
struct ProductListView: View {
    @StateObject private var viewModel: ProductListViewModel
    
    init(viewModel: ProductListViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationStack {
            Group {
                switch viewModel.state {
                case .idle, .loading:
                    ProgressView()
                case .loaded:
                    productList
                case .error(let message):
                    errorView(message)
                }
            }
            .navigationTitle("Products")
        }
        .task { await viewModel.loadProducts() }
    }
    
    private var productList: some View {
        List(viewModel.products) { product in
            ProductRow(product: product)
        }
    }
    
    private func errorView(_ message: String) -> some View {
        ContentUnavailableView(
            "Error",
            systemImage: "exclamationmark.triangle",
            description: Text(message)
        )
    }
}
```

#### Step 7: Wire Up Dependencies

```swift
// Sources/Infrastructure/DI/DependencyContainer.swift
@MainActor
final class DependencyContainer {
    static let shared = DependencyContainer()
    
    // Data Sources
    private lazy var apiService = APIService()
    private lazy var cacheManager = CacheManager()
    
    // Repositories
    private lazy var productRepository: ProductRepositoryProtocol = {
        ProductRepository(remote: apiService, cache: cacheManager)
    }()
    
    // Use Cases
    func makeGetProductsUseCase() -> GetProductsUseCaseProtocol {
        GetProductsUseCase(repository: productRepository)
    }
    
    // ViewModels
    func makeProductListViewModel() -> ProductListViewModel {
        ProductListViewModel(getProductsUseCase: makeGetProductsUseCase())
    }
}
```

---

## SOLID Principles in Action

This template strictly follows SOLID principles throughout:

### **S** — Single Responsibility

> Each class has one job, one reason to change.

```swift
// ✅ Good: UseCase only handles business logic
final class GetUserUseCase {
    func execute(id: UUID) async throws -> User
}

// ✅ Good: Repository only handles data coordination
final class UserRepository {
    func fetchUser(id: UUID) async throws -> User
}

// ❌ Bad: God class doing everything
final class UserManager {
    func fetchUser() { }
    func validateUser() { }
    func formatUserName() { }
    func saveToDatabase() { }
    func sendNotification() { }
}
```

### **O** — Open/Closed

> Open for extension, closed for modification.

```swift
// New analytics provider? Just add a new implementation
protocol AnalyticsServiceProtocol {
    func track(event: String, parameters: [String: Any])
}

final class FirebaseAnalytics: AnalyticsServiceProtocol { }
final class MixpanelAnalytics: AnalyticsServiceProtocol { }
final class AmplitudeAnalytics: AnalyticsServiceProtocol { }

// Composite pattern for multiple providers
final class CompositeAnalytics: AnalyticsServiceProtocol {
    private let services: [AnalyticsServiceProtocol]
    
    func track(event: String, parameters: [String: Any]) {
        services.forEach { $0.track(event: event, parameters: parameters) }
    }
}
```

### **L** — Liskov Substitution

> Subtypes must be substitutable for their base types.

```swift
protocol DataSourceProtocol {
    func fetchUsers() async throws -> [UserDTO]
}

// Both can be used interchangeably
final class RemoteDataSource: DataSourceProtocol { }
final class LocalDataSource: DataSourceProtocol { }
final class MockDataSource: DataSourceProtocol { }  // For testing
```

### **I** — Interface Segregation

> Clients shouldn't depend on interfaces they don't use.

```swift
// ✅ Good: Focused protocols
protocol Fetchable {
    associatedtype T
    func fetch(id: UUID) async throws -> T
}

protocol Saveable {
    associatedtype T
    func save(_ item: T) async throws
}

protocol Deletable {
    func delete(id: UUID) async throws
}

// Compose only what you need
final class ReadOnlyRepository: Fetchable { }
final class FullRepository: Fetchable, Saveable, Deletable { }
```

### **D** — Dependency Inversion

> Depend on abstractions, not concretions.

```swift
// ✅ Domain layer defines the protocol
protocol UserRepositoryProtocol {
    func fetchUser(id: UUID) async throws -> User
}

// ✅ Data layer implements it
final class UserRepository: UserRepositoryProtocol {
    func fetchUser(id: UUID) async throws -> User { }
}

// ✅ UseCase depends on abstraction
final class GetUserUseCase {
    private let repository: UserRepositoryProtocol  // Protocol, not concrete
    
    init(repository: UserRepositoryProtocol) {
        self.repository = repository
    }
}
```

---

## Testing

The architecture makes testing straightforward:

```swift
final class GetUserUseCaseTests: XCTestCase {
    var sut: GetUserUseCase!
    var mockRepository: MockUserRepository!
    
    override func setUp() {
        mockRepository = MockUserRepository()
        sut = GetUserUseCase(repository: mockRepository)
    }
    
    func test_execute_withValidId_returnsUser() async throws {
        // Given
        let expectedUser = User(id: UUID(), name: "John", email: "john@test.com")
        mockRepository.stubbedFetchResult = expectedUser
        
        // When
        let result = try await sut.execute(id: expectedUser.id)
        
        // Then
        XCTAssertEqual(result, expectedUser)
        XCTAssertEqual(mockRepository.fetchCallCount, 1)
    }
    
    func test_execute_withInvalidId_throwsError() async {
        // Given
        mockRepository.stubbedError = RepositoryError.notFound
        
        // When/Then
        do {
            _ = try await sut.execute(id: UUID())
            XCTFail("Expected error")
        } catch {
            XCTAssertEqual(error as? RepositoryError, .notFound)
        }
    }
}
```

Run tests:

```bash
swift test
```

---

## Requirements

| Requirement | Version |
|-------------|---------|
| iOS | 15.0+ |
| macOS | 12.0+ |
| Xcode | 15.0+ |
| Swift | 5.9+ |

---

## Resources

- [Clean Architecture Book](https://www.amazon.com/Clean-Architecture-Craftsmans-Software-Structure/dp/0134494164) by Robert C. Martin
- [The Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html) blog post
- [iOS Clean Architecture](https://tech.olx.com/clean-architecture-and-mvvm-on-ios-c9d167d9f5b3) - OLX Tech Blog

---

## Contributing

Contributions are welcome! Please read [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## License

MIT License - see [LICENSE](LICENSE) for details.

---

<p align="center">
  <sub>Built with ❤️ by <a href="https://github.com/muhittincamdali">Muhittin Camdali</a></sub>
</p>

---

## 📈 Star History

<a href="https://star-history.com/#muhittincamdali/ios-clean-architecture-template&Date">
 <picture>
   <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/svg?repos=muhittincamdali/ios-clean-architecture-template&type=Date&theme=dark" />
   <source media="(prefers-color-scheme: light)" srcset="https://api.star-history.com/svg?repos=muhittincamdali/ios-clean-architecture-template&type=Date" />
   <img alt="Star History Chart" src="https://api.star-history.com/svg?repos=muhittincamdali/ios-clean-architecture-template&type=Date" />
 </picture>
</a>
