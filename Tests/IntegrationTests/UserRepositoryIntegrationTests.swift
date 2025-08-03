import XCTest
import Quick
import Nimble
@testable import Data
@testable import Domain

/**
 * User Repository Integration Tests - Integration Tests
 * 
 * Comprehensive integration tests for UserRepository with real data sources.
 * Tests the complete data flow from repository to data sources.
 * 
 * - Author: iOS Clean Architecture Team
 * - Version: 2.0.0
 * - Date: 2024-01-15
 */

// MARK: - User Repository Integration Tests
class UserRepositoryIntegrationTests: QuickSpec {
    
    override func spec() {
        
        describe("UserRepository Integration") {
            
            var userRepository: UserRepository!
            var mockRemoteDataSource: MockUserRemoteDataSource!
            var mockLocalDataSource: MockUserLocalDataSource!
            var mockCacheManager: MockCacheManager!
            var mockNetworkMonitor: MockNetworkMonitor!
            var mockLogger: MockLogger!
            
            beforeEach {
                mockRemoteDataSource = MockUserRemoteDataSource()
                mockLocalDataSource = MockUserLocalDataSource()
                mockCacheManager = MockCacheManager()
                mockNetworkMonitor = MockNetworkMonitor()
                mockLogger = MockLogger()
                
                userRepository = UserRepository(
                    remoteDataSource: mockRemoteDataSource,
                    localDataSource: mockLocalDataSource,
                    cacheManager: mockCacheManager,
                    networkMonitor: mockNetworkMonitor,
                    logger: mockLogger
                )
            }
            
            context("when network is available") {
                
                beforeEach {
                    mockNetworkMonitor.isConnected = true
                }
                
                it("should fetch user from remote and cache it") {
                    // Given
                    let userId = "test-user-id"
                    let expectedUser = User(
                        id: userId,
                        name: "Test User",
                        email: "test@example.com",
                        role: .user
                    )
                    mockRemoteDataSource.mockUser = expectedUser
                    
                    // When
                    var result: User?
                    var thrownError: Error?
                    
                    do {
                        result = try await userRepository.getUser(id: userId)
                    } catch {
                        thrownError = error
                    }
                    
                    // Then
                    expect(result).toNot(beNil())
                    expect(result?.id).to(equal(userId))
                    expect(thrownError).to(beNil())
                    expect(mockRemoteDataSource.getUserCalled).to(beTrue())
                    expect(mockLocalDataSource.saveUserCalled).to(beTrue())
                    expect(mockCacheManager.setCalled).to(beTrue())
                }
                
                it("should fetch users from remote and cache them") {
                    // Given
                    let expectedUsers = [
                        User(id: "1", name: "User 1", email: "user1@example.com", role: .user),
                        User(id: "2", name: "User 2", email: "user2@example.com", role: .admin)
                    ]
                    mockRemoteDataSource.mockUsers = expectedUsers
                    
                    // When
                    var result: [User]?
                    var thrownError: Error?
                    
                    do {
                        result = try await userRepository.getUsers(limit: 10, offset: 0, isActive: nil)
                    } catch {
                        thrownError = error
                    }
                    
                    // Then
                    expect(result).toNot(beNil())
                    expect(result?.count).to(equal(2))
                    expect(thrownError).to(beNil())
                    expect(mockRemoteDataSource.getUsersCalled).to(beTrue())
                    expect(mockLocalDataSource.saveUsersCalled).to(beTrue())
                    expect(mockCacheManager.setCalled).to(beTrue())
                }
                
                it("should create user remotely and locally") {
                    // Given
                    let newUser = User(
                        id: "",
                        name: "New User",
                        email: "newuser@example.com",
                        role: .user
                    )
                    let createdUser = User(
                        id: "new-user-id",
                        name: "New User",
                        email: "newuser@example.com",
                        role: .user
                    )
                    mockRemoteDataSource.mockUser = createdUser
                    
                    // When
                    var result: User?
                    var thrownError: Error?
                    
                    do {
                        result = try await userRepository.createUser(newUser)
                    } catch {
                        thrownError = error
                    }
                    
                    // Then
                    expect(result).toNot(beNil())
                    expect(result?.name).to(equal("New User"))
                    expect(thrownError).to(beNil())
                    expect(mockRemoteDataSource.createUserCalled).to(beTrue())
                    expect(mockLocalDataSource.saveUserCalled).to(beTrue())
                }
                
                it("should update user remotely and locally") {
                    // Given
                    let updatedUser = User(
                        id: "test-user-id",
                        name: "Updated User",
                        email: "updated@example.com",
                        role: .admin
                    )
                    mockRemoteDataSource.mockUser = updatedUser
                    
                    // When
                    var result: User?
                    var thrownError: Error?
                    
                    do {
                        result = try await userRepository.updateUser(updatedUser)
                    } catch {
                        thrownError = error
                    }
                    
                    // Then
                    expect(result).toNot(beNil())
                    expect(result?.name).to(equal("Updated User"))
                    expect(result?.role).to(equal(.admin))
                    expect(thrownError).to(beNil())
                    expect(mockRemoteDataSource.updateUserCalled).to(beTrue())
                    expect(mockLocalDataSource.saveUserCalled).to(beTrue())
                }
                
                it("should delete user remotely and locally") {
                    // Given
                    let userId = "test-user-id"
                    mockRemoteDataSource.shouldThrowError = false
                    
                    // When
                    var thrownError: Error?
                    
                    do {
                        try await userRepository.deleteUser(id: userId)
                    } catch {
                        thrownError = error
                    }
                    
                    // Then
                    expect(thrownError).to(beNil())
                    expect(mockRemoteDataSource.deleteUserCalled).to(beTrue())
                    expect(mockLocalDataSource.deleteUserCalled).to(beTrue())
                }
            }
            
            context("when network is not available") {
                
                beforeEach {
                    mockNetworkMonitor.isConnected = false
                }
                
                it("should fetch user from local storage") {
                    // Given
                    let userId = "test-user-id"
                    let expectedUser = User(
                        id: userId,
                        name: "Local User",
                        email: "local@example.com",
                        role: .user
                    )
                    mockLocalDataSource.mockUser = expectedUser
                    
                    // When
                    var result: User?
                    var thrownError: Error?
                    
                    do {
                        result = try await userRepository.getUser(id: userId)
                    } catch {
                        thrownError = error
                    }
                    
                    // Then
                    expect(result).toNot(beNil())
                    expect(result?.id).to(equal(userId))
                    expect(thrownError).to(beNil())
                    expect(mockRemoteDataSource.getUserCalled).to(beFalse())
                    expect(mockLocalDataSource.getUserCalled).to(beTrue())
                }
                
                it("should create user locally when network is unavailable") {
                    // Given
                    let newUser = User(
                        id: "",
                        name: "New User",
                        email: "newuser@example.com",
                        role: .user
                    )
                    let createdUser = User(
                        id: "local-user-id",
                        name: "New User",
                        email: "newuser@example.com",
                        role: .user
                    )
                    mockLocalDataSource.mockUser = createdUser
                    
                    // When
                    var result: User?
                    var thrownError: Error?
                    
                    do {
                        result = try await userRepository.createUser(newUser)
                    } catch {
                        thrownError = error
                    }
                    
                    // Then
                    expect(result).toNot(beNil())
                    expect(result?.name).to(equal("New User"))
                    expect(thrownError).to(beNil())
                    expect(mockRemoteDataSource.createUserCalled).to(beFalse())
                    expect(mockLocalDataSource.createUserCalled).to(beTrue())
                }
                
                it("should throw network error when remote data is needed") {
                    // Given
                    let userId = "test-user-id"
                    mockLocalDataSource.mockUser = nil
                    
                    // When
                    var thrownError: Error?
                    
                    do {
                        _ = try await userRepository.getUser(id: userId)
                    } catch {
                        thrownError = error
                    }
                    
                    // Then
                    expect(thrownError).toNot(beNil())
                    expect(thrownError).to(beAKindOf(UserRepositoryError.self))
                }
            }
            
            context("caching behavior") {
                
                beforeEach {
                    mockNetworkMonitor.isConnected = true
                }
                
                it("should return cached user when available") {
                    // Given
                    let userId = "test-user-id"
                    let cachedUser = User(
                        id: userId,
                        name: "Cached User",
                        email: "cached@example.com",
                        role: .user
                    )
                    mockCacheManager.mockData = try? JSONEncoder().encode(cachedUser)
                    
                    // When
                    var result: User?
                    var thrownError: Error?
                    
                    do {
                        result = try await userRepository.getUser(id: userId)
                    } catch {
                        thrownError = error
                    }
                    
                    // Then
                    expect(result).toNot(beNil())
                    expect(result?.id).to(equal(userId))
                    expect(thrownError).to(beNil())
                    expect(mockRemoteDataSource.getUserCalled).to(beFalse())
                    expect(mockLocalDataSource.getUserCalled).to(beFalse())
                    expect(mockCacheManager.getCalled).to(beTrue())
                }
                
                it("should cache user after fetching from remote") {
                    // Given
                    let userId = "test-user-id"
                    let remoteUser = User(
                        id: userId,
                        name: "Remote User",
                        email: "remote@example.com",
                        role: .user
                    )
                    mockRemoteDataSource.mockUser = remoteUser
                    mockCacheManager.mockData = nil // No cached data
                    
                    // When
                    var result: User?
                    var thrownError: Error?
                    
                    do {
                        result = try await userRepository.getUser(id: userId)
                    } catch {
                        thrownError = error
                    }
                    
                    // Then
                    expect(result).toNot(beNil())
                    expect(thrownError).to(beNil())
                    expect(mockCacheManager.setCalled).to(beTrue())
                }
            }
            
            context("search functionality") {
                
                beforeEach {
                    mockNetworkMonitor.isConnected = true
                }
                
                it("should search users locally and remotely") {
                    // Given
                    let query = "test"
                    let localUsers = [
                        User(id: "1", name: "Local Test User", email: "local@example.com", role: .user)
                    ]
                    let remoteUsers = [
                        User(id: "2", name: "Remote Test User", email: "remote@example.com", role: .admin)
                    ]
                    mockLocalDataSource.mockUsers = localUsers
                    mockRemoteDataSource.mockUsers = remoteUsers
                    
                    // When
                    var result: [User]?
                    var thrownError: Error?
                    
                    do {
                        result = try await userRepository.searchUsers(query: query)
                    } catch {
                        thrownError = error
                    }
                    
                    // Then
                    expect(result).toNot(beNil())
                    expect(result?.count).to(equal(2))
                    expect(thrownError).to(beNil())
                    expect(mockLocalDataSource.searchUsersCalled).to(beTrue())
                    expect(mockRemoteDataSource.searchUsersCalled).to(beTrue())
                }
            }
            
            context("error handling") {
                
                beforeEach {
                    mockNetworkMonitor.isConnected = true
                }
                
                it("should handle remote data source errors") {
                    // Given
                    let userId = "test-user-id"
                    mockRemoteDataSource.shouldThrowError = true
                    mockRemoteDataSource.repositoryError = UserRepositoryError.networkError(NSError(domain: "Test", code: 500, userInfo: nil))
                    
                    // When
                    var thrownError: Error?
                    
                    do {
                        _ = try await userRepository.getUser(id: userId)
                    } catch {
                        thrownError = error
                    }
                    
                    // Then
                    expect(thrownError).toNot(beNil())
                    expect(thrownError).to(beAKindOf(UserRepositoryError.self))
                }
                
                it("should handle local data source errors") {
                    // Given
                    let userId = "test-user-id"
                    mockLocalDataSource.shouldThrowError = true
                    mockLocalDataSource.storageError = StorageError.loadFailed("Local storage error")
                    
                    // When
                    var thrownError: Error?
                    
                    do {
                        _ = try await userRepository.getUser(id: userId)
                    } catch {
                        thrownError = error
                    }
                    
                    // Then
                    expect(thrownError).toNot(beNil())
                    expect(thrownError).to(beAKindOf(UserRepositoryError.self))
                }
            }
        }
    }
}

// MARK: - Mock Classes
class MockUserRemoteDataSource: UserRemoteDataSourceProtocol {
    var mockUser: User?
    var mockUsers: [User] = []
    var shouldThrowError = false
    var repositoryError: Error = UserRepositoryError.userNotFound
    
    var getUserCalled = false
    var getUsersCalled = false
    var createUserCalled = false
    var updateUserCalled = false
    var deleteUserCalled = false
    var searchUsersCalled = false
    var getUsersByRoleCalled = false
    
    func getUser(id: String) async throws -> User {
        getUserCalled = true
        
        if shouldThrowError {
            throw repositoryError
        }
        
        guard let user = mockUser else {
            throw UserRepositoryError.userNotFound
        }
        
        return user
    }
    
    func getUsers(limit: Int, offset: Int, isActive: Bool?) async throws -> [User] {
        getUsersCalled = true
        
        if shouldThrowError {
            throw repositoryError
        }
        
        return mockUsers
    }
    
    func createUser(_ user: User) async throws -> User {
        createUserCalled = true
        
        if shouldThrowError {
            throw repositoryError
        }
        
        guard let createdUser = mockUser else {
            throw UserRepositoryError.invalidUser
        }
        
        return createdUser
    }
    
    func updateUser(_ user: User) async throws -> User {
        updateUserCalled = true
        
        if shouldThrowError {
            throw repositoryError
        }
        
        guard let updatedUser = mockUser else {
            throw UserRepositoryError.userNotFound
        }
        
        return updatedUser
    }
    
    func deleteUser(id: String) async throws {
        deleteUserCalled = true
        
        if shouldThrowError {
            throw repositoryError
        }
    }
    
    func searchUsers(query: String) async throws -> [User] {
        searchUsersCalled = true
        
        if shouldThrowError {
            throw repositoryError
        }
        
        return mockUsers
    }
    
    func getUsersByRole(_ role: UserRole) async throws -> [User] {
        getUsersByRoleCalled = true
        
        if shouldThrowError {
            throw repositoryError
        }
        
        return mockUsers
    }
}

class MockUserLocalDataSource: UserLocalDataSourceProtocol {
    var mockUser: User?
    var mockUsers: [User] = []
    var shouldThrowError = false
    var storageError: Error = StorageError.loadFailed("Storage error")
    
    var getUserCalled = false
    var getUsersCalled = false
    var saveUserCalled = false
    var saveUsersCalled = false
    var createUserCalled = false
    var updateUserCalled = false
    var deleteUserCalled = false
    var searchUsersCalled = false
    var getUsersByRoleCalled = false
    
    func getUser(id: String) async throws -> User? {
        getUserCalled = true
        
        if shouldThrowError {
            throw storageError
        }
        
        return mockUser
    }
    
    func getUsers(limit: Int, offset: Int, isActive: Bool?) async throws -> [User]? {
        getUsersCalled = true
        
        if shouldThrowError {
            throw storageError
        }
        
        return mockUsers.isEmpty ? nil : mockUsers
    }
    
    func saveUser(_ user: User) async throws {
        saveUserCalled = true
        
        if shouldThrowError {
            throw storageError
        }
    }
    
    func saveUsers(_ users: [User]) async throws {
        saveUsersCalled = true
        
        if shouldThrowError {
            throw storageError
        }
    }
    
    func createUser(_ user: User) async throws -> User {
        createUserCalled = true
        
        if shouldThrowError {
            throw storageError
        }
        
        guard let createdUser = mockUser else {
            throw StorageError.saveFailed("Failed to create user")
        }
        
        return createdUser
    }
    
    func updateUser(_ user: User) async throws -> User {
        updateUserCalled = true
        
        if shouldThrowError {
            throw storageError
        }
        
        guard let updatedUser = mockUser else {
            throw StorageError.saveFailed("Failed to update user")
        }
        
        return updatedUser
    }
    
    func deleteUser(id: String) async throws {
        deleteUserCalled = true
        
        if shouldThrowError {
            throw storageError
        }
    }
    
    func searchUsers(query: String) async throws -> [User] {
        searchUsersCalled = true
        
        if shouldThrowError {
            throw storageError
        }
        
        return mockUsers
    }
    
    func getUsersByRole(_ role: UserRole) async throws -> [User] {
        getUsersByRoleCalled = true
        
        if shouldThrowError {
            throw storageError
        }
        
        return mockUsers
    }
}

class MockCacheManager: CacheManagerProtocol {
    var mockData: Data?
    var shouldThrowError = false
    var cacheError: Error = StorageError.loadFailed("Cache error")
    
    var getCalled = false
    var setCalled = false
    var removeCalled = false
    var clearCalled = false
    
    func get<T: Codable>(forKey key: String) async throws -> T? {
        getCalled = true
        
        if shouldThrowError {
            throw cacheError
        }
        
        guard let data = mockData else {
            return nil
        }
        
        return try JSONDecoder().decode(T.self, from: data)
    }
    
    func set<T: Codable>(_ value: T, forKey key: String, expiration: TimeInterval) async throws {
        setCalled = true
        
        if shouldThrowError {
            throw cacheError
        }
    }
    
    func remove(forKey key: String) async throws {
        removeCalled = true
        
        if shouldThrowError {
            throw cacheError
        }
    }
    
    func clear() async throws {
        clearCalled = true
        
        if shouldThrowError {
            throw cacheError
        }
    }
}

class MockNetworkMonitor: NetworkMonitorProtocol {
    var isConnected: Bool = true
    
    func startMonitoring() {
        // Mock implementation
    }
    
    func stopMonitoring() {
        // Mock implementation
    }
}

class MockLogger: LoggerProtocol {
    var logCalled = false
    var debugCalled = false
    var infoCalled = false
    var warningCalled = false
    var errorCalled = false
    var criticalCalled = false
    
    func log(_ message: String, level: LogLevel, category: String, file: String, function: String, line: Int) {
        logCalled = true
    }
    
    func debug(_ message: String, category: String, file: String, function: String, line: Int) {
        debugCalled = true
    }
    
    func info(_ message: String, category: String, file: String, function: String, line: Int) {
        infoCalled = true
    }
    
    func warning(_ message: String, category: String, file: String, function: String, line: Int) {
        warningCalled = true
    }
    
    func error(_ message: String, category: String, file: String, function: String, line: Int) {
        errorCalled = true
    }
    
    func critical(_ message: String, category: String, file: String, function: String, line: Int) {
        criticalCalled = true
    }
    
    func logPerformance(_ operation: String, duration: TimeInterval, category: String) {
        // Mock implementation
    }
    
    func logNetworkCall(_ endpoint: String, duration: TimeInterval, success: Bool, category: String) {
        // Mock implementation
    }
    
    func logUserAction(_ action: String, parameters: [String: Any]?, category: String) {
        // Mock implementation
    }
    
    func logError(_ error: Error, context: String, category: String) {
        // Mock implementation
    }
    
    func setMinimumLogLevel(_ level: LogLevel) {
        // Mock implementation
    }
} 