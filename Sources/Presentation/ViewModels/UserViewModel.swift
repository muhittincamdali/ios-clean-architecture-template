import Foundation
import SwiftUI

/**
 * User ViewModel - Presentation Layer
 * 
 * This ViewModel handles the presentation logic for user-related views.
 * It follows MVVM pattern and Clean Architecture principles.
 * 
 * - Author: iOS Clean Architecture Team
 * - Version: 2.0.0
 * - Date: 2024-01-15
 */
@MainActor
class UserViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var user: User?
    @Published var users: [User] = []
    @Published var isLoading = false
    @Published var error: Error?
    @Published var searchQuery = ""
    @Published var selectedRole: UserRole?
    @Published var isRefreshing = false
    
    // MARK: - Private Properties
    private let getUserUseCase: GetUserUseCaseProtocol
    private let getUsersUseCase: GetUsersUseCaseProtocol
    private let createUserUseCase: CreateUserUseCaseProtocol
    private let updateUserUseCase: UpdateUserUseCaseProtocol
    private let deleteUserUseCase: DeleteUserUseCaseProtocol
    private let searchUsersUseCase: SearchUsersUseCaseProtocol
    
    // MARK: - Initialization
    init(
        getUserUseCase: GetUserUseCaseProtocol,
        getUsersUseCase: GetUsersUseCaseProtocol,
        createUserUseCase: CreateUserUseCaseProtocol,
        updateUserUseCase: UpdateUserUseCaseProtocol,
        deleteUserUseCase: DeleteUserUseCaseProtocol,
        searchUsersUseCase: SearchUsersUseCaseProtocol
    ) {
        self.getUserUseCase = getUserUseCase
        self.getUsersUseCase = getUsersUseCase
        self.createUserUseCase = createUserUseCase
        self.updateUserUseCase = updateUserUseCase
        self.deleteUserUseCase = deleteUserUseCase
        self.searchUsersUseCase = searchUsersUseCase
    }
    
    // MARK: - Public Methods
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
    
    func loadUsers(limit: Int = 20, offset: Int = 0, isActive: Bool? = nil) async {
        isLoading = true
        error = nil
        
        do {
            users = try await getUsersUseCase.execute(limit: limit, offset: offset, isActive: isActive)
        } catch {
            self.error = error
        }
        
        isLoading = false
    }
    
    func refreshUsers() async {
        isRefreshing = true
        error = nil
        
        do {
            users = try await getUsersUseCase.execute(limit: 20, offset: 0, isActive: nil)
        } catch {
            self.error = error
        }
        
        isRefreshing = false
    }
    
    func createUser(name: String, email: String, role: UserRole = .user) async -> Bool {
        isLoading = true
        error = nil
        
        do {
            let newUser = User(
                id: UUID().uuidString,
                name: name,
                email: email,
                role: role
            )
            
            let createdUser = try await createUserUseCase.execute(user: newUser)
            users.insert(createdUser, at: 0)
            return true
        } catch {
            self.error = error
            return false
        }
        
        isLoading = false
    }
    
    func updateUser(_ user: User) async -> Bool {
        isLoading = true
        error = nil
        
        do {
            let updatedUser = try await updateUserUseCase.execute(user: user)
            
            // Update in users array
            if let index = users.firstIndex(where: { $0.id == user.id }) {
                users[index] = updatedUser
            }
            
            // Update current user if it's the same
            if self.user?.id == user.id {
                self.user = updatedUser
            }
            
            return true
        } catch {
            self.error = error
            return false
        }
        
        isLoading = false
    }
    
    func deleteUser(id: String) async -> Bool {
        isLoading = true
        error = nil
        
        do {
            try await deleteUserUseCase.execute(id: id)
            
            // Remove from users array
            users.removeAll { $0.id == id }
            
            // Clear current user if it's the same
            if self.user?.id == id {
                self.user = nil
            }
            
            return true
        } catch {
            self.error = error
            return false
        }
        
        isLoading = false
    }
    
    func searchUsers(query: String) async {
        guard !query.isEmpty else {
            await loadUsers()
            return
        }
        
        isLoading = true
        error = nil
        
        do {
            users = try await searchUsersUseCase.execute(query: query)
        } catch {
            self.error = error
        }
        
        isLoading = false
    }
    
    func filterUsersByRole(_ role: UserRole?) async {
        selectedRole = role
        await loadUsers(isActive: nil)
    }
    
    func clearError() {
        error = nil
    }
    
    func retry() async {
        if let user = user {
            await loadUser(id: user.id)
        } else {
            await loadUsers()
        }
    }
}

// MARK: - Use Case Protocols
protocol GetUsersUseCaseProtocol {
    func execute(limit: Int, offset: Int, isActive: Bool?) async throws -> [User]
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

// MARK: - Use Case Implementations
struct GetUsersUseCase: GetUsersUseCaseProtocol {
    private let repository: UserRepositoryProtocol
    
    init(repository: UserRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(limit: Int, offset: Int, isActive: Bool?) async throws -> [User] {
        return try await repository.getUsers(limit: limit, offset: offset, isActive: isActive)
    }
}

struct CreateUserUseCase: CreateUserUseCaseProtocol {
    private let repository: UserRepositoryProtocol
    
    init(repository: UserRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(user: User) async throws -> User {
        return try await repository.createUser(user)
    }
}

struct UpdateUserUseCase: UpdateUserUseCaseProtocol {
    private let repository: UserRepositoryProtocol
    
    init(repository: UserRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(user: User) async throws -> User {
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