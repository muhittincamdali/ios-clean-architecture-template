# 📚 API Reference

Complete API documentation for iOS Clean Architecture Template.

## 📋 Table of Contents

- [Domain Layer](#domain-layer)
- [Data Layer](#data-layer)
- [Presentation Layer](#presentation-layer)
- [Infrastructure Layer](#infrastructure-layer)
- [Error Handling](#error-handling)

## 🏗️ Domain Layer

The core business logic layer containing entities, use cases, and protocols.

### Entities

#### User Entity
```swift
struct User: Codable, Identifiable, Equatable {
    let id: String
    let name: String
    let email: String
    let avatarURL: String?
    let createdAt: Date
    let updatedAt: Date
    let isActive: Bool
    let role: UserRole
}
```

#### UserRole Enum
```swift
enum UserRole: String, Codable, CaseIterable {
    case user = "user"
    case moderator = "moderator"
    case admin = "admin"
}
```

### Use Cases

#### GetUserUseCase
```swift
protocol GetUserUseCaseProtocol {
    func execute(id: String) async throws -> User
}

struct GetUserUseCase: GetUserUseCaseProtocol {
    private let repository: UserRepositoryProtocol
    private let validator: UserValidatorProtocol
    
    init(repository: UserRepositoryProtocol, validator: UserValidatorProtocol) {
        self.repository = repository
        self.validator = validator
    }
    
    func execute(id: String) async throws -> User {
        // Validate input
        try validator.validateUserID(id)
        
        // Check if user exists
        guard try await repository.userExists(id: id) else {
            throw RepositoryError.userNotFound
        }
        
        // Get user
        let user = try await repository.getUser(id: id)
        
        // Validate user data
        try validator.validateUser(user)
        
        return user
    }
}
```

#### GetUsersUseCase
```swift
protocol GetUsersUseCaseProtocol {
    func execute() async throws -> [User]
}

struct GetUsersUseCase: GetUsersUseCaseProtocol {
    private let repository: UserRepositoryProtocol
    
    init(repository: UserRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute() async throws -> [User] {
        return try await repository.getUsers()
    }
}
```

### Protocols

#### UserRepositoryProtocol
```swift
protocol UserRepositoryProtocol {
    func getUser(id: String) async throws -> User
    func getUsers() async throws -> [User]
    func createUser(_ user: User) async throws -> User
    func updateUser(_ user: User) async throws -> User
    func deleteUser(id: String) async throws -> Bool
    func searchUsers(query: String) async throws -> [User]
    func getUsersByRole(_ role: UserRole) async throws -> [User]
    func userExists(id: String) async throws -> Bool
    func getUserCount() async throws -> Int
}
```

#### UserValidatorProtocol
```swift
protocol UserValidatorProtocol {
    func validateUserID(_ id: String) throws
    func validateUser(_ user: User) throws
    func validateEmail(_ email: String) throws
}
```

## 📊 Data Layer

The data access layer containing repositories, data sources, and models.

### Data Transfer Objects (DTOs)

#### UserDTO
```swift
struct UserDTO: Codable, Equatable {
    let id: String
    let name: String
    let email: String
    let avatarURL: String?
    let createdAt: String
    let updatedAt: String
    let isActive: Bool
    let role: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case email
        case avatarURL = "avatar_url"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case isActive = "is_active"
        case role
    }
    
    func toDomain() -> User {
        return User(
            id: id,
            name: name,
            email: email,
            avatarURL: avatarURL,
            createdAt: DateFormatter.iso8601.date(from: createdAt) ?? Date(),
            updatedAt: DateFormatter.iso8601.date(from: updatedAt) ?? Date(),
            isActive: isActive,
            role: UserRole(rawValue: role) ?? .user
        )
    }
    
    static func fromDomain(_ user: User) -> UserDTO {
        return UserDTO(
            id: user.id,
            name: user.name,
            email: user.email,
            avatarURL: user.avatarURL,
            createdAt: DateFormatter.iso8601.string(from: user.createdAt),
            updatedAt: DateFormatter.iso8601.string(from: user.updatedAt),
            isActive: user.isActive,
            role: user.role.rawValue
        )
    }
}
```

### API Models

#### API Response Models
```swift
struct UsersResponse: Codable {
    let users: [UserDTO]
    let total: Int
    let page: Int
    let limit: Int
}

struct UserResponse: Codable {
    let user: UserDTO
}

struct CreateUserRequest: Codable {
    let name: String
    let email: String
    let role: String
}

struct UpdateUserRequest: Codable {
    let name: String?
    let email: String?
    let isActive: Bool?
    let role: String?
}
```

### Data Sources

#### Remote Data Source
```swift
protocol UserRemoteDataSourceProtocol {
    func getUser(id: String) async throws -> UserDTO
    func getUsers() async throws -> [UserDTO]
    func createUser(_ user: CreateUserRequest) async throws -> UserDTO
    func updateUser(id: String, _ user: UpdateUserRequest) async throws -> UserDTO
    func deleteUser(id: String) async throws -> Bool
    func searchUsers(query: String) async throws -> [UserDTO]
    func getUsersByRole(_ role: String) async throws -> [UserDTO]
    func getUserCount() async throws -> Int
}

class UserRemoteDataSource: UserRemoteDataSourceProtocol {
    private let networkService: NetworkServiceProtocol
    private let apiConfig: APIConfigProtocol
    
    init(networkService: NetworkServiceProtocol, apiConfig: APIConfigProtocol) {
        self.networkService = networkService
        self.apiConfig = apiConfig
    }
    
    func getUser(id: String) async throws -> UserDTO {
        let endpoint = APIEndpoint.getUser(id: id)
        let response: UserResponse = try await networkService.request(endpoint)
        return response.user
    }
    
    func getUsers() async throws -> [UserDTO] {
        let endpoint = APIEndpoint.getUsers
        let response: UsersResponse = try await networkService.request(endpoint)
        return response.users
    }
    
    func createUser(_ user: CreateUserRequest) async throws -> UserDTO {
        let endpoint = APIEndpoint.createUser
        let response: UserResponse = try await networkService.request(endpoint, body: user)
        return response.user
    }
    
    func updateUser(id: String, _ user: UpdateUserRequest) async throws -> UserDTO {
        let endpoint = APIEndpoint.updateUser(id: id)
        let response: UserResponse = try await networkService.request(endpoint, body: user)
        return response.user
    }
    
    func deleteUser(id: String) async throws -> Bool {
        let endpoint = APIEndpoint.deleteUser(id: id)
        let response: DeleteResponse = try await networkService.request(endpoint)
        return response.success
    }
    
    func searchUsers(query: String) async throws -> [UserDTO] {
        let endpoint = APIEndpoint.searchUsers(query: query)
        let response: UsersResponse = try await networkService.request(endpoint)
        return response.users
    }
    
    func getUsersByRole(_ role: String) async throws -> [UserDTO] {
        let endpoint = APIEndpoint.getUsersByRole(role: role)
        let response: UsersResponse = try await networkService.request(endpoint)
        return response.users
    }
    
    func getUserCount() async throws -> Int {
        let endpoint = APIEndpoint.getUserCount
        let response: CountResponse = try await networkService.request(endpoint)
        return response.count
    }
}
```

#### Local Data Source
```swift
protocol UserLocalDataSourceProtocol {
    func saveUser(_ user: UserDTO) throws
    func getUser(id: String) throws -> UserDTO?
    func getUsers() throws -> [UserDTO]
    func deleteUser(id: String) throws
    func clearAll() throws
}

class UserLocalDataSource: UserLocalDataSourceProtocol {
    private let storage: StorageProtocol
    
    init(storage: StorageProtocol) {
        self.storage = storage
    }
    
    func saveUser(_ user: UserDTO) throws {
        let key = "user_\(user.id)"
        let data = try JSONEncoder().encode(user)
        try storage.save(data, forKey: key)
    }
    
    func getUser(id: String) throws -> UserDTO? {
        let key = "user_\(id)"
        guard let data = try storage.getData(forKey: key) else {
            return nil
        }
        return try JSONDecoder().decode(UserDTO.self, from: data)
    }
    
    func getUsers() throws -> [UserDTO] {
        let pattern = "user_*"
        let keys = try storage.getKeys(matching: pattern)
        var users: [UserDTO] = []
        
        for key in keys {
            if let data = try storage.getData(forKey: key),
               let user = try? JSONDecoder().decode(UserDTO.self, from: data) {
                users.append(user)
            }
        }
        
        return users
    }
    
    func deleteUser(id: String) throws {
        let key = "user_\(id)"
        try storage.delete(forKey: key)
    }
    
    func clearAll() throws {
        let pattern = "user_*"
        let keys = try storage.getKeys(matching: pattern)
        
        for key in keys {
            try storage.delete(forKey: key)
        }
    }
}
```

### Repository Implementation

```swift
class UserRepository: UserRepositoryProtocol {
    private let remoteDataSource: UserRemoteDataSourceProtocol
    private let localDataSource: UserLocalDataSourceProtocol
    private let networkMonitor: NetworkMonitorProtocol
    
    init(remoteDataSource: UserRemoteDataSourceProtocol,
         localDataSource: UserLocalDataSourceProtocol,
         networkMonitor: NetworkMonitorProtocol) {
        self.remoteDataSource = remoteDataSource
        self.localDataSource = localDataSource
        self.networkMonitor = networkMonitor
    }
    
    func getUser(id: String) async throws -> User {
        // Try local first
        if let localUser = try localDataSource.getUser(id: id) {
            return localUser.toDomain()
        }
        
        // If not in local and no network, throw error
        guard networkMonitor.isConnected else {
            throw RepositoryError.noNetworkConnection
        }
        
        // Fetch from remote
        let remoteUser = try await remoteDataSource.getUser(id: id)
        
        // Save to local
        try localDataSource.saveUser(remoteUser)
        
        return remoteUser.toDomain()
    }
    
    func getUsers() async throws -> [User] {
        // Try local first
        let localUsers = try localDataSource.getUsers()
        
        // If network available, fetch from remote
        if networkMonitor.isConnected {
            do {
                let remoteUsers = try await remoteDataSource.getUsers()
                
                // Update local cache
                for user in remoteUsers {
                    try localDataSource.saveUser(user)
                }
                
                return remoteUsers.map { $0.toDomain() }
            } catch {
                // If remote fails, return local data
                return localUsers.map { $0.toDomain() }
            }
        }
        
        return localUsers.map { $0.toDomain() }
    }
    
    func createUser(_ user: User) async throws -> User {
        guard networkMonitor.isConnected else {
            throw RepositoryError.noNetworkConnection
        }
        
        let request = CreateUserRequest(
            name: user.name,
            email: user.email,
            role: user.role.rawValue
        )
        
        let createdUser = try await remoteDataSource.createUser(request)
        
        // Save to local
        try localDataSource.saveUser(createdUser)
        
        return createdUser.toDomain()
    }
    
    func updateUser(_ user: User) async throws -> User {
        guard networkMonitor.isConnected else {
            throw RepositoryError.noNetworkConnection
        }
        
        let request = UpdateUserRequest(
            name: user.name,
            email: user.email,
            isActive: user.isActive,
            role: user.role.rawValue
        )
        
        let updatedUser = try await remoteDataSource.updateUser(id: user.id, request)
        
        // Update local cache
        try localDataSource.saveUser(updatedUser)
        
        return updatedUser.toDomain()
    }
    
    func deleteUser(id: String) async throws -> Bool {
        guard networkMonitor.isConnected else {
            throw RepositoryError.noNetworkConnection
        }
        
        let success = try await remoteDataSource.deleteUser(id: id)
        
        if success {
            try localDataSource.deleteUser(id: id)
        }
        
        return success
    }
    
    func searchUsers(query: String) async throws -> [User] {
        guard networkMonitor.isConnected else {
            throw RepositoryError.noNetworkConnection
        }
        
        let users = try await remoteDataSource.searchUsers(query: query)
        return users.map { $0.toDomain() }
    }
    
    func getUsersByRole(_ role: UserRole) async throws -> [User] {
        guard networkMonitor.isConnected else {
            throw RepositoryError.noNetworkConnection
        }
        
        let users = try await remoteDataSource.getUsersByRole(role.rawValue)
        return users.map { $0.toDomain() }
    }
    
    func userExists(id: String) async throws -> Bool {
        return try await getUser(id: id) != nil
    }
    
    func getUserCount() async throws -> Int {
        guard networkMonitor.isConnected else {
            throw RepositoryError.noNetworkConnection
        }
        
        return try await remoteDataSource.getUserCount()
    }
}
```

## 🎨 Presentation Layer

The UI layer containing views, view models, and coordinators.

### View Models

#### UserViewModel
```swift
@MainActor
class UserViewModel: ObservableObject {
    @Published var users: [User] = []
    @Published var isLoading = false
    @Published var error: Error?
    @Published var searchQuery = ""
    @Published var selectedRole: UserRole?
    
    private let getUserUseCase: GetUserUseCaseProtocol
    private let getUsersUseCase: GetUsersUseCaseProtocol
    private let createUserUseCase: CreateUserUseCaseProtocol
    private let updateUserUseCase: UpdateUserUseCaseProtocol
    private let deleteUserUseCase: DeleteUserUseCaseProtocol
    private let searchUsersUseCase: SearchUsersUseCaseProtocol
    
    init(getUserUseCase: GetUserUseCaseProtocol,
         getUsersUseCase: GetUsersUseCaseProtocol,
         createUserUseCase: CreateUserUseCaseProtocol,
         updateUserUseCase: UpdateUserUseCaseProtocol,
         deleteUserUseCase: DeleteUserUseCaseProtocol,
         searchUsersUseCase: SearchUsersUseCaseProtocol) {
        self.getUserUseCase = getUserUseCase
        self.getUsersUseCase = getUsersUseCase
        self.createUserUseCase = createUserUseCase
        self.updateUserUseCase = updateUserUseCase
        self.deleteUserUseCase = deleteUserUseCase
        self.searchUsersUseCase = searchUsersUseCase
    }
    
    func loadUsers() async {
        isLoading = true
        error = nil
        
        do {
            users = try await getUsersUseCase.execute()
        } catch {
            self.error = error
        }
        
        isLoading = false
    }
    
    func loadUser(id: String) async {
        isLoading = true
        error = nil
        
        do {
            let user = try await getUserUseCase.execute(id: id)
            // Handle single user loading
        } catch {
            self.error = error
        }
        
        isLoading = false
    }
    
    func createUser(_ user: User) async {
        isLoading = true
        error = nil
        
        do {
            let createdUser = try await createUserUseCase.execute(user: user)
            users.append(createdUser)
        } catch {
            self.error = error
        }
        
        isLoading = false
    }
    
    func updateUser(_ user: User) async {
        isLoading = true
        error = nil
        
        do {
            let updatedUser = try await updateUserUseCase.execute(user: user)
            if let index = users.firstIndex(where: { $0.id == updatedUser.id }) {
                users[index] = updatedUser
            }
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
                users.removeAll { $0.id == id }
            }
        } catch {
            self.error = error
        }
        
        isLoading = false
    }
    
    func searchUsers() async {
        guard !searchQuery.isEmpty else {
            await loadUsers()
            return
        }
        
        isLoading = true
        error = nil
        
        do {
            users = try await searchUsersUseCase.execute(query: searchQuery)
        } catch {
            self.error = error
        }
        
        isLoading = false
    }
    
    func filterByRole(_ role: UserRole?) {
        selectedRole = role
        // Apply filtering logic
    }
}
```

### Views

#### UserView
```swift
struct UserView: View {
    @StateObject private var viewModel: UserViewModel
    @State private var showingCreateUser = false
    @State private var showingUserDetail = false
    @State private var selectedUser: User?
    
    init(viewModel: UserViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Search Bar
                SearchBar(text: $viewModel.searchQuery)
                    .onChange(of: viewModel.searchQuery) { _ in
                        Task {
                            await viewModel.searchUsers()
                        }
                    }
                
                // Filter Picker
                FilterPicker(selectedRole: $viewModel.selectedRole)
                    .onChange(of: viewModel.selectedRole) { _ in
                        viewModel.filterByRole(viewModel.selectedRole)
                    }
                
                // User List
                if viewModel.isLoading {
                    LoadingView()
                } else if let error = viewModel.error {
                    ErrorView(error: error) {
                        Task {
                            await viewModel.loadUsers()
                        }
                    }
                } else if viewModel.users.isEmpty {
                    EmptyStateView()
                } else {
                    UserListView(
                        users: viewModel.users,
                        onUserTap: { user in
                            selectedUser = user
                            showingUserDetail = true
                        },
                        onDeleteUser: { user in
                            Task {
                                await viewModel.deleteUser(id: user.id)
                            }
                        }
                    )
                }
            }
            .navigationTitle("Users")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add User") {
                        showingCreateUser = true
                    }
                }
            }
            .refreshable {
                await viewModel.loadUsers()
            }
            .sheet(isPresented: $showingCreateUser) {
                CreateUserView(viewModel: viewModel)
            }
            .sheet(isPresented: $showingUserDetail) {
                if let user = selectedUser {
                    UserDetailView(user: user, viewModel: viewModel)
                }
            }
        }
        .task {
            await viewModel.loadUsers()
        }
    }
}
```

## 🔧 Infrastructure Layer

The infrastructure layer containing network services, storage, and utilities.

### Network Service

```swift
protocol NetworkServiceProtocol {
    func request<T: Codable>(_ endpoint: APIEndpoint) async throws -> T
    func request<T: Codable, U: Codable>(_ endpoint: APIEndpoint, body: U) async throws -> T
}

class NetworkService: NetworkServiceProtocol {
    private let session: URLSession
    private let baseURL: String
    
    init(session: URLSession = .shared, baseURL: String) {
        self.session = session
        self.baseURL = baseURL
    }
    
    func request<T: Codable>(_ endpoint: APIEndpoint) async throws -> T {
        let url = URL(string: baseURL + endpoint.path)!
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        guard 200...299 ~= httpResponse.statusCode else {
            throw NetworkError.httpError(statusCode: httpResponse.statusCode)
        }
        
        return try JSONDecoder().decode(T.self, from: data)
    }
    
    func request<T: Codable, U: Codable>(_ endpoint: APIEndpoint, body: U) async throws -> T {
        let url = URL(string: baseURL + endpoint.path)!
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(body)
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        guard 200...299 ~= httpResponse.statusCode else {
            throw NetworkError.httpError(statusCode: httpResponse.statusCode)
        }
        
        return try JSONDecoder().decode(T.self, from: data)
    }
}
```

### Storage Service

```swift
protocol StorageProtocol {
    func save(_ data: Data, forKey key: String) throws
    func getData(forKey key: String) throws -> Data?
    func delete(forKey key: String) throws
    func getKeys(matching pattern: String) throws -> [String]
}

class KeychainStorage: StorageProtocol {
    func save(_ data: Data, forKey key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        if status == errSecDuplicateItem {
            let updateQuery: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrAccount as String: key
            ]
            
            let attributes: [String: Any] = [
                kSecValueData as String: data
            ]
            
            let updateStatus = SecItemUpdate(updateQuery as CFDictionary, attributes as CFDictionary)
            
            if updateStatus != errSecSuccess {
                throw StorageError.saveFailed
            }
        } else if status != errSecSuccess {
            throw StorageError.saveFailed
        }
    }
    
    func getData(forKey key: String) throws -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        if status == errSecItemNotFound {
            return nil
        } else if status != errSecSuccess {
            throw StorageError.retrieveFailed
        }
        
        return result as? Data
    }
    
    func delete(forKey key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        
        if status != errSecSuccess && status != errSecItemNotFound {
            throw StorageError.deleteFailed
        }
    }
    
    func getKeys(matching pattern: String) throws -> [String] {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecReturnAttributes as String: true,
            kSecMatchLimit as String: kSecMatchLimitAll
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        if status == errSecItemNotFound {
            return []
        } else if status != errSecSuccess {
            throw StorageError.retrieveFailed
        }
        
        guard let items = result as? [[String: Any]] else {
            return []
        }
        
        return items.compactMap { item in
            item[kSecAttrAccount as String] as? String
        }.filter { key in
            // Simple pattern matching - can be enhanced
            key.contains(pattern.replacingOccurrences(of: "*", with: ""))
        }
    }
}
```

## ❌ Error Handling

### Error Types

```swift
enum RepositoryError: Error {
    case userNotFound
    case networkError
    case noNetworkConnection
    case invalidData
    case serverError
}

enum NetworkError: Error {
    case invalidResponse
    case httpError(statusCode: Int)
    case decodingError
    case encodingError
}

enum StorageError: Error {
    case saveFailed
    case retrieveFailed
    case deleteFailed
}

enum ValidationError: Error {
    case invalidUserID
    case invalidEmail
    case invalidUserData
    case emptyName
    case invalidRole
}
```

### Error Handling Example

```swift
class ErrorHandler {
    func handleError(_ error: Error) {
        switch error {
        case let repositoryError as RepositoryError:
            handleRepositoryError(repositoryError)
        case let networkError as NetworkError:
            handleNetworkError(networkError)
        case let storageError as StorageError:
            handleStorageError(storageError)
        case let validationError as ValidationError:
            handleValidationError(validationError)
        default:
            handleGenericError(error)
        }
    }
    
    private func handleRepositoryError(_ error: RepositoryError) {
        switch error {
        case .userNotFound:
            // Show user not found message
            break
        case .networkError:
            // Show network error message
            break
        case .noNetworkConnection:
            // Show offline message
            break
        case .invalidData:
            // Show data error message
            break
        case .serverError:
            // Show server error message
            break
        }
    }
    
    private func handleNetworkError(_ error: NetworkError) {
        switch error {
        case .invalidResponse:
            // Show invalid response message
            break
        case .httpError(let statusCode):
            // Show HTTP error message with status code
            break
        case .decodingError:
            // Show decoding error message
            break
        case .encodingError:
            // Show encoding error message
            break
        }
    }
    
    private func handleStorageError(_ error: StorageError) {
        switch error {
        case .saveFailed:
            // Show save failed message
            break
        case .retrieveFailed:
            // Show retrieve failed message
            break
        case .deleteFailed:
            // Show delete failed message
            break
        }
    }
    
    private func handleValidationError(_ error: ValidationError) {
        switch error {
        case .invalidUserID:
            // Show invalid user ID message
            break
        case .invalidEmail:
            // Show invalid email message
            break
        case .invalidUserData:
            // Show invalid user data message
            break
        case .emptyName:
            // Show empty name message
            break
        case .invalidRole:
            // Show invalid role message
            break
        }
    }
    
    private func handleGenericError(_ error: Error) {
        // Show generic error message
    }
}
```

---

**For more information, visit our [GitHub repository](https://github.com/muhittincamdali/ios-clean-architecture-template).** 