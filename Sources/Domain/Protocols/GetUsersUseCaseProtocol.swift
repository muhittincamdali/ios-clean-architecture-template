import Foundation

/**
 * Get Users Use Case Protocol - Domain Layer
 * 
 * Abstract interface for multiple user retrieval operations.
 * Defines the contract for user list retrieval implementations.
 * 
 * - Author: iOS Clean Architecture Team
 * - Version: 2.0.0
 * - Date: 2024-01-15
 */

// MARK: - Get Users Use Case Protocol
protocol GetUsersUseCaseProtocol {
    func execute() async throws -> [User]
    func execute(limit: Int, offset: Int) async throws -> [User]
    func execute(filter: UserFilter) async throws -> [User]
    func execute(options: GetUsersOptions) async throws -> UsersResult
}

// MARK: - Supporting Types
struct UsersResult {
    let users: [User]
    let totalCount: Int
    let hasMore: Bool
    let metadata: UsersMetadata
}

struct UsersMetadata {
    let retrievedAt: Date
    let totalCount: Int
    let activeCount: Int
    let inactiveCount: Int
    let roleDistribution: [UserRole: Int]
    let cacheUsed: Bool
    let filterApplied: String?
    let sortApplied: String?
}

struct GetUsersOptions {
    let limit: Int
    let offset: Int
    let filter: UserFilter?
    let sortBy: UserSortBy?
    let includeActiveOnly: Bool
    let includeAdminsOnly: Bool
    let useCache: Bool
    let cacheExpiration: TimeInterval
    
    init(
        limit: Int = 100,
        offset: Int = 0,
        filter: UserFilter? = nil,
        sortBy: UserSortBy? = nil,
        includeActiveOnly: Bool = false,
        includeAdminsOnly: Bool = false,
        useCache: Bool = true,
        cacheExpiration: TimeInterval = 300
    ) {
        self.limit = limit
        self.offset = offset
        self.filter = filter
        self.sortBy = sortBy
        self.includeActiveOnly = includeActiveOnly
        self.includeAdminsOnly = includeAdminsOnly
        self.useCache = useCache
        self.cacheExpiration = cacheExpiration
    }
    
    var description: String {
        var desc = "limit:\(limit),offset:\(offset)"
        if let filter = filter {
            desc += ",filter:\(filter.rawValue)"
        }
        if let sortBy = sortBy {
            desc += ",sort:\(sortBy.rawValue)"
        }
        if includeActiveOnly {
            desc += ",activeOnly"
        }
        if includeAdminsOnly {
            desc += ",adminsOnly"
        }
        return desc
    }
}

enum UserFilter: String, CaseIterable {
    case all = "all"
    case active = "active"
    case inactive = "inactive"
    case admin = "admin"
    case moderator = "moderator"
    case user = "user"
    
    var displayName: String {
        switch self {
        case .all:
            return "All Users"
        case .active:
            return "Active Users"
        case .inactive:
            return "Inactive Users"
        case .admin:
            return "Administrators"
        case .moderator:
            return "Moderators"
        case .user:
            return "Regular Users"
        }
    }
}

enum UserSortBy: String, CaseIterable {
    case name = "name"
    case email = "email"
    case role = "role"
    case createdAt = "createdAt"
    case updatedAt = "updatedAt"
    
    var displayName: String {
        switch self {
        case .name:
            return "Name"
        case .email:
            return "Email"
        case .role:
            return "Role"
        case .createdAt:
            return "Created Date"
        case .updatedAt:
            return "Updated Date"
        }
    }
}

// MARK: - Get Users Use Case Error
enum GetUsersUseCaseError: LocalizedError {
    case invalidLimit(String)
    case invalidOffset(String)
    case networkError(Error)
    case databaseError(Error)
    case validationError(String)
    case permissionDenied
    case rateLimitExceeded
    case serverError(String)
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidLimit(let message):
            return "Invalid limit: \(message)"
        case .invalidOffset(let message):
            return "Invalid offset: \(message)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .databaseError(let error):
            return "Database error: \(error.localizedDescription)"
        case .validationError(let message):
            return "Validation error: \(message)"
        case .permissionDenied:
            return "Permission denied to access users"
        case .rateLimitExceeded:
            return "Rate limit exceeded for users retrieval"
        case .serverError(let message):
            return "Server error: \(message)"
        case .unknown(let error):
            return "Unknown error: \(error.localizedDescription)"
        }
    }
} 