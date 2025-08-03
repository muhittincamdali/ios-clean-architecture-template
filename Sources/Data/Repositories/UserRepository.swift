import Foundation

/**
 * User Repository - Data Layer
 * 
 * Implementation of user data access with remote and local data sources.
 * Implements Clean Architecture principles with proper error handling.
 * 
 * - Author: iOS Clean Architecture Team
 * - Version: 2.0.0
 * - Date: 2024-01-15
 */

// MARK: - User Repository Implementation
class UserRepository: UserRepositoryProtocol {
    
    // MARK: - Dependencies
    private let remoteDataSource: UserRemoteDataSourceProtocol
    private let localDataSource: UserLocalDataSourceProtocol
    private let cacheManager: CacheManagerProtocol
    private let networkMonitor: NetworkMonitorProtocol
    private let logger: LoggerProtocol
    
    // MARK: - Initialization
    init(
        remoteDataSource: UserRemoteDataSourceProtocol,
        localDataSource: UserLocalDataSourceProtocol,
        cacheManager: CacheManagerProtocol = CacheManager(),
        networkMonitor: NetworkMonitorProtocol = NetworkMonitor(),
        logger: LoggerProtocol = Logger()
    ) {
        self.remoteDataSource = remoteDataSource
        self.localDataSource = localDataSource
        self.cacheManager = cacheManager
        self.networkMonitor = networkMonitor
        self.logger = logger
    }
    
    // MARK: - Basic CRUD Operations
    func getUser(id: String) async throws -> User {
        let startTime = Date()
        
        do {
            // Check cache first
            let cacheKey = "user_\(id)"
            if let cachedUser: User = try await cacheManager.get(forKey: cacheKey) {
                logger.log("User retrieved from cache", level: .debug, category: "UserRepository", file: #file, function: #function, line: #line)
                return cachedUser
            }
            
            // Check local storage
            if let localUser = try await localDataSource.getUser(id: id) {
                // Cache the local user
                try await cacheManager.set(localUser, forKey: cacheKey, expiration: 300)
                logger.log("User retrieved from local storage", level: .debug, category: "UserRepository", file: #file, function: #function, line: #line)
                return localUser
            }
            
            // Fetch from remote if network is available
            if networkMonitor.isConnected {
                let remoteUser = try await remoteDataSource.getUser(id: id)
                
                // Save to local storage
                try await localDataSource.saveUser(remoteUser)
                
                // Cache the remote user
                try await cacheManager.set(remoteUser, forKey: cacheKey, expiration: 300)
                
                let duration = Date().timeIntervalSince(startTime)
                logger.log("User retrieved from remote", level: .info, category: "UserRepository", file: #file, function: #function, line: #line)
                logger.logPerformance("getUser", duration: duration, category: "UserRepository")
                
                return remoteUser
            } else {
                throw UserRepositoryError.networkError(NSError(domain: "NetworkError", code: 0, userInfo: [NSLocalizedDescriptionKey: "No network connection"]))
            }
            
        } catch {
            let duration = Date().timeIntervalSince(startTime)
            logger.log("Failed to get user: \(error.localizedDescription)", level: .error, category: "UserRepository", file: #file, function: #function, line: #line)
            throw handleError(error, for: id)
        }
    }
    
    func getUsers(limit: Int, offset: Int, isActive: Bool?) async throws -> [User] {
        let startTime = Date()
        
        do {
            // Check cache first
            let cacheKey = "users_\(limit)_\(offset)_\(isActive?.description ?? "nil")"
            if let cachedUsers: [User] = try await cacheManager.get(forKey: cacheKey) {
                logger.log("Users retrieved from cache", level: .debug, category: "UserRepository", file: #file, function: #function, line: #line)
                return cachedUsers
            }
            
            // Check local storage
            if let localUsers = try await localDataSource.getUsers(limit: limit, offset: offset, isActive: isActive) {
                // Cache the local users
                try await cacheManager.set(localUsers, forKey: cacheKey, expiration: 300)
                logger.log("Users retrieved from local storage", level: .debug, category: "UserRepository", file: #file, function: #function, line: #line)
                return localUsers
            }
            
            // Fetch from remote if network is available
            if networkMonitor.isConnected {
                let remoteUsers = try await remoteDataSource.getUsers(limit: limit, offset: offset, isActive: isActive)
                
                // Save to local storage
                try await localDataSource.saveUsers(remoteUsers)
                
                // Cache the remote users
                try await cacheManager.set(remoteUsers, forKey: cacheKey, expiration: 300)
                
                let duration = Date().timeIntervalSince(startTime)
                logger.log("Users retrieved from remote", level: .info, category: "UserRepository", file: #file, function: #function, line: #line)
                logger.logPerformance("getUsers", duration: duration, category: "UserRepository")
                
                return remoteUsers
            } else {
                throw UserRepositoryError.networkError(NSError(domain: "NetworkError", code: 0, userInfo: [NSLocalizedDescriptionKey: "No network connection"]))
            }
            
        } catch {
            let duration = Date().timeIntervalSince(startTime)
            logger.log("Failed to get users: \(error.localizedDescription)", level: .error, category: "UserRepository", file: #file, function: #function, line: #line)
            throw handleError(error)
        }
    }
    
    func createUser(_ user: User) async throws -> User {
        let startTime = Date()
        
        do {
            // Validate user data
            try validateUserForCreation(user)
            
            // Create user remotely if network is available
            var createdUser: User
            if networkMonitor.isConnected {
                createdUser = try await remoteDataSource.createUser(user)
            } else {
                // Create locally if no network
                createdUser = try await localDataSource.createUser(user)
            }
            
            // Save to local storage
            try await localDataSource.saveUser(createdUser)
            
            // Clear related caches
            try await clearUserCaches()
            
            let duration = Date().timeIntervalSince(startTime)
            logger.log("User created successfully", level: .info, category: "UserRepository", file: #file, function: #function, line: #line)
            logger.logPerformance("createUser", duration: duration, category: "UserRepository")
            
            return createdUser
            
        } catch {
            let duration = Date().timeIntervalSince(startTime)
            logger.log("Failed to create user: \(error.localizedDescription)", level: .error, category: "UserRepository", file: #file, function: #function, line: #line)
            throw handleError(error)
        }
    }
    
    func updateUser(_ user: User) async throws -> User {
        let startTime = Date()
        
        do {
            // Validate user data
            try validateUserForUpdate(user)
            
            // Update user remotely if network is available
            var updatedUser: User
            if networkMonitor.isConnected {
                updatedUser = try await remoteDataSource.updateUser(user)
            } else {
                // Update locally if no network
                updatedUser = try await localDataSource.updateUser(user)
            }
            
            // Save to local storage
            try await localDataSource.saveUser(updatedUser)
            
            // Clear related caches
            try await clearUserCaches()
            
            let duration = Date().timeIntervalSince(startTime)
            logger.log("User updated successfully", level: .info, category: "UserRepository", file: #file, function: #function, line: #line)
            logger.logPerformance("updateUser", duration: duration, category: "UserRepository")
            
            return updatedUser
            
        } catch {
            let duration = Date().timeIntervalSince(startTime)
            logger.log("Failed to update user: \(error.localizedDescription)", level: .error, category: "UserRepository", file: #file, function: #function, line: #line)
            throw handleError(error)
        }
    }
    
    func deleteUser(id: String) async throws {
        let startTime = Date()
        
        do {
            // Delete user remotely if network is available
            if networkMonitor.isConnected {
                try await remoteDataSource.deleteUser(id: id)
            }
            
            // Delete from local storage
            try await localDataSource.deleteUser(id: id)
            
            // Clear related caches
            try await clearUserCaches()
            
            let duration = Date().timeIntervalSince(startTime)
            logger.log("User deleted successfully", level: .info, category: "UserRepository", file: #file, function: #function, line: #line)
            logger.logPerformance("deleteUser", duration: duration, category: "UserRepository")
            
        } catch {
            let duration = Date().timeIntervalSince(startTime)
            logger.log("Failed to delete user: \(error.localizedDescription)", level: .error, category: "UserRepository", file: #file, function: #function, line: #line)
            throw handleError(error, for: id)
        }
    }
    
    // MARK: - Search and Filter Operations
    func searchUsers(query: String) async throws -> [User] {
        let startTime = Date()
        
        do {
            // Check cache first
            let cacheKey = "search_users_\(query)"
            if let cachedUsers: [User] = try await cacheManager.get(forKey: cacheKey) {
                logger.log("Search results retrieved from cache", level: .debug, category: "UserRepository", file: #file, function: #function, line: #line)
                return cachedUsers
            }
            
            // Search locally first
            var searchResults = try await localDataSource.searchUsers(query: query)
            
            // If network is available, also search remotely
            if networkMonitor.isConnected {
                let remoteResults = try await remoteDataSource.searchUsers(query: query)
                
                // Merge and deduplicate results
                searchResults = mergeAndDeduplicateUsers(local: searchResults, remote: remoteResults)
                
                // Save new users to local storage
                for user in remoteResults {
                    if !searchResults.contains(where: { $0.id == user.id }) {
                        try await localDataSource.saveUser(user)
                    }
                }
            }
            
            // Cache the search results
            try await cacheManager.set(searchResults, forKey: cacheKey, expiration: 180) // 3 minutes for search results
            
            let duration = Date().timeIntervalSince(startTime)
            logger.log("Users searched successfully", level: .info, category: "UserRepository", file: #file, function: #function, line: #line)
            logger.logPerformance("searchUsers", duration: duration, category: "UserRepository")
            
            return searchResults
            
        } catch {
            let duration = Date().timeIntervalSince(startTime)
            logger.log("Failed to search users: \(error.localizedDescription)", level: .error, category: "UserRepository", file: #file, function: #function, line: #line)
            throw handleError(error)
        }
    }
    
    func getUsersByRole(_ role: UserRole) async throws -> [User] {
        let startTime = Date()
        
        do {
            // Check cache first
            let cacheKey = "users_by_role_\(role.rawValue)"
            if let cachedUsers: [User] = try await cacheManager.get(forKey: cacheKey) {
                logger.log("Users by role retrieved from cache", level: .debug, category: "UserRepository", file: #file, function: #function, line: #line)
                return cachedUsers
            }
            
            // Get from local storage
            let localUsers = try await localDataSource.getUsersByRole(role)
            
            // If network is available, also get from remote
            if networkMonitor.isConnected {
                let remoteUsers = try await remoteDataSource.getUsersByRole(role)
                
                // Merge and deduplicate results
                let allUsers = mergeAndDeduplicateUsers(local: localUsers, remote: remoteUsers)
                
                // Save new users to local storage
                for user in remoteUsers {
                    if !localUsers.contains(where: { $0.id == user.id }) {
                        try await localDataSource.saveUser(user)
                    }
                }
                
                // Cache the results
                try await cacheManager.set(allUsers, forKey: cacheKey, expiration: 300)
                
                let duration = Date().timeIntervalSince(startTime)
                logger.log("Users by role retrieved successfully", level: .info, category: "UserRepository", file: #file, function: #function, line: #line)
                logger.logPerformance("getUsersByRole", duration: duration, category: "UserRepository")
                
                return allUsers
            } else {
                // Cache local results
                try await cacheManager.set(localUsers, forKey: cacheKey, expiration: 300)
                return localUsers
            }
            
        } catch {
            let duration = Date().timeIntervalSince(startTime)
            logger.log("Failed to get users by role: \(error.localizedDescription)", level: .error, category: "UserRepository", file: #file, function: #function, line: #line)
            throw handleError(error)
        }
    }
    
    func getActiveUsers() async throws -> [User] {
        return try await getUsers(limit: 1000, offset: 0, isActive: true)
    }
    
    func getInactiveUsers() async throws -> [User] {
        return try await getUsers(limit: 1000, offset: 0, isActive: false)
    }
    
    // MARK: - Validation Operations
    func userExists(id: String) async throws -> Bool {
        do {
            _ = try await getUser(id: id)
            return true
        } catch UserRepositoryError.userNotFound {
            return false
        }
    }
    
    func emailExists(_ email: String) async throws -> Bool {
        let users = try await searchUsers(query: email)
        return users.contains { $0.email.lowercased() == email.lowercased() }
    }
    
    func validateUser(_ user: User) async throws -> Bool {
        return user.isValid
    }
    
    // MARK: - Analytics Operations
    func getUserCount(isActive: Bool?) async throws -> Int {
        let users = try await getUsers(limit: 10000, offset: 0, isActive: isActive)
        return users.count
    }
    
    func getUsersByDateRange(from: Date, to: Date) async throws -> [User] {
        let allUsers = try await getUsers(limit: 10000, offset: 0, isActive: nil)
        return allUsers.filter { user in
            user.createdAt >= from && user.createdAt <= to
        }
    }
    
    func getUsersByLastLogin(days: Int) async throws -> [User] {
        // This would require additional user activity data
        // For now, return all active users
        return try await getActiveUsers()
    }
    
    // MARK: - Bulk Operations
    func createUsers(_ users: [User]) async throws -> [User] {
        var createdUsers: [User] = []
        
        for user in users {
            let createdUser = try await createUser(user)
            createdUsers.append(createdUser)
        }
        
        return createdUsers
    }
    
    func updateUsers(_ users: [User]) async throws -> [User] {
        var updatedUsers: [User] = []
        
        for user in users {
            let updatedUser = try await updateUser(user)
            updatedUsers.append(updatedUser)
        }
        
        return updatedUsers
    }
    
    func deleteUsers(ids: [String]) async throws {
        for id in ids {
            try await deleteUser(id: id)
        }
    }
    
    func activateUsers(ids: [String]) async throws {
        for id in ids {
            let user = try await getUser(id: id)
            let activatedUser = user.activate()
            _ = try await updateUser(activatedUser)
        }
    }
    
    func deactivateUsers(ids: [String]) async throws {
        for id in ids {
            let user = try await getUser(id: id)
            let deactivatedUser = user.deactivate()
            _ = try await updateUser(deactivatedUser)
        }
    }
    
    // MARK: - Advanced Operations
    func getUserWithPermissions(id: String) async throws -> User {
        return try await getUser(id: id)
    }
    
    func updateUserRole(id: String, role: UserRole) async throws -> User {
        let user = try await getUser(id: id)
        let updatedUser = user.changeRole(role)
        return try await updateUser(updatedUser)
    }
    
    func updateUserStatus(id: String, isActive: Bool) async throws -> User {
        let user = try await getUser(id: id)
        let updatedUser = isActive ? user.activate() : user.deactivate()
        return try await updateUser(updatedUser)
    }
    
    func getUserActivity(id: String) async throws -> UserActivity {
        // This would require additional user activity data
        // For now, return a default activity
        return UserActivity(userId: id)
    }
    
    // MARK: - Private Methods
    private func validateUserForCreation(_ user: User) throws {
        guard user.isValid else {
            throw UserRepositoryError.invalidUser
        }
        
        if try await emailExists(user.email) {
            throw UserRepositoryError.duplicateEmail
        }
    }
    
    private func validateUserForUpdate(_ user: User) throws {
        guard user.isValid else {
            throw UserRepositoryError.invalidUser
        }
        
        // Check if user exists
        guard try await userExists(id: user.id) else {
            throw UserRepositoryError.userNotFound
        }
    }
    
    private func mergeAndDeduplicateUsers(local: [User], remote: [User]) -> [User] {
        var mergedUsers = local
        
        for remoteUser in remote {
            if !mergedUsers.contains(where: { $0.id == remoteUser.id }) {
                mergedUsers.append(remoteUser)
            }
        }
        
        return mergedUsers
    }
    
    private func clearUserCaches() async throws {
        try await cacheManager.remove(forKey: "users_*")
        try await cacheManager.remove(forKey: "user_*")
        try await cacheManager.remove(forKey: "search_users_*")
        try await cacheManager.remove(forKey: "users_by_role_*")
    }
    
    private func handleError(_ error: Error, for userId: String? = nil) -> Error {
        if let repositoryError = error as? UserRepositoryError {
            return repositoryError
        }
        
        if let networkError = error as? NetworkError {
            return UserRepositoryError.networkError(networkError)
        }
        
        if let databaseError = error as? DatabaseError {
            return UserRepositoryError.databaseError(databaseError)
        }
        
        return UserRepositoryError.unknown(error)
    }
}

// MARK: - Data Source Protocols
protocol UserRemoteDataSourceProtocol {
    func getUser(id: String) async throws -> User
    func getUsers(limit: Int, offset: Int, isActive: Bool?) async throws -> [User]
    func createUser(_ user: User) async throws -> User
    func updateUser(_ user: User) async throws -> User
    func deleteUser(id: String) async throws
    func searchUsers(query: String) async throws -> [User]
    func getUsersByRole(_ role: UserRole) async throws -> [User]
}

protocol UserLocalDataSourceProtocol {
    func getUser(id: String) async throws -> User?
    func getUsers(limit: Int, offset: Int, isActive: Bool?) async throws -> [User]?
    func saveUser(_ user: User) async throws
    func saveUsers(_ users: [User]) async throws
    func createUser(_ user: User) async throws -> User
    func updateUser(_ user: User) async throws -> User
    func deleteUser(id: String) async throws
    func searchUsers(query: String) async throws -> [User]
    func getUsersByRole(_ role: UserRole) async throws -> [User]
}

// MARK: - Network Monitor Protocol
protocol NetworkMonitorProtocol {
    var isConnected: Bool { get }
    func startMonitoring()
    func stopMonitoring()
}

// MARK: - Network Monitor Implementation
class NetworkMonitor: NetworkMonitorProtocol {
    var isConnected: Bool = true
    
    func startMonitoring() {
        // Implementation for network monitoring
    }
    
    func stopMonitoring() {
        // Implementation for stopping network monitoring
    }
}

// MARK: - Cache Manager Implementation
class CacheManager: CacheManagerProtocol {
    private var cache: [String: (data: Data, expiration: Date)] = [:]
    
    func get<T: Codable>(forKey key: String) async throws -> T? {
        guard let cached = cache[key], cached.expiration > Date() else {
            return nil
        }
        
        return try JSONDecoder().decode(T.self, from: cached.data)
    }
    
    func set<T: Codable>(_ value: T, forKey key: String, expiration: TimeInterval) async throws {
        let data = try JSONEncoder().encode(value)
        let expirationDate = Date().addingTimeInterval(expiration)
        cache[key] = (data: data, expiration: expirationDate)
    }
    
    func remove(forKey key: String) async throws {
        cache.removeValue(forKey: key)
    }
    
    func clear() async throws {
        cache.removeAll()
    }
}

// MARK: - Error Types
enum NetworkError: LocalizedError {
    case noConnection
    case timeout
    case serverError(String)
    
    var errorDescription: String? {
        switch self {
        case .noConnection:
            return "No network connection"
        case .timeout:
            return "Request timeout"
        case .serverError(let message):
            return "Server error: \(message)"
        }
    }
}

enum DatabaseError: LocalizedError {
    case connectionFailed
    case queryFailed(String)
    case dataCorruption
    
    var errorDescription: String? {
        switch self {
        case .connectionFailed:
            return "Database connection failed"
        case .queryFailed(let message):
            return "Query failed: \(message)"
        case .dataCorruption:
            return "Data corruption detected"
        }
    }
}
