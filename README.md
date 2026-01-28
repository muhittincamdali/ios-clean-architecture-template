# iOS Clean Architecture Template

<p align="center">
  <img src="Assets/banner.png" alt="iOS Clean Architecture" width="800">
</p>

<p align="center">
  <a href="https://swift.org"><img src="https://img.shields.io/badge/Swift-5.9+-F05138?style=flat&logo=swift&logoColor=white" alt="Swift"></a>
  <a href="https://developer.apple.com/ios/"><img src="https://img.shields.io/badge/iOS-15.0+-000000?style=flat&logo=apple&logoColor=white" alt="iOS"></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-green.svg" alt="License"></a>
  <a href="https://github.com/muhittincamdali/ios-clean-architecture-template/actions"><img src="https://github.com/muhittincamdali/ios-clean-architecture-template/actions/workflows/ci.yml/badge.svg" alt="CI"></a>
</p>

<p align="center">
  <b>A production-ready iOS app template with Clean Architecture, MVVM-C, and best practices.</b>
</p>

---

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    Presentation                          │
│  ┌────────────┐  ┌────────────┐  ┌────────────┐        │
│  │    View    │  │  ViewModel │  │ Coordinator│        │
│  │  (SwiftUI) │  │            │  │            │        │
│  └─────┬──────┘  └──────┬─────┘  └──────┬─────┘        │
│        │                │               │               │
├────────┼────────────────┼───────────────┼───────────────┤
│        │         Domain │               │               │
│        │  ┌─────────────┴─────────────┐ │               │
│        │  │         Use Cases         │ │               │
│        │  │   ┌──────┐  ┌──────┐     │ │               │
│        │  │   │Fetch │  │Create│     │ │               │
│        │  │   │User  │  │Order │     │ │               │
│        │  │   └──────┘  └──────┘     │ │               │
│        │  └───────────────────────────┘ │               │
│        │                                │               │
│        │  ┌───────────────────────────┐ │               │
│        │  │        Entities           │ │               │
│        │  │   User, Product, Order    │ │               │
│        │  └───────────────────────────┘ │               │
│        │                                │               │
│        │  ┌───────────────────────────┐ │               │
│        │  │    Repository Protocols   │ │               │
│        │  └───────────────────────────┘ │               │
│        │                │               │               │
├────────┼────────────────┼───────────────┼───────────────┤
│        │          Data  │               │               │
│        │  ┌─────────────┴─────────────┐ │               │
│        │  │   Repository Implementations│               │
│        │  └─────────────┬─────────────┘ │               │
│        │                │               │               │
│        │  ┌─────────────┼─────────────┐ │               │
│        │  │   Network   │   Storage   │ │               │
│        │  │   Service   │   Service   │ │               │
│        │  └─────────────┴─────────────┘ │               │
└─────────────────────────────────────────────────────────┘
```

## Features

- **Clean Architecture** — Clear separation of concerns
- **MVVM-C Pattern** — ViewModel + Coordinator navigation
- **Dependency Injection** — Protocol-based, testable design
- **Async/Await** — Modern Swift concurrency
- **SwiftUI & UIKit** — Support for both frameworks
- **Unit Tests** — Ready-to-use test structure

## Project Structure

```
ios-clean-architecture-template/
├── Sources/
│   ├── Domain/
│   │   ├── Entities/
│   │   │   ├── User.swift
│   │   │   └── Product.swift
│   │   ├── UseCases/
│   │   │   ├── FetchUserUseCase.swift
│   │   │   └── CreateOrderUseCase.swift
│   │   └── Repositories/
│   │       └── UserRepositoryProtocol.swift
│   │
│   ├── Data/
│   │   ├── Repositories/
│   │   │   └── UserRepository.swift
│   │   ├── Network/
│   │   │   ├── APIClient.swift
│   │   │   └── Endpoints.swift
│   │   └── Storage/
│   │       └── CoreDataManager.swift
│   │
│   ├── Presentation/
│   │   ├── Scenes/
│   │   │   ├── Home/
│   │   │   │   ├── HomeView.swift
│   │   │   │   ├── HomeViewModel.swift
│   │   │   │   └── HomeCoordinator.swift
│   │   │   └── Profile/
│   │   │       ├── ProfileView.swift
│   │   │       └── ProfileViewModel.swift
│   │   └── Common/
│   │       └── BaseViewModel.swift
│   │
│   ├── Infrastructure/
│   │   ├── DI/
│   │   │   └── DependencyContainer.swift
│   │   └── Extensions/
│   │
│   └── Core/
│       └── AppDelegate.swift
│
├── Tests/
│   ├── DomainTests/
│   ├── DataTests/
│   └── PresentationTests/
│
└── Resources/
```

## Installation

```swift
dependencies: [
    .package(url: "https://github.com/muhittincamdali/ios-clean-architecture-template.git", from: "1.0.0")
]
```

Or clone and use as a starting point:

```bash
git clone https://github.com/muhittincamdali/ios-clean-architecture-template.git MyApp
cd MyApp
```

## Quick Start

### 1. Define Entity (Domain)

```swift
// Domain/Entities/User.swift
struct User: Identifiable, Equatable {
    let id: UUID
    let name: String
    let email: String
    let createdAt: Date
}
```

### 2. Create Repository Protocol (Domain)

```swift
// Domain/Repositories/UserRepositoryProtocol.swift
protocol UserRepositoryProtocol {
    func fetchUser(id: UUID) async throws -> User
    func fetchAllUsers() async throws -> [User]
    func saveUser(_ user: User) async throws
    func deleteUser(id: UUID) async throws
}
```

### 3. Implement Use Case (Domain)

```swift
// Domain/UseCases/FetchUserUseCase.swift
final class FetchUserUseCase {
    private let repository: UserRepositoryProtocol
    
    init(repository: UserRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(id: UUID) async throws -> User {
        return try await repository.fetchUser(id: id)
    }
}
```

### 4. Implement Repository (Data)

```swift
// Data/Repositories/UserRepository.swift
final class UserRepository: UserRepositoryProtocol {
    private let apiClient: APIClient
    private let storage: StorageService
    
    init(apiClient: APIClient, storage: StorageService) {
        self.apiClient = apiClient
        self.storage = storage
    }
    
    func fetchUser(id: UUID) async throws -> User {
        // Try cache first
        if let cached = try? await storage.getUser(id: id) {
            return cached
        }
        
        // Fetch from API
        let user = try await apiClient.request(UserEndpoint.get(id: id))
        try await storage.saveUser(user)
        return user
    }
    
    func fetchAllUsers() async throws -> [User] {
        return try await apiClient.request(UserEndpoint.list)
    }
    
    func saveUser(_ user: User) async throws {
        try await apiClient.request(UserEndpoint.create(user))
        try await storage.saveUser(user)
    }
    
    func deleteUser(id: UUID) async throws {
        try await apiClient.request(UserEndpoint.delete(id: id))
        try await storage.deleteUser(id: id)
    }
}
```

### 5. Create ViewModel (Presentation)

```swift
// Presentation/Scenes/Profile/ProfileViewModel.swift
@MainActor
final class ProfileViewModel: ObservableObject {
    @Published private(set) var user: User?
    @Published private(set) var isLoading = false
    @Published private(set) var error: Error?
    
    private let fetchUserUseCase: FetchUserUseCase
    
    init(fetchUserUseCase: FetchUserUseCase) {
        self.fetchUserUseCase = fetchUserUseCase
    }
    
    func loadUser(id: UUID) async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            user = try await fetchUserUseCase.execute(id: id)
        } catch {
            self.error = error
        }
    }
}
```

### 6. Build View (Presentation)

```swift
// Presentation/Scenes/Profile/ProfileView.swift
struct ProfileView: View {
    @StateObject private var viewModel: ProfileViewModel
    let userId: UUID
    
    init(userId: UUID, viewModel: ProfileViewModel) {
        self.userId = userId
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
            } else if let user = viewModel.user {
                VStack(spacing: 16) {
                    Text(user.name)
                        .font(.title)
                    Text(user.email)
                        .foregroundStyle(.secondary)
                }
            } else if let error = viewModel.error {
                Text(error.localizedDescription)
                    .foregroundStyle(.red)
            }
        }
        .task {
            await viewModel.loadUser(id: userId)
        }
    }
}
```

### 7. Setup Dependency Injection

```swift
// Infrastructure/DI/DependencyContainer.swift
final class DependencyContainer {
    static let shared = DependencyContainer()
    
    private lazy var apiClient = APIClient()
    private lazy var storage = CoreDataManager()
    
    private lazy var userRepository: UserRepositoryProtocol = {
        UserRepository(apiClient: apiClient, storage: storage)
    }()
    
    func makeFetchUserUseCase() -> FetchUserUseCase {
        FetchUserUseCase(repository: userRepository)
    }
    
    func makeProfileViewModel() -> ProfileViewModel {
        ProfileViewModel(fetchUserUseCase: makeFetchUserUseCase())
    }
}
```

## Testing

```swift
// Tests/DomainTests/FetchUserUseCaseTests.swift
final class FetchUserUseCaseTests: XCTestCase {
    var sut: FetchUserUseCase!
    var mockRepository: MockUserRepository!
    
    override func setUp() {
        mockRepository = MockUserRepository()
        sut = FetchUserUseCase(repository: mockRepository)
    }
    
    func testFetchUser_Success() async throws {
        // Given
        let expectedUser = User(id: UUID(), name: "John", email: "john@example.com", createdAt: Date())
        mockRepository.stubbedUser = expectedUser
        
        // When
        let user = try await sut.execute(id: expectedUser.id)
        
        // Then
        XCTAssertEqual(user, expectedUser)
        XCTAssertTrue(mockRepository.fetchUserCalled)
    }
}
```

## Requirements

- iOS 15.0+
- Xcode 15.0+
- Swift 5.9+

## Documentation

- [Architecture Guide](Documentation/Architecture.md)
- [Dependency Injection](Documentation/DependencyInjection.md)
- [Testing Guide](Documentation/Testing.md)

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

MIT License. See [LICENSE](LICENSE).

## Author

**Muhittin Camdali** — [@muhittincamdali](https://github.com/muhittincamdali)

---

<p align="center">
  <sub>Clean code leads to clean architecture ❤️</sub>
</p>
