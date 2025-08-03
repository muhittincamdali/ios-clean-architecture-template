import Foundation

/**
 * User Local Data Source - Data Layer
 * 
 * Local data source implementation for user data storage.
 * Handles local persistence and data management.
 * 
 * - Author: iOS Clean Architecture Team
 * - Version: 2.0.0
 * - Date: 2024-01-15
 */

// MARK: - User Local Data Source Implementation
class UserLocalDataSource: UserLocalDataSourceProtocol {
    
    // MARK: - Dependencies
    private let storage: StorageProtocol
    private let logger: LoggerProtocol
    
    // MARK: - Constants
    private let usersKey = "users"
    private let userPrefix = "user_"
    
    // MARK: - Initialization
    init(
        storage: StorageProtocol = KeychainStorage(),
        logger: LoggerProtocol = Logger()
    ) {
        self.storage = storage
        self.logger = logger
    }
    
    // MARK: - User Operations
    func getUser(id: String) async throws -> User? {
        do {
            let key = "\(userPrefix)\(id)"
            guard let data = try storage.getData(forKey: key) else {
                return nil
            }
            
            let user = try JSONDecoder().decode(User.self, from: data)
            logger.log("User retrieved from local storage", level: .debug, category: "UserLocalDataSource", file: #file, function: #function, line: #line)
            return user
        } catch {
            logger.log("Failed to get user from local storage: \(error.localizedDescription)", level: .error, category: "UserLocalDataSource", file: #file, function: #function, line: #line)
            throw handleError(error)
        }
    }
    
    func getUsers(limit: Int, offset: Int, isActive: Bool?) async throws -> [User]? {
        do {
            guard let data = try storage.getData(forKey: usersKey) else {
                return nil
            }
            
            let allUsers = try JSONDecoder().decode([User].self, from: data)
            
            // Apply filters
            var filteredUsers = allUsers
            
            if let isActive = isActive {
                filteredUsers = filteredUsers.filter { $0.isActive == isActive }
            }
            
            // Apply pagination
            let paginatedUsers = Array(filteredUsers.dropFirst(offset).prefix(limit))
            
            logger.log("Users retrieved from local storage", level: .debug, category: "UserLocalDataSource", file: #file, function: #function, line: #line)
            return paginatedUsers
        } catch {
            logger.log("Failed to get users from local storage: \(error.localizedDescription)", level: .error, category: "UserLocalDataSource", file: #file, function: #function, line: #line)
            throw handleError(error)
        }
    }
    
    func saveUser(_ user: User) async throws {
        do {
            let data = try JSONEncoder().encode(user)
            let key = "\(userPrefix)\(user.id)"
            try storage.save(data, forKey: key)
            
            // Update users list
            try await updateUsersList(user)
            
            logger.log("User saved to local storage", level: .debug, category: "UserLocalDataSource", file: #file, function: #function, line: #line)
        } catch {
            logger.log("Failed to save user to local storage: \(error.localizedDescription)", level: .error, category: "UserLocalDataSource", file: #file, function: #function, line: #line)
            throw handleError(error)
        }
    }
    
    func saveUsers(_ users: [User]) async throws {
        do {
            for user in users {
                try await saveUser(user)
            }
            
            logger.log("Users saved to local storage", level: .debug, category: "UserLocalDataSource", file: #file, function: #function, line: #line)
        } catch {
            logger.log("Failed to save users to local storage: \(error.localizedDescription)", level: .error, category: "UserLocalDataSource", file: #file, function: #function, line: #line)
            throw handleError(error)
        }
    }
    
    func createUser(_ user: User) async throws -> User {
        do {
            let createdUser = User(
                id: user.id.isEmpty ? UUID().uuidString : user.id,
                name: user.name,
                email: user.email,
                role: user.role,
                isActive: user.isActive,
                avatarURL: user.avatarURL,
                createdAt: Date(),
                updatedAt: Date()
            )
            
            try await saveUser(createdUser)
            
            logger.log("User created in local storage", level: .info, category: "UserLocalDataSource", file: #file, function: #function, line: #line)
            return createdUser
        } catch {
            logger.log("Failed to create user in local storage: \(error.localizedDescription)", level: .error, category: "UserLocalDataSource", file: #file, function: #function, line: #line)
            throw handleError(error)
        }
    }
    
    func updateUser(_ user: User) async throws -> User {
        do {
            let updatedUser = User(
                id: user.id,
                name: user.name,
                email: user.email,
                role: user.role,
                isActive: user.isActive,
                avatarURL: user.avatarURL,
                createdAt: user.createdAt,
                updatedAt: Date()
            )
            
            try await saveUser(updatedUser)
            
            logger.log("User updated in local storage", level: .info, category: "UserLocalDataSource", file: #file, function: #function, line: #line)
            return updatedUser
        } catch {
            logger.log("Failed to update user in local storage: \(error.localizedDescription)", level: .error, category: "UserLocalDataSource", file: #file, function: #function, line: #line)
            throw handleError(error)
        }
    }
    
    func deleteUser(id: String) async throws {
        do {
            let key = "\(userPrefix)\(id)"
            try storage.delete(forKey: key)
            
            // Remove from users list
            try await removeUserFromList(id: id)
            
            logger.log("User deleted from local storage", level: .info, category: "UserLocalDataSource", file: #file, function: #function, line: #line)
        } catch {
            logger.log("Failed to delete user from local storage: \(error.localizedDescription)", level: .error, category: "UserLocalDataSource", file: #file, function: #function, line: #line)
            throw handleError(error)
        }
    }
    
    func searchUsers(query: String) async throws -> [User] {
        do {
            guard let data = try storage.getData(forKey: usersKey) else {
                return []
            }
            
            let allUsers = try JSONDecoder().decode([User].self, from: data)
            
            // Filter users by query
            let filteredUsers = allUsers.filter { user in
                user.name.localizedCaseInsensitiveContains(query) ||
                user.email.localizedCaseInsensitiveContains(query)
            }
            
            logger.log("Users searched in local storage", level: .debug, category: "UserLocalDataSource", file: #file, function: #function, line: #line)
            return filteredUsers
        } catch {
            logger.log("Failed to search users in local storage: \(error.localizedDescription)", level: .error, category: "UserLocalDataSource", file: #file, function: #function, line: #line)
            throw handleError(error)
        }
    }
    
    func getUsersByRole(_ role: UserRole) async throws -> [User] {
        do {
            guard let data = try storage.getData(forKey: usersKey) else {
                return []
            }
            
            let allUsers = try JSONDecoder().decode([User].self, from: data)
            
            // Filter users by role
            let filteredUsers = allUsers.filter { $0.role == role }
            
            logger.log("Users by role retrieved from local storage", level: .debug, category: "UserLocalDataSource", file: #file, function: #function, line: #line)
            return filteredUsers
        } catch {
            logger.log("Failed to get users by role from local storage: \(error.localizedDescription)", level: .error, category: "UserLocalDataSource", file: #file, function: #function, line: #line)
            throw handleError(error)
        }
    }
    
    // MARK: - Private Methods
    private func updateUsersList(_ user: User) async throws {
        do {
            var users = try await getAllUsers()
            
            // Remove existing user if exists
            users.removeAll { $0.id == user.id }
            
            // Add updated user
            users.append(user)
            
            // Save updated list
            let data = try JSONEncoder().encode(users)
            try storage.save(data, forKey: usersKey)
        } catch {
            logger.log("Failed to update users list: \(error.localizedDescription)", level: .error, category: "UserLocalDataSource", file: #file, function: #function, line: #line)
            throw handleError(error)
        }
    }
    
    private func removeUserFromList(id: String) async throws {
        do {
            var users = try await getAllUsers()
            
            // Remove user from list
            users.removeAll { $0.id == id }
            
            // Save updated list
            let data = try JSONEncoder().encode(users)
            try storage.save(data, forKey: usersKey)
        } catch {
            logger.log("Failed to remove user from list: \(error.localizedDescription)", level: .error, category: "UserLocalDataSource", file: #file, function: #function, line: #line)
            throw handleError(error)
        }
    }
    
    private func getAllUsers() async throws -> [User] {
        do {
            guard let data = try storage.getData(forKey: usersKey) else {
                return []
            }
            
            return try JSONDecoder().decode([User].self, from: data)
        } catch {
            logger.log("Failed to get all users: \(error.localizedDescription)", level: .error, category: "UserLocalDataSource", file: #file, function: #function, line: #line)
            throw handleError(error)
        }
    }
    
    private func handleError(_ error: Error) -> Error {
        if let storageError = error as? StorageError {
            switch storageError {
            case .saveFailed(let message):
                return UserRepositoryError.databaseError(NSError(domain: "StorageError", code: 0, userInfo: [NSLocalizedDescriptionKey: message]))
            case .loadFailed(let message):
                return UserRepositoryError.databaseError(NSError(domain: "StorageError", code: 0, userInfo: [NSLocalizedDescriptionKey: message]))
            case .deleteFailed(let message):
                return UserRepositoryError.databaseError(NSError(domain: "StorageError", code: 0, userInfo: [NSLocalizedDescriptionKey: message]))
            case .encodingFailed:
                return UserRepositoryError.databaseError(NSError(domain: "StorageError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Data encoding failed"]))
            case .decodingFailed:
                return UserRepositoryError.databaseError(NSError(domain: "StorageError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Data decoding failed"]))
            }
        }
        
        return UserRepositoryError.unknown(error)
    }
}

// MARK: - Storage Protocol
protocol StorageProtocol {
    func save(_ data: Data, forKey key: String) throws
    func getData(forKey key: String) throws -> Data?
    func delete(forKey key: String) throws
    func getKeys(matching pattern: String) throws -> [String]
}

// MARK: - Storage Error
enum StorageError: LocalizedError {
    case saveFailed(String)
    case loadFailed(String)
    case deleteFailed(String)
    case encodingFailed
    case decodingFailed
    
    var errorDescription: String? {
        switch self {
        case .saveFailed(let message):
            return "Save failed: \(message)"
        case .loadFailed(let message):
            return "Load failed: \(message)"
        case .deleteFailed(let message):
            return "Delete failed: \(message)"
        case .encodingFailed:
            return "Data encoding failed"
        case .decodingFailed:
            return "Data decoding failed"
        }
    }
}

// MARK: - Keychain Storage Implementation
class KeychainStorage: StorageProtocol {
    
    func save(_ data: Data, forKey key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        if status == errSecDuplicateItem {
            // Item already exists, update it
            let updateQuery: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrAccount as String: key
            ]
            
            let updateAttributes: [String: Any] = [
                kSecValueData as String: data,
                kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
            ]
            
            let updateStatus = SecItemUpdate(updateQuery as CFDictionary, updateAttributes as CFDictionary)
            
            if updateStatus != errSecSuccess {
                throw StorageError.saveFailed("Keychain update failed with status: \(updateStatus)")
            }
        } else if status != errSecSuccess {
            throw StorageError.saveFailed("Keychain save failed with status: \(status)")
        }
    }
    
    func getData(forKey key: String) throws -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        if status == errSecItemNotFound {
            return nil
        } else if status != errSecSuccess {
            throw StorageError.loadFailed("Keychain load failed with status: \(status)")
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
            throw StorageError.deleteFailed("Keychain delete failed with status: \(status)")
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
            throw StorageError.loadFailed("Keychain keys load failed with status: \(status)")
        }
        
        guard let items = result as? [[String: Any]] else {
            return []
        }
        
        return items.compactMap { item in
            item[kSecAttrAccount as String] as? String
        }.filter { key in
            key.range(of: pattern, options: .regularExpression) != nil
        }
    }
} 