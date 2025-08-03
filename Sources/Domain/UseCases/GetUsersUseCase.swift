import Foundation

/**
 * Get Users Use Case - Domain Layer
 * 
 * Business logic for retrieving multiple users with filtering and pagination.
 * Implements Clean Architecture principles with proper error handling.
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

// MARK: - Get Users Use Case Implementation
struct GetUsersUseCase: GetUsersUseCaseProtocol {
    
    // MARK: - Dependencies
    private let repository: UserRepositoryProtocol
    private let validator: UserValidatorProtocol
    private let cacheManager: CacheManagerProtocol?
    private let analyticsService: AnalyticsServiceProtocol?
    
    // MARK: - Initialization
    init(
        repository: UserRepositoryProtocol,
        validator: UserValidatorProtocol = UserValidator(),
        cacheManager: CacheManagerProtocol? = nil,
        analyticsService: AnalyticsServiceProtocol? = nil
    ) {
        self.repository = repository
        self.validator = validator
        self.cacheManager = cacheManager
        self.analyticsService = analyticsService
    }
    
    // MARK: - Basic Users Retrieval
    func execute() async throws -> [User] {
        return try await execute(limit: 100, offset: 0)
    }
    
    func execute(limit: Int, offset: Int) async throws -> [User] {
        let startTime = Date()
        
        do {
            // Validate parameters
            try validatePaginationParameters(limit: limit, offset: offset)
            
            // Check cache first
            let cacheKey = "users_\(limit)_\(offset)"
            if let cachedUsers: [User] = try await cacheManager?.get(forKey: cacheKey) {
                analyticsService?.trackEvent("users_cache_hit", parameters: [
                    "limit": limit,
                    "offset": offset,
                    "count": cachedUsers.count
                ])
                return cachedUsers
            }
            
            // Fetch users from repository
            let users = try await repository.getUsers(limit: limit, offset: offset, isActive: nil)
            
            // Validate users data
            try validateUsers(users)
            
            // Cache the result
            try await cacheManager?.set(users, forKey: cacheKey, expiration: 300) // 5 minutes
            
            // Track analytics
            let duration = Date().timeIntervalSince(startTime)
            analyticsService?.trackEvent("users_retrieved", parameters: [
                "limit": limit,
                "offset": offset,
                "count": users.count,
                "duration": duration,
                "cached": false
            ])
            
            return users
            
        } catch {
            // Track error
            let duration = Date().timeIntervalSince(startTime)
            analyticsService?.trackEvent("users_retrieval_error", parameters: [
                "limit": limit,
                "offset": offset,
                "error": error.localizedDescription,
                "duration": duration
            ])
            
            throw handleError(error)
        }
    }
    
    // MARK: - Filtered Users Retrieval
    func execute(filter: UserFilter) async throws -> [User] {
        let startTime = Date()
        
        do {
            // Validate filter
            try validateFilter(filter)
            
            // Fetch users based on filter
            let users: [User]
            switch filter {
            case .all:
                users = try await repository.getUsers(limit: 1000, offset: 0, isActive: nil)
            case .active:
                users = try await repository.getActiveUsers()
            case .inactive:
                users = try await repository.getInactiveUsers()
            case .admin:
                users = try await repository.getUsersByRole(.admin)
            case .moderator:
                users = try await repository.getUsersByRole(.moderator)
            case .user:
                users = try await repository.getUsersByRole(.user)
            }
            
            // Validate users data
            try validateUsers(users)
            
            // Track analytics
            let duration = Date().timeIntervalSince(startTime)
            analyticsService?.trackEvent("users_filtered_retrieved", parameters: [
                "filter": filter.rawValue,
                "count": users.count,
                "duration": duration
            ])
            
            return users
            
        } catch {
            // Track error
            let duration = Date().timeIntervalSince(startTime)
            analyticsService?.trackEvent("users_filtered_error", parameters: [
                "filter": filter.rawValue,
                "error": error.localizedDescription,
                "duration": duration
            ])
            
            throw handleError(error)
        }
    }
    
    // MARK: - Advanced Users Retrieval with Options
    func execute(options: GetUsersOptions) async throws -> UsersResult {
        let startTime = Date()
        
        do {
            // Validate options
            try validateOptions(options)
            
            // Check cache if enabled
            let cacheKey = "users_result_\(options.hashValue)"
            if options.useCache, let cachedResult: UsersResult = try await cacheManager?.get(forKey: cacheKey) {
                analyticsService?.trackEvent("users_result_cache_hit", parameters: [
                    "options": options.description
                ])
                return cachedResult
            }
            
            // Fetch users based on options
            var users: [User] = []
            
            if let filter = options.filter {
                users = try await execute(filter: filter)
            } else {
                users = try await execute(limit: options.limit, offset: options.offset)
            }
            
            // Apply additional filtering
            if options.includeActiveOnly {
                users = users.filter { $0.isActive }
            }
            
            if options.includeAdminsOnly {
                users = users.filter { $0.isAdmin }
            }
            
            // Sort users if specified
            if let sortBy = options.sortBy {
                users = sortUsers(users, by: sortBy)
            }
            
            // Validate users data
            try validateUsers(users)
            
            // Create result
            let result = UsersResult(
                users: users,
                totalCount: users.count,
                hasMore: users.count >= options.limit,
                metadata: createMetadata(for: users, options: options)
            )
            
            // Cache result if enabled
            if options.useCache {
                try await cacheManager?.set(result, forKey: cacheKey, expiration: options.cacheExpiration)
            }
            
            // Track analytics
            let duration = Date().timeIntervalSince(startTime)
            analyticsService?.trackEvent("users_result_retrieved", parameters: [
                "options": options.description,
                "count": users.count,
                "duration": duration
            ])
            
            return result
            
        } catch {
            // Track error
            let duration = Date().timeIntervalSince(startTime)
            analyticsService?.trackEvent("users_result_error", parameters: [
                "options": options.description,
                "error": error.localizedDescription,
                "duration": duration
            ])
            
            throw handleError(error)
        }
    }
    
    // MARK: - Private Methods
    private func validatePaginationParameters(limit: Int, offset: Int) throws {
        guard limit > 0 && limit <= 1000 else {
            throw GetUsersUseCaseError.invalidLimit("Limit must be between 1 and 1000")
        }
        
        guard offset >= 0 else {
            throw GetUsersUseCaseError.invalidOffset("Offset must be non-negative")
        }
    }
    
    private func validateFilter(_ filter: UserFilter) throws {
        // Filter validation logic can be added here
        // For now, all filters are considered valid
    }
    
    private func validateOptions(_ options: GetUsersOptions) throws {
        guard options.limit > 0 && options.limit <= 1000 else {
            throw GetUsersUseCaseError.invalidLimit("Limit must be between 1 and 1000")
        }
        
        guard options.offset >= 0 else {
            throw GetUsersUseCaseError.invalidOffset("Offset must be non-negative")
        }
    }
    
    private func validateUsers(_ users: [User]) throws {
        for user in users {
            try validator.validateUser(user)
        }
    }
    
    private func sortUsers(_ users: [User], by sortBy: UserSortBy) -> [User] {
        switch sortBy {
        case .name:
            return users.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        case .email:
            return users.sorted { $0.email.localizedCaseInsensitiveCompare($1.email) == .orderedAscending }
        case .role:
            return users.sorted { $0.role.priority < $1.role.priority }
        case .createdAt:
            return users.sorted { $0.createdAt > $1.createdAt }
        case .updatedAt:
            return users.sorted { $0.updatedAt > $1.updatedAt }
        }
    }
    
    private func createMetadata(for users: [User], options: GetUsersOptions) -> UsersMetadata {
        let roleDistribution = Dictionary(grouping: users, by: { $0.role })
            .mapValues { $0.count }
        
        return UsersMetadata(
            retrievedAt: Date(),
            totalCount: users.count,
            activeCount: users.filter { $0.isActive }.count,
            inactiveCount: users.filter { !$0.isActive }.count,
            roleDistribution: roleDistribution,
            cacheUsed: options.useCache,
            filterApplied: options.filter?.rawValue,
            sortApplied: options.sortBy?.rawValue
        )
    }
    
    private func handleError(_ error: Error) -> Error {
        if let repositoryError = error as? UserRepositoryError {
            switch repositoryError {
            case .networkError(let underlyingError):
                return GetUsersUseCaseError.networkError(underlyingError)
            case .databaseError(let underlyingError):
                return GetUsersUseCaseError.databaseError(underlyingError)
            case .validationError(let message):
                return GetUsersUseCaseError.validationError(message)
            case .permissionDenied:
                return GetUsersUseCaseError.permissionDenied
            case .rateLimitExceeded:
                return GetUsersUseCaseError.rateLimitExceeded
            case .serverError(let message):
                return GetUsersUseCaseError.serverError(message)
            default:
                return GetUsersUseCaseError.unknown(error)
            }
        }
        
        return GetUsersUseCaseError.unknown(error)
    }
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