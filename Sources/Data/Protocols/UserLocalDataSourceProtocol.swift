import Foundation

/**
 * User Local Data Source Protocol - Data Layer
 * 
 * Abstract interface for local user data operations.
 * Defines the contract for local user data source implementations.
 * 
 * - Author: iOS Clean Architecture Team
 * - Version: 2.0.0
 * - Date: 2024-01-15
 */

// MARK: - User Local Data Source Protocol
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
    func clearAllUsers() async throws
    func getUserCount() async throws -> Int
    func getUsersByDateRange(from: Date, to: Date) async throws -> [User]
}

// MARK: - User Local Data Source Error
enum UserLocalDataSourceError: LocalizedError {
    case userNotFound
    case invalidUser
    case saveFailed(String)
    case loadFailed(String)
    case deleteFailed(String)
    case clearFailed(String)
    case databaseError(String)
    case storageError(String)
    case encodingError(String)
    case decodingError(String)
    case permissionDenied(String)
    case capacityExceeded(String)
    case corrupted(String)
    case unknown(String)
    
    var errorDescription: String? {
        switch self {
        case .userNotFound:
            return "User not found in local storage"
        case .invalidUser:
            return "Invalid user data"
        case .saveFailed(let message):
            return "Failed to save user: \(message)"
        case .loadFailed(let message):
            return "Failed to load user: \(message)"
        case .deleteFailed(let message):
            return "Failed to delete user: \(message)"
        case .clearFailed(let message):
            return "Failed to clear users: \(message)"
        case .databaseError(let message):
            return "Database error: \(message)"
        case .storageError(let message):
            return "Storage error: \(message)"
        case .encodingError(let message):
            return "Encoding error: \(message)"
        case .decodingError(let message):
            return "Decoding error: \(message)"
        case .permissionDenied(let message):
            return "Permission denied: \(message)"
        case .capacityExceeded(let message):
            return "Storage capacity exceeded: \(message)"
        case .corrupted(let message):
            return "Data corrupted: \(message)"
        case .unknown(let message):
            return "Unknown error: \(message)"
        }
    }
    
    var errorCode: Int {
        switch self {
        case .userNotFound:
            return 4001
        case .invalidUser:
            return 4002
        case .saveFailed:
            return 4003
        case .loadFailed:
            return 4004
        case .deleteFailed:
            return 4005
        case .clearFailed:
            return 4006
        case .databaseError:
            return 4007
        case .storageError:
            return 4008
        case .encodingError:
            return 4009
        case .decodingError:
            return 4010
        case .permissionDenied:
            return 4011
        case .capacityExceeded:
            return 4012
        case .corrupted:
            return 4013
        case .unknown:
            return 4099
        }
    }
}

// MARK: - User Local Data Source Options
struct UserLocalDataSourceOptions {
    let storageType: StorageType
    let encryptionEnabled: Bool
    let compressionEnabled: Bool
    let backupEnabled: Bool
    let syncEnabled: Bool
    let maxStorageSize: Int64
    let cacheEnabled: Bool
    let cacheExpiration: TimeInterval
    
    enum StorageType {
        case userDefaults
        case keychain
        case coreData
        case fileSystem
        case sqlite
        case realm
    }
    
    init(
        storageType: StorageType = .coreData,
        encryptionEnabled: Bool = true,
        compressionEnabled: Bool = false,
        backupEnabled: Bool = true,
        syncEnabled: Bool = false,
        maxStorageSize: Int64 = 100 * 1024 * 1024, // 100 MB
        cacheEnabled: Bool = true,
        cacheExpiration: TimeInterval = 3600 // 1 hour
    ) {
        self.storageType = storageType
        self.encryptionEnabled = encryptionEnabled
        self.compressionEnabled = compressionEnabled
        self.backupEnabled = backupEnabled
        self.syncEnabled = syncEnabled
        self.maxStorageSize = maxStorageSize
        self.cacheEnabled = cacheEnabled
        self.cacheExpiration = cacheExpiration
    }
}

// MARK: - User Local Data Source Statistics
struct UserLocalDataSourceStatistics {
    let totalUsers: Int
    let activeUsers: Int
    let inactiveUsers: Int
    let storageSize: Int64
    let cacheHitRate: Double
    let averageLoadTime: TimeInterval
    let lastSyncTime: Date?
    let lastBackupTime: Date?
    let timestamp: Date
    
    init(
        totalUsers: Int = 0,
        activeUsers: Int = 0,
        inactiveUsers: Int = 0,
        storageSize: Int64 = 0,
        cacheHitRate: Double = 0,
        averageLoadTime: TimeInterval = 0,
        lastSyncTime: Date? = nil,
        lastBackupTime: Date? = nil
    ) {
        self.totalUsers = totalUsers
        self.activeUsers = activeUsers
        self.inactiveUsers = inactiveUsers
        self.storageSize = storageSize
        self.cacheHitRate = cacheHitRate
        self.averageLoadTime = averageLoadTime
        self.lastSyncTime = lastSyncTime
        self.lastBackupTime = lastBackupTime
        self.timestamp = Date()
    }
}

// MARK: - User Local Data Source Extensions
extension UserLocalDataSourceProtocol {
    
    // MARK: - Convenience Methods
    func getAllUsers() async throws -> [User] {
        return try await getUsers(limit: 1000, offset: 0, isActive: nil) ?? []
    }
    
    func getActiveUsers() async throws -> [User] {
        return try await getUsers(limit: 1000, offset: 0, isActive: true) ?? []
    }
    
    func getInactiveUsers() async throws -> [User] {
        return try await getUsers(limit: 1000, offset: 0, isActive: false) ?? []
    }
    
    func getUsersByPage(page: Int, pageSize: Int) async throws -> [User] {
        let offset = page * pageSize
        return try await getUsers(limit: pageSize, offset: offset, isActive: nil) ?? []
    }
    
    func getUserByEmail(_ email: String) async throws -> User? {
        let users = try await searchUsers(query: email)
        return users.first { $0.email.lowercased() == email.lowercased() }
    }
    
    func getAdmins() async throws -> [User] {
        return try await getUsersByRole(.admin)
    }
    
    func getModerators() async throws -> [User] {
        return try await getUsersByRole(.moderator)
    }
    
    func getRegularUsers() async throws -> [User] {
        return try await getUsersByRole(.user)
    }
    
    // MARK: - Validation Methods
    func validateUserData(_ user: User) async throws -> Bool {
        guard !user.id.isEmpty else {
            throw UserLocalDataSourceError.invalidUser
        }
        
        guard !user.name.isEmpty else {
            throw UserLocalDataSourceError.invalidUser
        }
        
        guard !user.email.isEmpty else {
            throw UserLocalDataSourceError.invalidUser
        }
        
        return true
    }
    
    // MARK: - Statistics Methods
    func getStatistics() -> UserLocalDataSourceStatistics {
        // This would typically return actual statistics
        return UserLocalDataSourceStatistics()
    }
    
    // MARK: - Batch Operations
    func batchSaveUsers(_ users: [User]) async throws {
        for user in users {
            try await saveUser(user)
        }
    }
    
    func batchCreateUsers(_ users: [User]) async throws -> [User] {
        var createdUsers: [User] = []
        
        for user in users {
            let createdUser = try await createUser(user)
            createdUsers.append(createdUser)
        }
        
        return createdUsers
    }
    
    func batchUpdateUsers(_ users: [User]) async throws -> [User] {
        var updatedUsers: [User] = []
        
        for user in users {
            let updatedUser = try await updateUser(user)
            updatedUsers.append(updatedUser)
        }
        
        return updatedUsers
    }
    
    func batchDeleteUsers(ids: [String]) async throws {
        for id in ids {
            try await deleteUser(id: id)
        }
    }
    
    // MARK: - Utility Methods
    func isUserExists(id: String) async throws -> Bool {
        let user = try await getUser(id: id)
        return user != nil
    }
    
    func isEmailExists(_ email: String) async throws -> Bool {
        let user = try await getUserByEmail(email)
        return user != nil
    }
    
    func getUsersByLastLogin(days: Int) async throws -> [User] {
        let cutoffDate = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        return try await getUsersByDateRange(from: cutoffDate, to: Date())
    }
    
    func getUsersCreatedInLastDays(_ days: Int) async throws -> [User] {
        let cutoffDate = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        return try await getUsersByDateRange(from: cutoffDate, to: Date())
    }
}

// MARK: - User Local Data Source Categories
extension UserLocalDataSourceProtocol {
    
    struct Category {
        static let local = "Local"
        static let storage = "Storage"
        static let database = "Database"
        static let cache = "Cache"
        static let performance = "Performance"
    }
} 