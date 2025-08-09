# 🏗️ Architecture Guide

<!-- TOC START -->
## Table of Contents
- [🏗️ Architecture Guide](#-architecture-guide)
- [🎯 Clean Architecture Overview](#-clean-architecture-overview)
  - [🏗️ Katman Yapısı](#-katman-yaps)
  - [🔄 Bağımlılık Yönü](#-bagmllk-yonu)
- [📊 Domain Layer](#-domain-layer)
  - [🏢 Entities](#-entities)
  - [📋 Use Cases](#-use-cases)
  - [🤝 Protocols](#-protocols)
- [💾 Data Layer](#-data-layer)
  - [🗄️ Repositories](#-repositories)
  - [📡 Remote DataSources](#-remote-datasources)
  - [💿 Local DataSources](#-local-datasources)
- [📱 Presentation Layer](#-presentation-layer)
  - [🧠 ViewModels](#-viewmodels)
  - [🎨 Views](#-views)
  - [🎯 Coordinators](#-coordinators)
- [🔧 Infrastructure Layer](#-infrastructure-layer)
  - [🔐 Security](#-security)
  - [📊 Analytics](#-analytics)
  - [🎨 Design System](#-design-system)
  - [⚡ Performance](#-performance)
- [🔄 Dependency Injection](#-dependency-injection)
- [🧪 Testing Strategy](#-testing-strategy)
  - [📊 Test Pyramid](#-test-pyramid)
  - [🧪 Unit Tests](#-unit-tests)
  - [🧪 Integration Tests](#-integration-tests)
- [📚 Best Practices](#-best-practices)
  - [🎯 Clean Architecture Principles](#-clean-architecture-principles)
  - [🔧 Code Organization](#-code-organization)
  - [🧪 Testing Guidelines](#-testing-guidelines)
<!-- TOC END -->


<div align="center">

**🏗️ Dünya standartlarında Clean Architecture rehberi**

[📚 Getting Started](GettingStarted.md) • [🔌 API Reference](API.md) • [🎨 Design System](DesignSystem.md)

</div>

---

## 🎯 Clean Architecture Overview

Bu proje, **Clean Architecture** prensiplerini takip ederek dünya standartlarında bir iOS uygulaması geliştirmeyi hedefler.

### 🏗️ Katman Yapısı

```
📱 Presentation Layer (UI)
├── 🎨 Views (SwiftUI/UIKit)
├── 🧠 ViewModels
└── 🎯 Coordinators

📊 Domain Layer (Business Logic)
├── 🏢 Entities
├── 📋 Use Cases
└── 🤝 Protocols

💾 Data Layer (Data Access)
├── 📡 Remote DataSources
├── 💿 Local DataSources
└── 🗄️ Repositories

🔧 Infrastructure Layer (External Services)
├── 🔐 Security
├── 📊 Analytics
├── 🎨 Design System
└── ⚡ Performance
```

### 🔄 Bağımlılık Yönü

```
Presentation → Domain ← Data
     ↓           ↑        ↓
Infrastructure → Domain ← Infrastructure
```

**Önemli**: Tüm bağımlılıklar **Domain Layer**'a doğru yönelir.

---

## 📊 Domain Layer

Domain Layer, iş mantığının kalbidir ve hiçbir dış bağımlılığı yoktur.

### 🏢 Entities

```swift
// Core business objects
struct User {
    let id: String
    let name: String
    let email: String
    let profileImage: URL?
    let createdAt: Date
    let updatedAt: Date
}

struct Product {
    let id: String
    let name: String
    let description: String
    let price: Decimal
    let category: Category
    let images: [URL]
    let isAvailable: Bool
}

struct Order {
    let id: String
    let userId: String
    let products: [OrderItem]
    let totalAmount: Decimal
    let status: OrderStatus
    let createdAt: Date
    let updatedAt: Date
}
```

### 📋 Use Cases

```swift
// Business logic implementation
protocol GetUserUseCaseProtocol {
    func execute(id: String) async throws -> User
}

protocol CreateUserUseCaseProtocol {
    func execute(user: CreateUserRequest) async throws -> User
}

protocol UpdateUserUseCaseProtocol {
    func execute(id: String, updates: UpdateUserRequest) async throws -> User
}

protocol DeleteUserUseCaseProtocol {
    func execute(id: String) async throws -> Bool
}

// Implementation
class GetUserUseCase: GetUserUseCaseProtocol {
    private let userRepository: UserRepositoryProtocol
    
    init(userRepository: UserRepositoryProtocol) {
        self.userRepository = userRepository
    }
    
    func execute(id: String) async throws -> User {
        guard !id.isEmpty else {
            throw DomainError.invalidUserId
        }
        
        return try await userRepository.getUser(id: id)
    }
}
```

### 🤝 Protocols

```swift
// Repository protocols
protocol UserRepositoryProtocol {
    func getUser(id: String) async throws -> User
    func createUser(_ user: CreateUserRequest) async throws -> User
    func updateUser(id: String, updates: UpdateUserRequest) async throws -> User
    func deleteUser(id: String) async throws -> Bool
    func getUsers(page: Int, limit: Int) async throws -> [User]
}

protocol ProductRepositoryProtocol {
    func getProduct(id: String) async throws -> Product
    func getProducts(category: Category?, page: Int, limit: Int) async throws -> [Product]
    func searchProducts(query: String, page: Int, limit: Int) async throws -> [Product]
}

protocol OrderRepositoryProtocol {
    func createOrder(_ order: CreateOrderRequest) async throws -> Order
    func getOrder(id: String) async throws -> Order
    func getUserOrders(userId: String, page: Int, limit: Int) async throws -> [Order]
    func updateOrderStatus(id: String, status: OrderStatus) async throws -> Order
}
```

---

## 💾 Data Layer

Data Layer, veri erişimi ve yönetiminden sorumludur.

### 🗄️ Repositories

```swift
// Repository implementation
class UserRepository: UserRepositoryProtocol {
    private let remoteDataSource: UserRemoteDataSourceProtocol
    private let localDataSource: UserLocalDataSourceProtocol
    private let networkMonitor: NetworkMonitorProtocol
    
    init(
        remoteDataSource: UserRemoteDataSourceProtocol,
        localDataSource: UserLocalDataSourceProtocol,
        networkMonitor: NetworkMonitorProtocol
    ) {
        self.remoteDataSource = remoteDataSource
        self.localDataSource = localDataSource
        self.networkMonitor = networkMonitor
    }
    
    func getUser(id: String) async throws -> User {
        // Check network availability
        guard networkMonitor.isConnected else {
            return try await localDataSource.getUser(id: id)
        }
        
        do {
            // Try remote first
            let user = try await remoteDataSource.getUser(id: id)
            // Cache locally
            try await localDataSource.saveUser(user)
            return user
        } catch {
            // Fallback to local
            return try await localDataSource.getUser(id: id)
        }
    }
}
```

### 📡 Remote DataSources

```swift
// API data source
protocol UserRemoteDataSourceProtocol {
    func getUser(id: String) async throws -> UserDTO
    func createUser(_ user: CreateUserDTO) async throws -> UserDTO
    func updateUser(id: String, updates: UpdateUserDTO) async throws -> UserDTO
    func deleteUser(id: String) async throws -> Bool
    func getUsers(page: Int, limit: Int) async throws -> [UserDTO]
}

class UserRemoteDataSource: UserRemoteDataSourceProtocol {
    private let networkClient: NetworkClientProtocol
    
    init(networkClient: NetworkClientProtocol) {
        self.networkClient = networkClient
    }
    
    func getUser(id: String) async throws -> UserDTO {
        let endpoint = APIEndpoint.getUser(id: id)
        let userDTO: UserDTO = try await networkClient.request(endpoint)
        return userDTO
    }
}
```

### 💿 Local DataSources

```swift
// Core Data implementation
protocol UserLocalDataSourceProtocol {
    func getUser(id: String) async throws -> User
    func saveUser(_ user: User) async throws
    func deleteUser(id: String) async throws
    func getUsers(page: Int, limit: Int) async throws -> [User]
}

class UserLocalDataSource: UserLocalDataSourceProtocol {
    private let coreDataManager: CoreDataManagerProtocol
    
    init(coreDataManager: CoreDataManagerProtocol) {
        self.coreDataManager = coreDataManager
    }
    
    func getUser(id: String) async throws -> User {
        let context = coreDataManager.mainContext
        
        let request: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id)
        request.fetchLimit = 1
        
        let entities = try context.fetch(request)
        guard let entity = entities.first else {
            throw DataError.userNotFound
        }
        
        return entity.toDomain()
    }
}
```

---

## 📱 Presentation Layer

Presentation Layer, kullanıcı arayüzü ve etkileşiminden sorumludur.

### 🧠 ViewModels

```swift
// MVVM ViewModel
@MainActor
class UserViewModel: ObservableObject {
    @Published var user: User?
    @Published var isLoading = false
    @Published var error: Error?
    @Published var isRefreshing = false
    
    private let getUserUseCase: GetUserUseCaseProtocol
    private let updateUserUseCase: UpdateUserUseCaseProtocol
    private let deleteUserUseCase: DeleteUserUseCaseProtocol
    
    init(
        getUserUseCase: GetUserUseCaseProtocol,
        updateUserUseCase: UpdateUserUseCaseProtocol,
        deleteUserUseCase: DeleteUserUseCaseProtocol
    ) {
        self.getUserUseCase = getUserUseCase
        self.updateUserUseCase = updateUserUseCase
        self.deleteUserUseCase = deleteUserUseCase
    }
    
    func loadUser(id: String) async {
        isLoading = true
        error = nil
        
        do {
            user = try await getUserUseCase.execute(id: id)
        } catch {
            self.error = error
        }
        
        isLoading = false
    }
    
    func refreshUser(id: String) async {
        isRefreshing = true
        
        do {
            user = try await getUserUseCase.execute(id: id)
        } catch {
            self.error = error
        }
        
        isRefreshing = false
    }
    
    func updateUser(id: String, updates: UpdateUserRequest) async {
        isLoading = true
        error = nil
        
        do {
            user = try await updateUserUseCase.execute(id: id, updates: updates)
        } catch {
            self.error = error
        }
        
        isLoading = false
    }
    
    func deleteUser(id: String) async {
        isLoading = true
        error = nil
        
        do {
            let success = try await deleteUserUseCase.execute(id: id)
            if success {
                user = nil
            }
        } catch {
            self.error = error
        }
        
        isLoading = false
    }
}
```

### 🎨 Views

```swift
// SwiftUI View
struct UserView: View {
    @StateObject private var viewModel: UserViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(userId: String) {
        self._viewModel = StateObject(wrappedValue: UserViewModel(
            getUserUseCase: DependencyContainer.shared.getUserUseCase,
            updateUserUseCase: DependencyContainer.shared.updateUserUseCase,
            deleteUserUseCase: DependencyContainer.shared.deleteUserUseCase
        ))
        self.userId = userId
    }
    
    var body: some View {
        NavigationView {
            Group {
                if viewModel.isLoading {
                    LoadingView()
                } else if let user = viewModel.user {
                    UserDetailView(user: user, viewModel: viewModel)
                } else if let error = viewModel.error {
                    ErrorView(error: error, retryAction: {
                        Task {
                            await viewModel.loadUser(id: userId)
                        }
                    })
                } else {
                    EmptyStateView()
                }
            }
            .navigationTitle("User Profile")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Edit") {
                        // Navigate to edit view
                    }
                }
            }
            .refreshable {
                await viewModel.refreshUser(id: userId)
            }
        }
        .task {
            await viewModel.loadUser(id: userId)
        }
    }
}

// User Detail View
struct UserDetailView: View {
    let user: User
    @ObservedObject var viewModel: UserViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Profile Image
                AsyncImage(url: user.profileImage) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.gray)
                }
                .frame(width: 120, height: 120)
                .clipShape(Circle())
                
                // User Info
                VStack(spacing: 12) {
                    Text(user.name)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text(user.email)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("Member since \(user.createdAt.formatted(date: .abbreviated, time: .omitted))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Actions
                VStack(spacing: 12) {
                    Button("Edit Profile") {
                        // Navigate to edit
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button("Delete Account", role: .destructive) {
                        // Show delete confirmation
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding()
        }
    }
}
```

### 🎯 Coordinators

```swift
// Navigation coordinator
protocol UserCoordinatorProtocol {
    func showUserDetail(id: String)
    func showUserEdit(user: User)
    func showUserDeleteConfirmation(user: User)
    func dismiss()
}

class UserCoordinator: UserCoordinatorProtocol {
    private let navigationController: UINavigationController
    private let dependencyContainer: DependencyContainerProtocol
    
    init(
        navigationController: UINavigationController,
        dependencyContainer: DependencyContainerProtocol
    ) {
        self.navigationController = navigationController
        self.dependencyContainer = dependencyContainer
    }
    
    func showUserDetail(id: String) {
        let userView = UserView(userId: id)
        let hostingController = UIHostingController(rootView: userView)
        navigationController.pushViewController(hostingController, animated: true)
    }
    
    func showUserEdit(user: User) {
        let editView = UserEditView(user: user)
        let hostingController = UIHostingController(rootView: editView)
        navigationController.pushViewController(hostingController, animated: true)
    }
    
    func showUserDeleteConfirmation(user: User) {
        let alert = UIAlertController(
            title: "Delete Account",
            message: "Are you sure you want to delete your account? This action cannot be undone.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
            // Handle deletion
        })
        
        navigationController.present(alert, animated: true)
    }
    
    func dismiss() {
        navigationController.popViewController(animated: true)
    }
}
```

---

## 🔧 Infrastructure Layer

Infrastructure Layer, dış servisler ve altyapı bileşenlerini içerir.

### 🔐 Security

```swift
// Security manager
protocol SecurityManagerProtocol {
    func encrypt(_ data: Data) throws -> Data
    func decrypt(_ data: Data) throws -> Data
    func saveSecurely(_ data: Data, forKey key: String) throws
    func loadSecurely(forKey key: String) throws -> Data
    func deleteSecurely(forKey key: String) throws
}

class SecurityManager: SecurityManagerProtocol {
    private let keychain: KeychainProtocol
    private let encryption: EncryptionProtocol
    
    init(keychain: KeychainProtocol, encryption: EncryptionProtocol) {
        self.keychain = keychain
        self.encryption = encryption
    }
    
    func saveSecurely(_ data: Data, forKey key: String) throws {
        let encryptedData = try encrypt(data)
        try keychain.save(encryptedData, forKey: key)
    }
    
    func loadSecurely(forKey key: String) throws -> Data {
        let encryptedData = try keychain.load(forKey: key)
        return try decrypt(encryptedData)
    }
}
```

### 📊 Analytics

```swift
// Analytics manager
protocol AnalyticsManagerProtocol {
    func trackEvent(_ event: AnalyticsEvent)
    func trackScreen(_ screen: AnalyticsScreen)
    func trackError(_ error: Error)
    func setUserProperty(_ value: String, forKey key: String)
}

class AnalyticsManager: AnalyticsManagerProtocol {
    private let firebaseAnalytics: FirebaseAnalyticsProtocol
    private let crashlytics: CrashlyticsProtocol
    
    init(
        firebaseAnalytics: FirebaseAnalyticsProtocol,
        crashlytics: CrashlyticsProtocol
    ) {
        self.firebaseAnalytics = firebaseAnalytics
        self.crashlytics = crashlytics
    }
    
    func trackEvent(_ event: AnalyticsEvent) {
        firebaseAnalytics.logEvent(event.name, parameters: event.parameters)
    }
    
    func trackError(_ error: Error) {
        crashlytics.recordError(error)
    }
}
```

### 🎨 Design System

```swift
// Design system manager
protocol DesignSystemProtocol {
    var colors: ColorPalette { get }
    var typography: Typography { get }
    var spacing: Spacing { get }
    var animations: Animations { get }
}

class DesignSystem: DesignSystemProtocol {
    let colors: ColorPalette
    let typography: Typography
    let spacing: Spacing
    let animations: Animations
    
    init(
        colors: ColorPalette,
        typography: Typography,
        spacing: Spacing,
        animations: Animations
    ) {
        self.colors = colors
        self.typography = typography
        self.spacing = spacing
        self.animations = animations
    }
}

// Color palette
struct ColorPalette {
    let primary: Color
    let secondary: Color
    let accent: Color
    let background: Color
    let surface: Color
    let error: Color
    let success: Color
    let warning: Color
    let text: Color
    let textSecondary: Color
}

// Typography
struct Typography {
    let h1: Font
    let h2: Font
    let h3: Font
    let h4: Font
    let h5: Font
    let h6: Font
    let body: Font
    let caption: Font
    let button: Font
}
```

### ⚡ Performance

```swift
// Performance monitor
protocol PerformanceMonitorProtocol {
    func startTrace(_ name: String)
    func endTrace(_ name: String)
    func addMetric(_ name: String, value: Double)
    func recordError(_ error: Error)
}

class PerformanceMonitor: PerformanceMonitorProtocol {
    private let firebasePerformance: FirebasePerformanceProtocol
    
    init(firebasePerformance: FirebasePerformanceProtocol) {
        self.firebasePerformance = firebasePerformance
    }
    
    func startTrace(_ name: String) {
        firebasePerformance.startTrace(name: name)
    }
    
    func endTrace(_ name: String) {
        firebasePerformance.endTrace(name: name)
    }
}
```

---

## 🔄 Dependency Injection

Dependency Injection, bağımlılıkları yönetmek için kullanılır.

```swift
// Dependency container
protocol DependencyContainerProtocol {
    func register<T>(_ type: T.Type, factory: @escaping () -> T)
    func resolve<T>(_ type: T.Type) -> T
}

class DependencyContainer: DependencyContainerProtocol {
    private var factories: [String: () -> Any] = [:]
    
    func register<T>(_ type: T.Type, factory: @escaping () -> T) {
        let key = String(describing: type)
        factories[key] = factory
    }
    
    func resolve<T>(_ type: T.Type) -> T {
        let key = String(describing: type)
        guard let factory = factories[key] else {
            fatalError("No factory registered for type: \(type)")
        }
        
        guard let instance = factory() as? T else {
            fatalError("Factory returned wrong type for: \(type)")
        }
        
        return instance
    }
}

// Container setup
extension DependencyContainer {
    static func setup() -> DependencyContainer {
        let container = DependencyContainer()
        
        // Register repositories
        container.register(UserRepositoryProtocol.self) {
            UserRepository(
                remoteDataSource: container.resolve(UserRemoteDataSourceProtocol.self),
                localDataSource: container.resolve(UserLocalDataSourceProtocol.self),
                networkMonitor: container.resolve(NetworkMonitorProtocol.self)
            )
        }
        
        // Register use cases
        container.register(GetUserUseCaseProtocol.self) {
            GetUserUseCase(
                userRepository: container.resolve(UserRepositoryProtocol.self)
            )
        }
        
        // Register view models
        container.register(UserViewModel.self) { userId in
            UserViewModel(
                getUserUseCase: container.resolve(GetUserUseCaseProtocol.self),
                updateUserUseCase: container.resolve(UpdateUserUseCaseProtocol.self),
                deleteUserUseCase: container.resolve(DeleteUserUseCaseProtocol.self)
            )
        }
        
        return container
    }
}
```

---

## 🧪 Testing Strategy

### 📊 Test Pyramid

```
    🧪 E2E Tests (10%)
   🧪 Integration Tests (20%)
  🧪 Unit Tests (70%)
```

### 🧪 Unit Tests

```swift
// Use case tests
class GetUserUseCaseTests: XCTestCase {
    var useCase: GetUserUseCase!
    var mockRepository: MockUserRepository!
    
    override func setUp() {
        super.setUp()
        mockRepository = MockUserRepository()
        useCase = GetUserUseCase(userRepository: mockRepository)
    }
    
    func testGetUserSuccess() async throws {
        // Given
        let expectedUser = User(id: "123", name: "John Doe", email: "john@example.com")
        mockRepository.getUserResult = .success(expectedUser)
        
        // When
        let user = try await useCase.execute(id: "123")
        
        // Then
        XCTAssertEqual(user.id, "123")
        XCTAssertEqual(user.name, "John Doe")
        XCTAssertEqual(user.email, "john@example.com")
    }
    
    func testGetUserWithEmptyId() async throws {
        // Given
        let emptyId = ""
        
        // When & Then
        do {
            _ = try await useCase.execute(id: emptyId)
            XCTFail("Should throw error for empty ID")
        } catch {
            XCTAssertEqual(error as? DomainError, .invalidUserId)
        }
    }
}
```

### 🧪 Integration Tests

```swift
// Repository integration tests
class UserRepositoryIntegrationTests: XCTestCase {
    var repository: UserRepository!
    var mockRemoteDataSource: MockUserRemoteDataSource!
    var mockLocalDataSource: MockUserLocalDataSource!
    var mockNetworkMonitor: MockNetworkMonitor!
    
    override func setUp() {
        super.setUp()
        mockRemoteDataSource = MockUserRemoteDataSource()
        mockLocalDataSource = MockUserLocalDataSource()
        mockNetworkMonitor = MockNetworkMonitor()
        
        repository = UserRepository(
            remoteDataSource: mockRemoteDataSource,
            localDataSource: mockLocalDataSource,
            networkMonitor: mockNetworkMonitor
        )
    }
    
    func testGetUserWithNetworkAvailable() async throws {
        // Given
        let expectedUser = User(id: "123", name: "John Doe", email: "john@example.com")
        mockNetworkMonitor.isConnected = true
        mockRemoteDataSource.getUserResult = .success(expectedUser)
        
        // When
        let user = try await repository.getUser(id: "123")
        
        // Then
        XCTAssertEqual(user.id, "123")
        XCTAssertTrue(mockLocalDataSource.saveUserCalled)
    }
}
```

---

## 📚 Best Practices

### 🎯 Clean Architecture Principles

1. **Dependency Rule**: Dependencies point inward
2. **Single Responsibility**: Each class has one reason to change
3. **Open/Closed**: Open for extension, closed for modification
4. **Interface Segregation**: Clients depend on interfaces they use
5. **Dependency Inversion**: Depend on abstractions, not concretions

### 🔧 Code Organization

```
Sources/
├── Domain/
│   ├── Entities/
│   ├── UseCases/
│   └── Protocols/
├── Data/
│   ├── Repositories/
│   ├── DataSources/
│   └── Models/
├── Presentation/
│   ├── Views/
│   ├── ViewModels/
│   └── Coordinators/
└── Infrastructure/
    ├── Security/
    ├── Analytics/
    ├── Design/
    └── Performance/
```

### 🧪 Testing Guidelines

1. **Test Coverage**: Aim for 100% test coverage
2. **Test Naming**: Given-When-Then pattern
3. **Mock Usage**: Mock external dependencies
4. **Test Isolation**: Each test should be independent
5. **Fast Tests**: Tests should run quickly

---

<div align="center">

**🏗️ Dünya standartlarında Clean Architecture için teşekkürler!**

**🚀 Dünya standartlarında iOS Clean Architecture Template**

</div> 