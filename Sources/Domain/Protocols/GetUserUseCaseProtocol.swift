import Foundation

/**
 * Get User Use Case Protocol - Domain Layer
 * 
 * Abstract interface for user retrieval operations.
 * Defines the contract for user retrieval implementations.
 * 
 * - Author: iOS Clean Architecture Team
 * - Version: 2.0.0
 * - Date: 2024-01-15
 */

// MARK: - Get User Use Case Protocol
protocol GetUserUseCaseProtocol {
    func execute(id: String) async throws -> User
    func execute(id: String, includeInactive: Bool) async throws -> User
    func execute(id: String, options: GetUserOptions) async throws -> UserResult
}

// MARK: - Supporting Types
struct UserResult {
    let user: User
    let metadata: UserMetadata
    let warnings: [String]
}

struct UserMetadata {
    let retrievedAt: Date
    let userId: String
    let includeInactive: Bool
    let includePermissions: Bool
    let includeActivity: Bool
    let cacheUsed: Bool
    let cacheExpiration: TimeInterval
}

struct GetUserOptions {
    let includeInactive: Bool
    let includePermissions: Bool
    let includeActivity: Bool
    let useCache: Bool
    let cacheExpiration: TimeInterval
    
    init(
        includeInactive: Bool = false,
        includePermissions: Bool = false,
        includeActivity: Bool = false,
        useCache: Bool = true,
        cacheExpiration: TimeInterval = 300
    ) {
        self.includeInactive = includeInactive
        self.includePermissions = includePermissions
        self.includeActivity = includeActivity
        self.useCache = useCache
        self.cacheExpiration = cacheExpiration
    }
    
    var description: String {
        var desc = "includeInactive:\(includeInactive)"
        if includePermissions {
            desc += ",includePermissions:true"
        }
        if includeActivity {
            desc += ",includeActivity:true"
        }
        if useCache {
            desc += ",useCache:true"
        }
        return desc
    }
    
    var hashValue: Int {
        var hasher = Hasher()
        hasher.combine(includeInactive)
        hasher.combine(includePermissions)
        hasher.combine(includeActivity)
        hasher.combine(useCache)
        hasher.combine(cacheExpiration)
        return hasher.finalize()
    }
}

// MARK: - Get User Use Case Error
enum GetUserUseCaseError: LocalizedError {
    case invalidUserId(String)
    case userNotFound
    case userInactive
    case invalidOptions(String)
    case networkError(Error)
    case databaseError(Error)
    case validationError(String)
    case permissionDenied
    case rateLimitExceeded
    case serverError(String)
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidUserId(let message):
            return "Invalid user ID: \(message)"
        case .userNotFound:
            return "User not found"
        case .userInactive:
            return "User is inactive"
        case .invalidOptions(let message):
            return "Invalid options: \(message)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .databaseError(let error):
            return "Database error: \(error.localizedDescription)"
        case .validationError(let message):
            return "Validation error: \(message)"
        case .permissionDenied:
            return "Permission denied to access user"
        case .rateLimitExceeded:
            return "Rate limit exceeded for user retrieval"
        case .serverError(let message):
            return "Server error: \(message)"
        case .unknown(let error):
            return "Unknown error: \(error.localizedDescription)"
        }
    }
} 