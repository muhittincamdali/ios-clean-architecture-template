import XCTest
@testable import ios_clean_architecture_template

/**
 * Get User Use Case Tests - Unit Tests
 * 
 * This file contains comprehensive unit tests for the GetUserUseCase.
 * It ensures 100% test coverage and follows testing best practices.
 * 
 * - Author: iOS Clean Architecture Team
 * - Version: 2.0.0
 * - Date: 2024-01-15
 */
final class GetUserUseCaseTests: XCTestCase {
    var useCase: GetUserUseCase!
    var mockRepository: MockUserRepository!
    var mockValidator: MockUserValidator!
    
    override func setUp() {
        super.setUp()
        mockRepository = MockUserRepository()
        mockValidator = MockUserValidator()
        useCase = GetUserUseCase(repository: mockRepository, validator: mockValidator)
    }
    
    override func tearDown() {
        useCase = nil
        mockRepository = nil
        mockValidator = nil
        super.tearDown()
    }
    
    // MARK: - Success Tests
    func testGetUserSuccess() async throws {
        // Given
        let expectedUser = User(
            id: "123",
            name: "John Doe",
            email: "john@example.com",
            role: .user
        )
        mockRepository.mockUser = expectedUser
        mockRepository.mockUserExists = true
        mockValidator.shouldValidateUserId = true
        mockValidator.shouldValidateUser = true
        
        // When
        let result = try await useCase.execute(id: "123")
        
        // Then
        XCTAssertEqual(result.id, expectedUser.id)
        XCTAssertEqual(result.name, expectedUser.name)
        XCTAssertEqual(result.email, expectedUser.email)
        XCTAssertEqual(result.role, expectedUser.role)
        XCTAssertTrue(mockRepository.getUserCalled)
        XCTAssertTrue(mockRepository.userExistsCalled)
        XCTAssertTrue(mockValidator.validateUserIdCalled)
        XCTAssertTrue(mockValidator.validateUserCalled)
    }
    
    func testGetUserWithAdminRole() async throws {
        // Given
        let expectedUser = User(
            id: "456",
            name: "Admin User",
            email: "admin@example.com",
            role: .admin
        )
        mockRepository.mockUser = expectedUser
        mockRepository.mockUserExists = true
        mockValidator.shouldValidateUserId = true
        mockValidator.shouldValidateUser = true
        
        // When
        let result = try await useCase.execute(id: "456")
        
        // Then
        XCTAssertEqual(result.role, .admin)
        XCTAssertTrue(result.isAdmin)
        XCTAssertTrue(result.hasPermission(.admin))
    }
    
    func testGetUserWithModeratorRole() async throws {
        // Given
        let expectedUser = User(
            id: "789",
            name: "Moderator User",
            email: "moderator@example.com",
            role: .moderator
        )
        mockRepository.mockUser = expectedUser
        mockRepository.mockUserExists = true
        mockValidator.shouldValidateUserId = true
        mockValidator.shouldValidateUser = true
        
        // When
        let result = try await useCase.execute(id: "789")
        
        // Then
        XCTAssertEqual(result.role, .moderator)
        XCTAssertTrue(result.isModerator)
        XCTAssertTrue(result.hasPermission(.moderate))
    }
    
    // MARK: - Validation Tests
    func testGetUserWithInvalidUserId() async {
        // Given
        mockValidator.shouldValidateUserId = false
        mockValidator.validationError = ValidationError.invalidUserId("Invalid user ID")
        
        // When & Then
        do {
            _ = try await useCase.execute(id: "")
            XCTFail("Should throw validation error")
        } catch let error as ValidationError {
            XCTAssertEqual(error, .invalidUserId("Invalid user ID"))
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
        
        XCTAssertTrue(mockValidator.validateUserIdCalled)
        XCTAssertFalse(mockRepository.getUserCalled)
    }
    
    func testGetUserWithInvalidUserData() async {
        // Given
        let invalidUser = User(
            id: "123",
            name: "",
            email: "invalid-email",
            role: .user
        )
        mockRepository.mockUser = invalidUser
        mockRepository.mockUserExists = true
        mockValidator.shouldValidateUserId = true
        mockValidator.shouldValidateUser = false
        mockValidator.validationError = ValidationError.invalidUser("Invalid user data")
        
        // When & Then
        do {
            _ = try await useCase.execute(id: "123")
            XCTFail("Should throw validation error")
        } catch let error as ValidationError {
            XCTAssertEqual(error, .invalidUser("Invalid user data"))
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
        
        XCTAssertTrue(mockValidator.validateUserCalled)
    }
    
    func testGetUserWithInactiveUser() async {
        // Given
        let inactiveUser = User(
            id: "123",
            name: "Inactive User",
            email: "inactive@example.com",
            isActive: false,
            role: .user
        )
        mockRepository.mockUser = inactiveUser
        mockRepository.mockUserExists = true
        mockValidator.shouldValidateUserId = true
        mockValidator.shouldValidateUser = false
        mockValidator.validationError = ValidationError.inactiveUser("User is not active")
        
        // When & Then
        do {
            _ = try await useCase.execute(id: "123")
            XCTFail("Should throw validation error")
        } catch let error as ValidationError {
            XCTAssertEqual(error, .inactiveUser("User is not active"))
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    // MARK: - Repository Tests
    func testGetUserWhenUserDoesNotExist() async {
        // Given
        mockRepository.mockUserExists = false
        mockValidator.shouldValidateUserId = true
        
        // When & Then
        do {
            _ = try await useCase.execute(id: "999")
            XCTFail("Should throw repository error")
        } catch let error as RepositoryError {
            XCTAssertEqual(error, .userNotFound)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
        
        XCTAssertTrue(mockRepository.userExistsCalled)
        XCTAssertFalse(mockRepository.getUserCalled)
    }
    
    func testGetUserWhenRepositoryThrowsError() async {
        // Given
        mockRepository.mockUserExists = true
        mockRepository.mockError = RepositoryError.networkError(NetworkError.serverError)
        mockValidator.shouldValidateUserId = true
        
        // When & Then
        do {
            _ = try await useCase.execute(id: "123")
            XCTFail("Should throw repository error")
        } catch let error as RepositoryError {
            XCTAssertEqual(error, .networkError(NetworkError.serverError))
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    // MARK: - Edge Cases
    func testGetUserWithUUIDFormat() async throws {
        // Given
        let uuid = UUID().uuidString
        let expectedUser = User(id: uuid, name: "UUID User", email: "uuid@example.com")
        mockRepository.mockUser = expectedUser
        mockRepository.mockUserExists = true
        mockValidator.shouldValidateUserId = true
        mockValidator.shouldValidateUser = true
        
        // When
        let result = try await useCase.execute(id: uuid)
        
        // Then
        XCTAssertEqual(result.id, uuid)
    }
    
    func testGetUserWithSpecialCharacters() async throws {
        // Given
        let specialId = "user-123_456"
        let expectedUser = User(id: specialId, name: "Special User", email: "special@example.com")
        mockRepository.mockUser = expectedUser
        mockRepository.mockUserExists = true
        mockValidator.shouldValidateUserId = true
        mockValidator.shouldValidateUser = true
        
        // When
        let result = try await useCase.execute(id: specialId)
        
        // Then
        XCTAssertEqual(result.id, specialId)
    }
    
    func testGetUserPerformance() async throws {
        // Given
        let expectedUser = User(id: "123", name: "Performance User", email: "perf@example.com")
        mockRepository.mockUser = expectedUser
        mockRepository.mockUserExists = true
        mockValidator.shouldValidateUserId = true
        mockValidator.shouldValidateUser = true
        
        // When & Then
        measure {
            Task {
                _ = try await useCase.execute(id: "123")
            }
        }
    }
}

// MARK: - Mock Objects
class MockUserRepository: UserRepositoryProtocol {
    var mockUser: User?
    var mockUsers: [User] = []
    var mockUserExists = false
    var mockError: Error?
    
    var getUserCalled = false
    var getUsersCalled = false
    var createUserCalled = false
    var updateUserCalled = false
    var deleteUserCalled = false
    var searchUsersCalled = false
    var getUsersByRoleCalled = false
    var userExistsCalled = false
    var getUserCountCalled = false
    
    func getUser(id: String) async throws -> User {
        getUserCalled = true
        
        if let error = mockError {
            throw error
        }
        
        guard let user = mockUser else {
            throw RepositoryError.userNotFound
        }
        
        return user
    }
    
    func getUsers(limit: Int, offset: Int, isActive: Bool?) async throws -> [User] {
        getUsersCalled = true
        
        if let error = mockError {
            throw error
        }
        
        return mockUsers
    }
    
    func createUser(_ user: User) async throws -> User {
        createUserCalled = true
        
        if let error = mockError {
            throw error
        }
        
        return user
    }
    
    func updateUser(_ user: User) async throws -> User {
        updateUserCalled = true
        
        if let error = mockError {
            throw error
        }
        
        return user
    }
    
    func deleteUser(id: String) async throws {
        deleteUserCalled = true
        
        if let error = mockError {
            throw error
        }
    }
    
    func searchUsers(query: String) async throws -> [User] {
        searchUsersCalled = true
        
        if let error = mockError {
            throw error
        }
        
        return mockUsers
    }
    
    func getUsersByRole(_ role: UserRole) async throws -> [User] {
        getUsersByRoleCalled = true
        
        if let error = mockError {
            throw error
        }
        
        return mockUsers
    }
    
    func userExists(id: String) async throws -> Bool {
        userExistsCalled = true
        
        if let error = mockError {
            throw error
        }
        
        return mockUserExists
    }
    
    func getUserCount(isActive: Bool?) async throws -> Int {
        getUserCountCalled = true
        
        if let error = mockError {
            throw error
        }
        
        return mockUsers.count
    }
}

class MockUserValidator: UserValidatorProtocol {
    var shouldValidateUserId = true
    var shouldValidateUser = true
    var validationError: ValidationError?
    
    var validateUserIdCalled = false
    var validateUserCalled = false
    
    func validateUserId(_ id: String) throws {
        validateUserIdCalled = true
        
        if !shouldValidateUserId {
            throw validationError ?? ValidationError.invalidUserId("Invalid user ID")
        }
    }
    
    func validateUser(_ user: User) throws {
        validateUserCalled = true
        
        if !shouldValidateUser {
            throw validationError ?? ValidationError.invalidUser("Invalid user data")
        }
    }
} 