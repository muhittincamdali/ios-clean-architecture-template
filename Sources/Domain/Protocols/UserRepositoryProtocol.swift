import Foundation

/**
 * User Repository Protocol - Domain Layer
 * 
 * Abstract interface for user data operations.
 * Defines the contract for user repository implementations.
 * 
 * - Author: iOS Clean Architecture Team
 * - Version: 2.0.0
 * - Date: 2024-01-15
 */

// MARK: - User Repository Protocol
protocol UserRepositoryProtocol {
    
    // MARK: - Basic CRUD Operations
    func getUser(id: String) async throws -> User
    func getUsers(limit: Int, offset: Int, isActive: Bool?) async throws -> [User]
    func createUser(_ user: User) async throws -> User
    func updateUser(_ user: User) async throws -> User
    func deleteUser(id: String) async throws
    
    // MARK: - Search and Filter Operations
    func searchUsers(query: String) async throws -> [User]
    func getUsersByRole(_ role: UserRole) async throws -> [User]
    func getActiveUsers() async throws -> [User]
    func getInactiveUsers() async throws -> [User]
    
    // MARK: - Validation Operations
    func userExists(id: String) async throws -> Bool
    func emailExists(_ email: String) async throws -> Bool
    func validateUser(_ user: User) async throws -> Bool
    
    // MARK: - Analytics Operations
    func getUserCount(isActive: Bool?) async throws -> Int
    func getUsersByDateRange(from: Date, to: Date) async throws -> [User]
    func getUsersByLastLogin(days: Int) async throws -> [User]
    
    // MARK: - Bulk Operations
    func createUsers(_ users: [User]) async throws -> [User]
    func updateUsers(_ users: [User]) async throws -> [User]
    func deleteUsers(ids: [String]) async throws
    func activateUsers(ids: [String]) async throws
    func deactivateUsers(ids: [String]) async throws
    
    // MARK: - Advanced Operations
    func getUserWithPermissions(id: String) async throws -> User
    func updateUserRole(id: String, role: UserRole) async throws -> User
    func updateUserStatus(id: String, isActive: Bool) async throws -> User
    func getUserActivity(id: String) async throws -> UserActivity
}

// MARK: - User Activity
struct UserActivity: Codable {
    let userId: String
    let lastLoginDate: Date?
    let loginCount: Int
    let lastActivityDate: Date?
    let totalSessionTime: TimeInterval
    let createdContentCount: Int
    let editedContentCount: Int
    let deletedContentCount: Int
    let moderationActionsCount: Int
    
    init(
        userId: String,
        lastLoginDate: Date? = nil,
        loginCount: Int = 0,
        lastActivityDate: Date? = nil,
        totalSessionTime: TimeInterval = 0,
        createdContentCount: Int = 0,
        editedContentCount: Int = 0,
        deletedContentCount: Int = 0,
        moderationActionsCount: Int = 0
    ) {
        self.userId = userId
        self.lastLoginDate = lastLoginDate
        self.loginCount = loginCount
        self.lastActivityDate = lastActivityDate
        self.totalSessionTime = totalSessionTime
        self.createdContentCount = createdContentCount
        self.editedContentCount = editedContentCount
        self.deletedContentCount = deletedContentCount
        self.moderationActionsCount = moderationActionsCount
    }
}

// MARK: - User Repository Error
enum UserRepositoryError: LocalizedError {
    case userNotFound
    case invalidUser
    case duplicateEmail
    case networkError(Error)
    case databaseError(Error)
    case validationError(String)
    case permissionDenied
    case rateLimitExceeded
    case serverError(String)
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .userNotFound:
            return "User not found"
        case .invalidUser:
            return "Invalid user data"
        case .duplicateEmail:
            return "Email already exists"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .databaseError(let error):
            return "Database error: \(error.localizedDescription)"
        case .validationError(let message):
            return "Validation error: \(message)"
        case .permissionDenied:
            return "Permission denied"
        case .rateLimitExceeded:
            return "Rate limit exceeded"
        case .serverError(let message):
            return "Server error: \(message)"
        case .unknown(let error):
            return "Unknown error: \(error.localizedDescription)"
        }
    }
}

// MARK: - User Repository Result
enum UserRepositoryResult<T> {
    case success(T)
    case failure(UserRepositoryError)
}

// MARK: - User Repository Options
struct UserRepositoryOptions {
    let includeInactive: Bool
    let includeDeleted: Bool
    let includePermissions: Bool
    let includeActivity: Bool
    let cacheResults: Bool
    let timeout: TimeInterval
    
    init(
        includeInactive: Bool = false,
        includeDeleted: Bool = false,
        includePermissions: Bool = false,
        includeActivity: Bool = false,
        cacheResults: Bool = true,
        timeout: TimeInterval = 30.0
    ) {
        self.includeInactive = includeInactive
        self.includeDeleted = includeDeleted
        self.includePermissions = includePermissions
        self.includeActivity = includeActivity
        self.cacheResults = cacheResults
        self.timeout = timeout
    }
}

// MARK: - User Repository Statistics
struct UserRepositoryStatistics {
    let totalUsers: Int
    let activeUsers: Int
    let inactiveUsers: Int
    let adminUsers: Int
    let moderatorUsers: Int
    let regularUsers: Int
    let usersCreatedToday: Int
    let usersCreatedThisWeek: Int
    let usersCreatedThisMonth: Int
    let averageSessionTime: TimeInterval
    let mostActiveUsers: [User]
    
    init(
        totalUsers: Int = 0,
        activeUsers: Int = 0,
        inactiveUsers: Int = 0,
        adminUsers: Int = 0,
        moderatorUsers: Int = 0,
        regularUsers: Int = 0,
        usersCreatedToday: Int = 0,
        usersCreatedThisWeek: Int = 0,
        usersCreatedThisMonth: Int = 0,
        averageSessionTime: TimeInterval = 0,
        mostActiveUsers: [User] = []
    ) {
        self.totalUsers = totalUsers
        self.activeUsers = activeUsers
        self.inactiveUsers = inactiveUsers
        self.adminUsers = adminUsers
        self.moderatorUsers = moderatorUsers
        self.regularUsers = regularUsers
        self.usersCreatedToday = usersCreatedToday
        self.usersCreatedThisWeek = usersCreatedThisWeek
        self.usersCreatedThisMonth = usersCreatedThisMonth
        self.averageSessionTime = averageSessionTime
        self.mostActiveUsers = mostActiveUsers
    }
}

// MARK: - User Repository Extensions
extension UserRepositoryProtocol {
    
    // MARK: - Convenience Methods
    func getAllUsers() async throws -> [User] {
        return try await getUsers(limit: 1000, offset: 0, isActive: nil)
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
        guard user.isValid else {
            throw UserRepositoryError.validationError("User data is invalid")
        }
        
        if try await emailExists(user.email) {
            throw UserRepositoryError.duplicateEmail
        }
        
        return true
    }
    
    // MARK: - Statistics Methods
    func getStatistics() async throws -> UserRepositoryStatistics {
        let totalUsers = try await getUserCount(isActive: nil)
        let activeUsers = try await getUserCount(isActive: true)
        let inactiveUsers = try await getUserCount(isActive: false)
        
        let admins = try await getAdmins()
        let moderators = try await getModerators()
        let regularUsers = try await getRegularUsers()
        
        return UserRepositoryStatistics(
            totalUsers: totalUsers,
            activeUsers: activeUsers,
            inactiveUsers: inactiveUsers,
            adminUsers: admins.count,
            moderatorUsers: moderators.count,
            regularUsers: regularUsers.count
        )
    }
    
    // MARK: - Batch Operations
    func batchUpdateUserRoles(_ updates: [(String, UserRole)]) async throws {
        for (userId, newRole) in updates {
            _ = try await updateUserRole(id: userId, role: newRole)
        }
    }
    
    func batchUpdateUserStatus(_ updates: [(String, Bool)]) async throws {
        for (userId, isActive) in updates {
            _ = try await updateUserStatus(id: userId, isActive: isActive)
        }
    }
}
