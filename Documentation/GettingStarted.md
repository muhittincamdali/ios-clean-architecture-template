# 🚀 Getting Started

<div align="center">

**🌟 Welcome to the iOS Clean Architecture Template!**

This guide will help you get started with the professional iOS Clean Architecture Template in just 5 minutes.

[📚 Documentation](#documentation) • [🏗️ Architecture](#architecture) • [🎨 Design System](#design-system) • [🧪 Testing](#testing)

</div>

---

## 📋 Requirements

### 🖥️ Development Environment
- **macOS 12.0+** (Monterey or later)
- **Xcode 14.0+** (Latest stable version recommended)
- **iOS 15.0+** (Minimum deployment target)
- **Swift 5.7+** (Latest Swift version)

### 📱 Device Support
- **iPhone**: iOS 15.0+
- **iPad**: iPadOS 15.0+
- **macOS**: macOS 12.0+ (Catalyst support)
- **watchOS**: watchOS 8.0+ (Optional)

### 📦 Dependencies
- **CocoaPods** (Optional, for dependency management)
- **Swift Package Manager** (Default, built into Xcode)
- **Carthage** (Optional, alternative dependency manager)

---

## ⚡ Quick Start

### 1. 🍴 Clone the Repository
```bash
# Clone the repository
git clone https://github.com/muhittincamdali/ios-clean-architecture-template.git

# Navigate to project directory
cd ios-clean-architecture-template
```

### 2. 📦 Install Dependencies
```bash
# Install CocoaPods (if not installed)
sudo gem install cocoapods

# Install project dependencies
pod install
```

### 3. 🚀 Open in Xcode
```bash
# Open the workspace (not the project file)
open ios-clean-architecture-template.xcworkspace
```

### 4. 🎯 Run the Project
- Select your target device or simulator
- Press **⌘+R** to build and run
- The app should launch successfully

---

## 🏗️ Project Structure

```
📱 ios-clean-architecture-template/
├── 📱 Sources/
│   ├── 📊 Domain/
│   │   ├── 🏢 Entities/
│   │   ├── 📋 Use Cases/
│   │   └── 🤝 Protocols/
│   ├── 💾 Data/
│   │   ├── 📡 Remote/
│   │   ├── 💿 Local/
│   │   └── 🗄️ Repositories/
│   ├── 📱 Presentation/
│   │   ├── 🎨 Views/
│   │   ├── 🧠 ViewModels/
│   │   └── 🎯 Coordinators/
│   └── 🔧 Infrastructure/
│       ├── 🔐 Security/
│       ├── 📊 Analytics/
│       ├── 🎨 Design System/
│       └── ⚡ Performance/
├── 🧪 Tests/
│   ├── UnitTests/
│   ├── IntegrationTests/
│   └── UITests/
├── 📚 Documentation/
├── 📦 Resources/
└── 🔧 Configuration/
```

---

## 🎯 Adding Your First Feature

Let's add a simple user management feature following Clean Architecture principles.

### 1. 📊 Domain Layer

#### Create Entity
```swift
// Sources/Domain/Entities/User.swift
struct User: Codable, Identifiable {
    let id: String
    let name: String
    let email: String
    let avatarURL: String?
    
    init(id: String, name: String, email: String, avatarURL: String? = nil) {
        self.id = id
        self.name = name
        self.email = email
        self.avatarURL = avatarURL
    }
}
```

#### Create Use Case
```swift
// Sources/Domain/UseCases/GetUserUseCase.swift
protocol GetUserUseCaseProtocol {
    func execute(id: String) async throws -> User
}

struct GetUserUseCase: GetUserUseCaseProtocol {
    private let repository: UserRepositoryProtocol
    
    init(repository: UserRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(id: String) async throws -> User {
        return try await repository.getUser(id: id)
    }
}
```

#### Create Protocol
```swift
// Sources/Domain/Protocols/UserRepositoryProtocol.swift
protocol UserRepositoryProtocol {
    func getUser(id: String) async throws -> User
    func createUser(_ user: User) async throws -> User
    func updateUser(_ user: User) async throws -> User
    func deleteUser(id: String) async throws
}
```

### 2. 💾 Data Layer

#### Create DTO
```swift
// Sources/Data/Models/UserDTO.swift
struct UserDTO: Codable {
    let id: String
    let name: String
    let email: String
    let avatarURL: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case email
        case avatarURL = "avatar_url"
    }
}

extension UserDTO {
    func toDomain() -> User {
        return User(
            id: id,
            name: name,
            email: email,
            avatarURL: avatarURL
        )
    }
}

extension User {
    func toDTO() -> UserDTO {
        return UserDTO(
            id: id,
            name: name,
            email: email,
            avatarURL: avatarURL
        )
    }
}
```

#### Create Repository Implementation
```swift
// Sources/Data/Repositories/UserRepository.swift
class UserRepository: UserRepositoryProtocol {
    private let remoteDataSource: UserRemoteDataSourceProtocol
    private let localDataSource: UserLocalDataSourceProtocol
    
    init(remoteDataSource: UserRemoteDataSourceProtocol, localDataSource: UserLocalDataSourceProtocol) {
        self.remoteDataSource = remoteDataSource
        self.localDataSource = localDataSource
    }
    
    func getUser(id: String) async throws -> User {
        do {
            // Try remote first
            let userDTO = try await remoteDataSource.fetchUser(id: id)
            let user = userDTO.toDomain()
            
            // Cache locally
            try await localDataSource.saveUser(userDTO)
            
            return user
        } catch {
            // Fallback to local
            if let userDTO = try await localDataSource.getUser(id: id) {
                return userDTO.toDomain()
            }
            throw error
        }
    }
    
    func createUser(_ user: User) async throws -> User {
        let userDTO = user.toDTO()
        let createdDTO = try await remoteDataSource.createUser(userDTO)
        try await localDataSource.saveUser(createdDTO)
        return createdDTO.toDomain()
    }
    
    func updateUser(_ user: User) async throws -> User {
        let userDTO = user.toDTO()
        let updatedDTO = try await remoteDataSource.updateUser(userDTO)
        try await localDataSource.saveUser(updatedDTO)
        return updatedDTO.toDomain()
    }
    
    func deleteUser(id: String) async throws {
        try await remoteDataSource.deleteUser(id: id)
        try await localDataSource.deleteUser(id: id)
    }
}
```

### 3. 📱 Presentation Layer

#### Create ViewModel
```swift
// Sources/Presentation/ViewModels/UserViewModel.swift
@MainActor
class UserViewModel: ObservableObject {
    @Published var user: User?
    @Published var isLoading = false
    @Published var error: Error?
    
    private let getUserUseCase: GetUserUseCaseProtocol
    
    init(getUserUseCase: GetUserUseCaseProtocol) {
        self.getUserUseCase = getUserUseCase
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
}
```

#### Create View
```swift
// Sources/Presentation/Views/UserView.swift
struct UserView: View {
    @StateObject private var viewModel: UserViewModel
    
    init(getUserUseCase: GetUserUseCaseProtocol) {
        self._viewModel = StateObject(wrappedValue: UserViewModel(getUserUseCase: getUserUseCase))
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if viewModel.isLoading {
                    ProgressView("Loading user...")
                        .progressViewStyle(CircularProgressViewStyle())
                } else if let user = viewModel.user {
                    UserDetailView(user: user)
                } else if let error = viewModel.error {
                    ErrorView(error: error) {
                        Task {
                            await viewModel.loadUser(id: "123")
                        }
                    }
                } else {
                    EmptyStateView()
                }
            }
            .navigationTitle("User Profile")
            .task {
                await viewModel.loadUser(id: "123")
            }
        }
    }
}

struct UserDetailView: View {
    let user: User
    
    var body: some View {
        VStack(spacing: 20) {
            if let avatarURL = user.avatarURL {
                AsyncImage(url: URL(string: avatarURL)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.gray)
                }
                .frame(width: 100, height: 100)
                .clipShape(Circle())
            }
            
            VStack(spacing: 10) {
                Text(user.name)
                    .font(.title)
                    .fontWeight(.bold)
                
                Text(user.email)
                    .font(.body)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
    }
}
```

---

## 🧪 Writing Tests

### Unit Tests
```swift
// Tests/UnitTests/GetUserUseCaseTests.swift
class GetUserUseCaseTests: XCTestCase {
    var useCase: GetUserUseCase!
    var mockRepository: MockUserRepository!
    
    override func setUp() {
        super.setUp()
        mockRepository = MockUserRepository()
        useCase = GetUserUseCase(repository: mockRepository)
    }
    
    override func tearDown() {
        useCase = nil
        mockRepository = nil
        super.tearDown()
    }
    
    func testGetUserSuccess() async throws {
        // Given
        let expectedUser = User(id: "123", name: "John Doe", email: "john@example.com")
        mockRepository.mockUser = expectedUser
        
        // When
        let result = try await useCase.execute(id: "123")
        
        // Then
        XCTAssertEqual(result.id, expectedUser.id)
        XCTAssertEqual(result.name, expectedUser.name)
        XCTAssertEqual(result.email, expectedUser.email)
    }
    
    func testGetUserFailure() async {
        // Given
        mockRepository.shouldThrowError = true
        
        // When & Then
        do {
            _ = try await useCase.execute(id: "123")
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(error is RepositoryError)
        }
    }
}

class MockUserRepository: UserRepositoryProtocol {
    var mockUser: User?
    var shouldThrowError = false
    
    func getUser(id: String) async throws -> User {
        if shouldThrowError {
            throw RepositoryError.networkError
        }
        
        guard let user = mockUser else {
            throw RepositoryError.userNotFound
        }
        
        return user
    }
    
    func createUser(_ user: User) async throws -> User {
        return user
    }
    
    func updateUser(_ user: User) async throws -> User {
        return user
    }
    
    func deleteUser(id: String) async throws {
        // Mock implementation
    }
}
```

### UI Tests
```swift
// Tests/UITests/UserViewUITests.swift
class UserViewUITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUp() {
        super.setUp()
        app = XCUIApplication()
        app.launch()
    }
    
    func testUserViewDisplaysUserData() {
        // Given
        let userView = app.otherElements["UserView"]
        
        // When
        userView.tap()
        
        // Then
        XCTAssertTrue(app.staticTexts["John Doe"].exists)
        XCTAssertTrue(app.staticTexts["john@example.com"].exists)
    }
    
    func testUserViewShowsLoadingState() {
        // Given
        let userView = app.otherElements["UserView"]
        
        // When
        userView.tap()
        
        // Then
        XCTAssertTrue(app.activityIndicators["LoadingIndicator"].exists)
    }
}
```

---

## ⚙️ Configuration

### Environment Setup
```swift
// Sources/Infrastructure/Configuration/Environment.swift
enum Environment {
    case development
    case staging
    case production
    
    var baseURL: String {
        switch self {
        case .development:
            return "https://api-dev.example.com"
        case .staging:
            return "https://api-staging.example.com"
        case .production:
            return "https://api.example.com"
        }
    }
    
    var timeoutInterval: TimeInterval {
        switch self {
        case .development:
            return 30
        case .staging:
            return 20
        case .production:
            return 15
        }
    }
}
```

### Dependency Injection
```swift
// Sources/Infrastructure/DI/DIContainer.swift
class DIContainer {
    static let shared = DIContainer()
    
    private init() {}
    
    func registerDependencies() {
        // Register repositories
        register(UserRepositoryProtocol.self) { container in
            UserRepository(
                remoteDataSource: container.resolve(UserRemoteDataSourceProtocol.self)!,
                localDataSource: container.resolve(UserLocalDataSourceProtocol.self)!
            )
        }
        
        // Register use cases
        register(GetUserUseCaseProtocol.self) { container in
            GetUserUseCase(repository: container.resolve(UserRepositoryProtocol.self)!)
        }
    }
}
```

---

## 🚀 Deployment

### Build Configuration
```bash
# Development build
xcodebuild -workspace ios-clean-architecture-template.xcworkspace -scheme ios-clean-architecture-template -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 15'

# Release build
xcodebuild -workspace ios-clean-architecture-template.xcworkspace -scheme ios-clean-architecture-template -configuration Release -destination 'generic/platform=iOS'
```

### Archive for App Store
```bash
# Archive the project
xcodebuild -workspace ios-clean-architecture-template.xcworkspace -scheme ios-clean-architecture-template -configuration Release -archivePath ios-clean-architecture-template.xcarchive archive

# Export IPA
xcodebuild -exportArchive -archivePath ios-clean-architecture-template.xcarchive -exportPath ./build -exportOptionsPlist ExportOptions.plist
```

---

## 📚 Next Steps

### 🎯 What to Learn Next
1. **Clean Architecture Principles** - Deep dive into domain, data, and presentation layers
2. **SOLID Principles** - Single Responsibility, Open/Closed, Liskov Substitution, Interface Segregation, Dependency Inversion
3. **SwiftUI Best Practices** - State management, navigation, and performance
4. **Testing Strategies** - Unit, integration, and UI testing
5. **Performance Optimization** - Memory management, network optimization, and UI responsiveness

### 📖 Recommended Resources
- [Clean Architecture by Robert C. Martin](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [SOLID Principles](https://en.wikipedia.org/wiki/SOLID)
- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui/)
- [iOS Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)

---

<div align="center">

**🌟 Ready to build professional iOS apps?**

**🚀 Start with this template and create amazing experiences!**

</div>
