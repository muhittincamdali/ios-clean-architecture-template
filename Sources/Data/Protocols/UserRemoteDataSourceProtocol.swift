import Foundation

/**
 * User Remote Data Source Protocol - Data Layer
 * 
 * Abstract interface for remote user data operations.
 * Defines the contract for remote user data source implementations.
 * 
 * - Author: iOS Clean Architecture Team
 * - Version: 2.0.0
 * - Date: 2024-01-15
 */

// MARK: - User Remote Data Source Protocol
protocol UserRemoteDataSourceProtocol {
    func getUser(id: String) async throws -> User
    func getUsers(limit: Int, offset: Int, isActive: Bool?) async throws -> [User]
    func createUser(_ user: User) async throws -> User
    func updateUser(_ user: User) async throws -> User
    func deleteUser(id: String) async throws
    func searchUsers(query: String) async throws -> [User]
    func getUsersByRole(_ role: UserRole) async throws -> [User]
}

// MARK: - User Remote Data Source Error
enum UserRemoteDataSourceError: LocalizedError {
    case userNotFound
    case invalidUser
    case duplicateEmail
    case networkError(Error)
    case serverError(String)
    case authenticationError(String)
    case authorizationError(String)
    case rateLimitExceeded
    case timeout(String)
    case invalidResponse(String)
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .userNotFound:
            return "User not found in remote data source"
        case .invalidUser:
            return "Invalid user data"
        case .duplicateEmail:
            return "Email already exists in remote data source"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .serverError(let message):
            return "Server error: \(message)"
        case .authenticationError(let message):
            return "Authentication error: \(message)"
        case .authorizationError(let message):
            return "Authorization error: \(message)"
        case .rateLimitExceeded:
            return "Rate limit exceeded"
        case .timeout(let message):
            return "Request timeout: \(message)"
        case .invalidResponse(let message):
            return "Invalid response: \(message)"
        case .unknown(let error):
            return "Unknown error: \(error.localizedDescription)"
        }
    }
    
    var errorCode: Int {
        switch self {
        case .userNotFound:
            return 3001
        case .invalidUser:
            return 3002
        case .duplicateEmail:
            return 3003
        case .networkError:
            return 3004
        case .serverError:
            return 3005
        case .authenticationError:
            return 3006
        case .authorizationError:
            return 3007
        case .rateLimitExceeded:
            return 3008
        case .timeout:
            return 3009
        case .invalidResponse:
            return 3010
        case .unknown:
            return 3099
        }
    }
}

// MARK: - User Remote Data Source Options
struct UserRemoteDataSourceOptions {
    let timeout: TimeInterval
    let retryCount: Int
    let retryDelay: TimeInterval
    let includeInactive: Bool
    let includeDeleted: Bool
    let includePermissions: Bool
    let includeActivity: Bool
    let cacheResults: Bool
    let cacheExpiration: TimeInterval
    
    init(
        timeout: TimeInterval = 30.0,
        retryCount: Int = 3,
        retryDelay: TimeInterval = 1.0,
        includeInactive: Bool = false,
        includeDeleted: Bool = false,
        includePermissions: Bool = false,
        includeActivity: Bool = false,
        cacheResults: Bool = true,
        cacheExpiration: TimeInterval = 300
    ) {
        self.timeout = timeout
        self.retryCount = retryCount
        self.retryDelay = retryDelay
        self.includeInactive = includeInactive
        self.includeDeleted = includeDeleted
        self.includePermissions = includePermissions
        self.includeActivity = includeActivity
        self.cacheResults = cacheResults
        self.cacheExpiration = cacheExpiration
    }
}

// MARK: - User Remote Data Source Statistics
struct UserRemoteDataSourceStatistics {
    let totalRequests: Int
    let successfulRequests: Int
    let failedRequests: Int
    let averageResponseTime: TimeInterval
    let cacheHitRate: Double
    let errorRate: Double
    let lastRequestTime: Date?
    let timestamp: Date
    
    init(
        totalRequests: Int = 0,
        successfulRequests: Int = 0,
        failedRequests: Int = 0,
        averageResponseTime: TimeInterval = 0,
        cacheHitRate: Double = 0,
        errorRate: Double = 0,
        lastRequestTime: Date? = nil
    ) {
        self.totalRequests = totalRequests
        self.successfulRequests = successfulRequests
        self.failedRequests = failedRequests
        self.averageResponseTime = averageResponseTime
        self.cacheHitRate = cacheHitRate
        self.errorRate = errorRate
        self.lastRequestTime = lastRequestTime
        self.timestamp = Date()
    }
}

// MARK: - User Remote Data Source Extensions
extension UserRemoteDataSourceProtocol {
    
    // MARK: - Convenience Methods
    func getAllUsers() async throws -> [User] {
        return try await getUsers(limit: 1000, offset: 0, isActive: nil)
    }
    
    func getActiveUsers() async throws -> [User] {
        return try await getUsers(limit: 1000, offset: 0, isActive: true)
    }
    
    func getInactiveUsers() async throws -> [User] {
        return try await getUsers(limit: 1000, offset: 0, isActive: false)
    }
    
    func getUsersByPage(page: Int, pageSize: Int) async throws -> [User] {
        let offset = page * pageSize
        return try await getUsers(limit: pageSize, offset: offset, isActive: nil)
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
            throw UserRemoteDataSourceError.invalidUser
        }
        
        guard !user.name.isEmpty else {
            throw UserRemoteDataSourceError.invalidUser
        }
        
        guard !user.email.isEmpty else {
            throw UserRemoteDataSourceError.invalidUser
        }
        
        return true
    }
    
    // MARK: - Statistics Methods
    func getStatistics() -> UserRemoteDataSourceStatistics {
        // This would typically track actual statistics
        return UserRemoteDataSourceStatistics()
    }
    
    // MARK: - Batch Operations
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
}

// MARK: - User Remote Data Source Categories
extension UserRemoteDataSourceProtocol {
    
    struct Category {
        static let remote = "Remote"
        static let network = "Network"
        static let api = "API"
        static let cache = "Cache"
        static let performance = "Performance"
    }
} 