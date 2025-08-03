import XCTest
import Quick
import Nimble
@testable import Domain
@testable import Data

/**
 * User Use Case Tests - Unit Tests
 * 
 * Comprehensive test suite for all user-related use cases:
 * - GetUserUseCase
 * - GetUsersUseCase
 * - CreateUserUseCase
 * - UpdateUserUseCase
 * - DeleteUserUseCase
 * - SearchUsersUseCase
 * 
 * - Author: iOS Clean Architecture Team
 * - Version: 2.0.0
 * - Date: 2024-01-15
 */

// MARK: - User Use Case Tests
class UserUseCaseTests: QuickSpec {
    
    override func spec() {
        
        describe("GetUserUseCase") {
            
            var getUserUseCase: GetUserUseCase!
            var mockRepository: MockUserRepository!
            var mockValidator: MockUserValidator!
            
            beforeEach {
                mockRepository = MockUserRepository()
                mockValidator = MockUserValidator()
                getUserUseCase = GetUserUseCase(repository: mockRepository, validator: mockValidator)
            }
            
            context("when user exists and is valid") {
                
                it("should return user successfully") {
                    // Given
                    let userId = "123"
                    let expectedUser = User(
                        id: userId,
                        name: "John Doe",
                        email: "john@example.com",
                        role: .user
                    )
                    mockRepository.mockUser = expectedUser
                    mockRepository.shouldThrowError = false
                    mockValidator.shouldThrowError = false
                    
                    // When
                    var result: User?
                    var thrownError: Error?
                    
                    do {
                        result = try await getUserUseCase.execute(id: userId)
                    } catch {
                        thrownError = error
                    }
                    
                    // Then
                    expect(result).toNot(beNil())
                    expect(result?.id).to(equal(userId))
                    expect(result?.name).to(equal("John Doe"))
                    expect(thrownError).to(beNil())
                    expect(mockRepository.getUserCalled).to(beTrue())
                    expect(mockRepository.getUserId).to(equal(userId))
                    expect(mockValidator.validateUserIdCalled).to(beTrue())
                    expect(mockValidator.validateUserCalled).to(beTrue())
                }
            }
            
            context("when user ID is invalid") {
                
                it("should throw validation error") {
                    // Given
                    let invalidUserId = ""
                    mockValidator.shouldThrowError = true
                    mockValidator.validationError = ValidationError.invalidUserId("User ID cannot be empty")
                    
                    // When
                    var thrownError: Error?
                    
                    do {
                        _ = try await getUserUseCase.execute(id: invalidUserId)
                    } catch {
                        thrownError = error
                    }
                    
                    // Then
                    expect(thrownError).toNot(beNil())
                    expect(thrownError).to(beAKindOf(ValidationError.self))
                    expect(mockRepository.getUserCalled).to(beFalse())
                }
            }
            
            context("when user does not exist") {
                
                it("should throw user not found error") {
                    // Given
                    let userId = "999"
                    mockRepository.shouldThrowError = true
                    mockRepository.repositoryError = RepositoryError.userNotFound
                    mockValidator.shouldThrowError = false
                    
                    // When
                    var thrownError: Error?
                    
                    do {
                        _ = try await getUserUseCase.execute(id: userId)
                    } catch {
                        thrownError = error
                    }
                    
                    // Then
                    expect(thrownError).toNot(beNil())
                    expect(thrownError).to(beAKindOf(RepositoryError.self))
                    expect(mockRepository.getUserCalled).to(beTrue())
                }
            }
            
            context("when user data is invalid") {
                
                it("should throw validation error") {
                    // Given
                    let userId = "123"
                    let invalidUser = User(
                        id: userId,
                        name: "",
                        email: "invalid-email",
                        role: .user
                    )
                    mockRepository.mockUser = invalidUser
                    mockRepository.shouldThrowError = false
                    mockValidator.shouldThrowError = true
                    mockValidator.validationError = ValidationError.invalidUser("User data is invalid")
                    
                    // When
                    var thrownError: Error?
                    
                    do {
                        _ = try await getUserUseCase.execute(id: userId)
                    } catch {
                        thrownError = error
                    }
                    
                    // Then
                    expect(thrownError).toNot(beNil())
                    expect(thrownError).to(beAKindOf(ValidationError.self))
                }
            }
        }
        
        describe("GetUsersUseCase") {
            
            var getUsersUseCase: GetUsersUseCase!
            var mockRepository: MockUserRepository!
            
            beforeEach {
                mockRepository = MockUserRepository()
                getUsersUseCase = GetUsersUseCase(repository: mockRepository)
            }
            
            context("when users exist") {
                
                it("should return list of users") {
                    // Given
                    let expectedUsers = [
                        User(id: "1", name: "John Doe", email: "john@example.com", role: .user),
                        User(id: "2", name: "Jane Smith", email: "jane@example.com", role: .admin),
                        User(id: "3", name: "Bob Johnson", email: "bob@example.com", role: .moderator)
                    ]
                    mockRepository.mockUsers = expectedUsers
                    mockRepository.shouldThrowError = false
                    
                    // When
                    var result: [User]?
                    var thrownError: Error?
                    
                    do {
                        result = try await getUsersUseCase.execute()
                    } catch {
                        thrownError = error
                    }
                    
                    // Then
                    expect(result).toNot(beNil())
                    expect(result?.count).to(equal(3))
                    expect(thrownError).to(beNil())
                    expect(mockRepository.getUsersCalled).to(beTrue())
                }
            }
            
            context("when no users exist") {
                
                it("should return empty list") {
                    // Given
                    mockRepository.mockUsers = []
                    mockRepository.shouldThrowError = false
                    
                    // When
                    var result: [User]?
                    var thrownError: Error?
                    
                    do {
                        result = try await getUsersUseCase.execute()
                    } catch {
                        thrownError = error
                    }
                    
                    // Then
                    expect(result).toNot(beNil())
                    expect(result?.count).to(equal(0))
                    expect(thrownError).to(beNil())
                }
            }
            
            context("when repository throws error") {
                
                it("should propagate error") {
                    // Given
                    mockRepository.shouldThrowError = true
                    mockRepository.repositoryError = RepositoryError.networkError(NSError(domain: "Test", code: 500, userInfo: nil))
                    
                    // When
                    var thrownError: Error?
                    
                    do {
                        _ = try await getUsersUseCase.execute()
                    } catch {
                        thrownError = error
                    }
                    
                    // Then
                    expect(thrownError).toNot(beNil())
                    expect(thrownError).to(beAKindOf(RepositoryError.self))
                }
            }
        }
        
        describe("CreateUserUseCase") {
            
            var createUserUseCase: CreateUserUseCase!
            var mockRepository: MockUserRepository!
            var mockValidator: MockUserValidator!
            
            beforeEach {
                mockRepository = MockUserRepository()
                mockValidator = MockUserValidator()
                createUserUseCase = CreateUserUseCase(repository: mockRepository, validator: mockValidator)
            }
            
            context("when user data is valid") {
                
                it("should create user successfully") {
                    // Given
                    let newUser = User(
                        id: "",
                        name: "New User",
                        email: "newuser@example.com",
                        role: .user
                    )
                    let createdUser = User(
                        id: "123",
                        name: "New User",
                        email: "newuser@example.com",
                        role: .user
                    )
                    mockRepository.mockUser = createdUser
                    mockRepository.shouldThrowError = false
                    mockValidator.shouldThrowError = false
                    
                    // When
                    var result: User?
                    var thrownError: Error?
                    
                    do {
                        result = try await createUserUseCase.execute(user: newUser)
                    } catch {
                        thrownError = error
                    }
                    
                    // Then
                    expect(result).toNot(beNil())
                    expect(result?.name).to(equal("New User"))
                    expect(result?.email).to(equal("newuser@example.com"))
                    expect(thrownError).to(beNil())
                    expect(mockRepository.createUserCalled).to(beTrue())
                }
            }
            
            context("when user data is invalid") {
                
                it("should throw validation error") {
                    // Given
                    let invalidUser = User(
                        id: "",
                        name: "",
                        email: "invalid-email",
                        role: .user
                    )
                    mockValidator.shouldThrowError = true
                    mockValidator.validationError = ValidationError.invalidUser("User data is invalid")
                    
                    // When
                    var thrownError: Error?
                    
                    do {
                        _ = try await createUserUseCase.execute(user: invalidUser)
                    } catch {
                        thrownError = error
                    }
                    
                    // Then
                    expect(thrownError).toNot(beNil())
                    expect(thrownError).to(beAKindOf(ValidationError.self))
                    expect(mockRepository.createUserCalled).to(beFalse())
                }
            }
        }
        
        describe("UpdateUserUseCase") {
            
            var updateUserUseCase: UpdateUserUseCase!
            var mockRepository: MockUserRepository!
            var mockValidator: MockUserValidator!
            
            beforeEach {
                mockRepository = MockUserRepository()
                mockValidator = MockUserValidator()
                updateUserUseCase = UpdateUserUseCase(repository: mockRepository, validator: mockValidator)
            }
            
            context("when user update is valid") {
                
                it("should update user successfully") {
                    // Given
                    let updatedUser = User(
                        id: "123",
                        name: "Updated User",
                        email: "updated@example.com",
                        role: .admin
                    )
                    mockRepository.mockUser = updatedUser
                    mockRepository.shouldThrowError = false
                    mockValidator.shouldThrowError = false
                    
                    // When
                    var result: User?
                    var thrownError: Error?
                    
                    do {
                        result = try await updateUserUseCase.execute(user: updatedUser)
                    } catch {
                        thrownError = error
                    }
                    
                    // Then
                    expect(result).toNot(beNil())
                    expect(result?.name).to(equal("Updated User"))
                    expect(result?.role).to(equal(.admin))
                    expect(thrownError).to(beNil())
                    expect(mockRepository.updateUserCalled).to(beTrue())
                }
            }
            
            context("when user does not exist") {
                
                it("should throw user not found error") {
                    // Given
                    let nonExistentUser = User(
                        id: "999",
                        name: "Non Existent",
                        email: "nonexistent@example.com",
                        role: .user
                    )
                    mockRepository.shouldThrowError = true
                    mockRepository.repositoryError = RepositoryError.userNotFound
                    mockValidator.shouldThrowError = false
                    
                    // When
                    var thrownError: Error?
                    
                    do {
                        _ = try await updateUserUseCase.execute(user: nonExistentUser)
                    } catch {
                        thrownError = error
                    }
                    
                    // Then
                    expect(thrownError).toNot(beNil())
                    expect(thrownError).to(beAKindOf(RepositoryError.self))
                }
            }
        }
        
        describe("DeleteUserUseCase") {
            
            var deleteUserUseCase: DeleteUserUseCase!
            var mockRepository: MockUserRepository!
            
            beforeEach {
                mockRepository = MockUserRepository()
                deleteUserUseCase = DeleteUserUseCase(repository: mockRepository)
            }
            
            context("when user exists") {
                
                it("should delete user successfully") {
                    // Given
                    let userId = "123"
                    mockRepository.shouldThrowError = false
                    
                    // When
                    var thrownError: Error?
                    
                    do {
                        try await deleteUserUseCase.execute(id: userId)
                    } catch {
                        thrownError = error
                    }
                    
                    // Then
                    expect(thrownError).to(beNil())
                    expect(mockRepository.deleteUserCalled).to(beTrue())
                    expect(mockRepository.deleteUserId).to(equal(userId))
                }
            }
            
            context("when user does not exist") {
                
                it("should throw user not found error") {
                    // Given
                    let userId = "999"
                    mockRepository.shouldThrowError = true
                    mockRepository.repositoryError = RepositoryError.userNotFound
                    
                    // When
                    var thrownError: Error?
                    
                    do {
                        try await deleteUserUseCase.execute(id: userId)
                    } catch {
                        thrownError = error
                    }
                    
                    // Then
                    expect(thrownError).toNot(beNil())
                    expect(thrownError).to(beAKindOf(RepositoryError.self))
                }
            }
        }
        
        describe("SearchUsersUseCase") {
            
            var searchUsersUseCase: SearchUsersUseCase!
            var mockRepository: MockUserRepository!
            
            beforeEach {
                mockRepository = MockUserRepository()
                searchUsersUseCase = SearchUsersUseCase(repository: mockRepository)
            }
            
            context("when search query matches users") {
                
                it("should return matching users") {
                    // Given
                    let searchQuery = "john"
                    let expectedUsers = [
                        User(id: "1", name: "John Doe", email: "john@example.com", role: .user),
                        User(id: "2", name: "Johnny Smith", email: "johnny@example.com", role: .user)
                    ]
                    mockRepository.mockUsers = expectedUsers
                    mockRepository.shouldThrowError = false
                    
                    // When
                    var result: [User]?
                    var thrownError: Error?
                    
                    do {
                        result = try await searchUsersUseCase.execute(query: searchQuery)
                    } catch {
                        thrownError = error
                    }
                    
                    // Then
                    expect(result).toNot(beNil())
                    expect(result?.count).to(equal(2))
                    expect(thrownError).to(beNil())
                    expect(mockRepository.searchUsersCalled).to(beTrue())
                    expect(mockRepository.searchUsersQuery).to(equal(searchQuery))
                }
            }
            
            context("when search query has no matches") {
                
                it("should return empty list") {
                    // Given
                    let searchQuery = "nonexistent"
                    mockRepository.mockUsers = []
                    mockRepository.shouldThrowError = false
                    
                    // When
                    var result: [User]?
                    var thrownError: Error?
                    
                    do {
                        result = try await searchUsersUseCase.execute(query: searchQuery)
                    } catch {
                        thrownError = error
                    }
                    
                    // Then
                    expect(result).toNot(beNil())
                    expect(result?.count).to(equal(0))
                    expect(thrownError).to(beNil())
                }
            }
        }
        
        describe("Performance Tests") {
            
            var getUserUseCase: GetUserUseCase!
            var mockRepository: MockUserRepository!
            
            beforeEach {
                mockRepository = MockUserRepository()
                getUserUseCase = GetUserUseCase(repository: mockRepository)
            }
            
            it("should execute within performance threshold") {
                // Given
                let userId = "123"
                let expectedUser = User(id: userId, name: "Test User", email: "test@example.com", role: .user)
                mockRepository.mockUser = expectedUser
                mockRepository.shouldThrowError = false
                
                // When & Then
                measure {
                    Task {
                        do {
                            _ = try await getUserUseCase.execute(id: userId)
                        } catch {
                            fail("Unexpected error: \(error)")
                        }
                    }
                }
            }
        }
        
        describe("Concurrency Tests") {
            
            var getUserUseCase: GetUserUseCase!
            var mockRepository: MockUserRepository!
            
            beforeEach {
                mockRepository = MockUserRepository()
                getUserUseCase = GetUserUseCase(repository: mockRepository)
            }
            
            it("should handle concurrent requests") {
                // Given
                let userIds = ["1", "2", "3", "4", "5"]
                let expectedUser = User(id: "1", name: "Test User", email: "test@example.com", role: .user)
                mockRepository.mockUser = expectedUser
                mockRepository.shouldThrowError = false
                
                // When
                let group = DispatchGroup()
                var results: [User] = []
                var errors: [Error] = []
                
                for userId in userIds {
                    group.enter()
                    Task {
                        do {
                            let user = try await getUserUseCase.execute(id: userId)
                            results.append(user)
                        } catch {
                            errors.append(error)
                        }
                        group.leave()
                    }
                }
                
                group.wait()
                
                // Then
                expect(results.count).to(equal(userIds.count))
                expect(errors.count).to(equal(0))
            }
        }
    }
}

// MARK: - Mock Classes
class MockUserRepository: UserRepositoryProtocol {
    var mockUser: User?
    var mockUsers: [User] = []
    var shouldThrowError = false
    var repositoryError: Error = RepositoryError.userNotFound
    
    var getUserCalled = false
    var getUserId: String?
    var getUsersCalled = false
    var createUserCalled = false
    var updateUserCalled = false
    var deleteUserCalled = false
    var deleteUserId: String?
    var searchUsersCalled = false
    var searchUsersQuery: String?
    
    func getUser(id: String) async throws -> User {
        getUserCalled = true
        getUserId = id
        
        if shouldThrowError {
            throw repositoryError
        }
        
        guard let user = mockUser else {
            throw RepositoryError.userNotFound
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
            throw RepositoryError.invalidUser
        }
        
        return createdUser
    }
    
    func updateUser(_ user: User) async throws -> User {
        updateUserCalled = true
        
        if shouldThrowError {
            throw repositoryError
        }
        
        guard let updatedUser = mockUser else {
            throw RepositoryError.userNotFound
        }
        
        return updatedUser
    }
    
    func deleteUser(id: String) async throws {
        deleteUserCalled = true
        deleteUserId = id
        
        if shouldThrowError {
            throw repositoryError
        }
    }
    
    func searchUsers(query: String) async throws -> [User] {
        searchUsersCalled = true
        searchUsersQuery = query
        
        if shouldThrowError {
            throw repositoryError
        }
        
        return mockUsers
    }
    
    func getUsersByRole(_ role: UserRole) async throws -> [User] {
        if shouldThrowError {
            throw repositoryError
        }
        
        return mockUsers.filter { $0.role == role }
    }
    
    func userExists(id: String) async throws -> Bool {
        if shouldThrowError {
            throw repositoryError
        }
        
        return mockUser != nil
    }
    
    func getUserCount(isActive: Bool?) async throws -> Int {
        if shouldThrowError {
            throw repositoryError
        }
        
        return mockUsers.count
    }
}

class MockUserValidator: UserValidatorProtocol {
    var shouldThrowError = false
    var validationError: Error = ValidationError.invalidUserId("Invalid user ID")
    
    var validateUserIdCalled = false
    var validateUserCalled = false
    
    func validateUserId(_ id: String) throws {
        validateUserIdCalled = true
        
        if shouldThrowError {
            throw validationError
        }
    }
    
    func validateUser(_ user: User) throws {
        validateUserCalled = true
        
        if shouldThrowError {
            throw validationError
        }
    }
}

// MARK: - Additional Use Case Protocols
protocol GetUsersUseCaseProtocol {
    func execute() async throws -> [User]
}

protocol CreateUserUseCaseProtocol {
    func execute(user: User) async throws -> User
}

protocol UpdateUserUseCaseProtocol {
    func execute(user: User) async throws -> User
}

protocol DeleteUserUseCaseProtocol {
    func execute(id: String) async throws
}

protocol SearchUsersUseCaseProtocol {
    func execute(query: String) async throws -> [User]
}

// MARK: - Additional Use Case Implementations
struct GetUsersUseCase: GetUsersUseCaseProtocol {
    private let repository: UserRepositoryProtocol
    
    init(repository: UserRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute() async throws -> [User] {
        return try await repository.getUsers(limit: 100, offset: 0, isActive: nil)
    }
}

struct CreateUserUseCase: CreateUserUseCaseProtocol {
    private let repository: UserRepositoryProtocol
    private let validator: UserValidatorProtocol
    
    init(repository: UserRepositoryProtocol, validator: UserValidatorProtocol = UserValidator()) {
        self.repository = repository
        self.validator = validator
    }
    
    func execute(user: User) async throws -> User {
        try validator.validateUser(user)
        return try await repository.createUser(user)
    }
}

struct UpdateUserUseCase: UpdateUserUseCaseProtocol {
    private let repository: UserRepositoryProtocol
    private let validator: UserValidatorProtocol
    
    init(repository: UserRepositoryProtocol, validator: UserValidatorProtocol = UserValidator()) {
        self.repository = repository
        self.validator = validator
    }
    
    func execute(user: User) async throws -> User {
        try validator.validateUser(user)
        return try await repository.updateUser(user)
    }
}

struct DeleteUserUseCase: DeleteUserUseCaseProtocol {
    private let repository: UserRepositoryProtocol
    
    init(repository: UserRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(id: String) async throws {
        try await repository.deleteUser(id: id)
    }
}

struct SearchUsersUseCase: SearchUsersUseCaseProtocol {
    private let repository: UserRepositoryProtocol
    
    init(repository: UserRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(query: String) async throws -> [User] {
        return try await repository.searchUsers(query: query)
    }
}

// MARK: - Mock Use Cases for Preview
struct MockGetUserUseCase: GetUserUseCaseProtocol {
    func execute(id: String) async throws -> User {
        return User(id: id, name: "Mock User", email: "mock@example.com", role: .user)
    }
}

struct MockGetUsersUseCase: GetUsersUseCaseProtocol {
    func execute() async throws -> [User] {
        return [
            User(id: "1", name: "User 1", email: "user1@example.com", role: .user),
            User(id: "2", name: "User 2", email: "user2@example.com", role: .admin)
        ]
    }
}

struct MockCreateUserUseCase: CreateUserUseCaseProtocol {
    func execute(user: User) async throws -> User {
        return user
    }
}

struct MockUpdateUserUseCase: UpdateUserUseCaseProtocol {
    func execute(user: User) async throws -> User {
        return user
    }
}

struct MockDeleteUserUseCase: DeleteUserUseCaseProtocol {
    func execute(id: String) async throws {
        // Mock implementation
    }
}

struct MockSearchUsersUseCase: SearchUsersUseCaseProtocol {
    func execute(query: String) async throws -> [User] {
        return [
            User(id: "1", name: "Search Result", email: "search@example.com", role: .user)
        ]
    }
}
