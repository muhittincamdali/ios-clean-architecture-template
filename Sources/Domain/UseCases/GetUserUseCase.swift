import Foundation

/**
 * Get User Use Case - Domain Layer
 * 
 * Business logic for retrieving a single user by ID.
 * Implements Clean Architecture principles with proper error handling.
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

// MARK: - Get User Use Case Implementation
struct GetUserUseCase: GetUserUseCaseProtocol {
    
    // MARK: - Dependencies
    private let repository: UserRepositoryProtocol
    private let validator: UserValidatorProtocol
    private let cacheManager: CacheManagerProtocol?
    private let analyticsService: AnalyticsServiceProtocol?
    private let logger: LoggerProtocol?
    
    // MARK: - Initialization
    init(
        repository: UserRepositoryProtocol,
        validator: UserValidatorProtocol = UserValidator(),
        cacheManager: CacheManagerProtocol? = nil,
        analyticsService: AnalyticsServiceProtocol? = nil,
        logger: LoggerProtocol? = nil
    ) {
        self.repository = repository
        self.validator = validator
        self.cacheManager = cacheManager
        self.analyticsService = analyticsService
        self.logger = logger
    }
    
    // MARK: - Basic User Retrieval
    func execute(id: String) async throws -> User {
        return try await execute(id: id, includeInactive: false)
    }
    
    func execute(id: String, includeInactive: Bool) async throws -> User {
        let startTime = Date()
        
        do {
            // Validate input
            try validateUserId(id)
            
            // Check cache first
            let cacheKey = "user_\(id)"
            if let cachedUser: User = try await cacheManager?.get(forKey: cacheKey) {
                analyticsService?.trackEvent("user_cache_hit", parameters: [
                    "user_id": id,
                    "cached": true
                ])
                return cachedUser
            }
            
            // Fetch user from repository
            let user = try await repository.getUser(id: id)
            
            // Validate user data
            let validationResult = try await validator.validateUser(user)
            if !validationResult.isValid {
                throw GetUserUseCaseError.validationError(validationResult.errorMessages.joined(separator: ", "))
            }
            
            // Cache the result
            try await cacheManager?.set(user, forKey: cacheKey, expiration: 300) // 5 minutes
            
            // Track analytics
            let duration = Date().timeIntervalSince(startTime)
            analyticsService?.trackEvent("user_retrieved", parameters: [
                "user_id": id,
                "duration": duration,
                "cached": false
            ])
            
            logger?.info("User retrieved successfully: \(id)", category: "User", file: #file, function: #function, line: #line)
            
            return user
            
        } catch {
            // Track error
            let duration = Date().timeIntervalSince(startTime)
            analyticsService?.trackEvent("user_retrieval_error", parameters: [
                "user_id": id,
                "error": error.localizedDescription,
                "duration": duration
            ])
            
            logger?.error("Failed to retrieve user: \(error.localizedDescription)", category: "User", file: #file, function: #function, line: #line)
            
            throw handleError(error)
        }
    }
    
    // MARK: - Advanced User Retrieval with Options
    func execute(id: String, options: GetUserOptions) async throws -> UserResult {
        let startTime = Date()
        
        do {
            // Validate input
            try validateUserId(id)
            try validateOptions(options)
            
            // Check cache if enabled
            let cacheKey = "user_result_\(id)_\(options.hashValue)"
            if options.useCache, let cachedResult: UserResult = try await cacheManager?.get(forKey: cacheKey) {
                analyticsService?.trackEvent("user_result_cache_hit", parameters: [
                    "user_id": id,
                    "options": options.description
                ])
                return cachedResult
            }
            
            // Fetch user from repository
            let user = try await repository.getUser(id: id)
            
            // Apply filters
            var filteredUser = user
            
            if !options.includeInactive && !user.isActive {
                throw GetUserUseCaseError.userInactive
            }
            
            if options.includePermissions {
                // Add permission information if needed
                // This would typically involve additional repository calls
            }
            
            if options.includeActivity {
                // Add activity information if needed
                // This would typically involve additional repository calls
            }
            
            // Validate user data
            let validationResult = try await validator.validateUser(filteredUser)
            if !validationResult.isValid {
                throw GetUserUseCaseError.validationError(validationResult.errorMessages.joined(separator: ", "))
            }
            
            // Create result
            let result = UserResult(
                user: filteredUser,
                metadata: createMetadata(for: filteredUser, options: options),
                warnings: validationResult.warnings
            )
            
            // Cache result if enabled
            if options.useCache {
                try await cacheManager?.set(result, forKey: cacheKey, expiration: options.cacheExpiration)
            }
            
            // Track analytics
            let duration = Date().timeIntervalSince(startTime)
            analyticsService?.trackEvent("user_result_retrieved", parameters: [
                "user_id": id,
                "options": options.description,
                "duration": duration
            ])
            
            logger?.info("User result retrieved successfully: \(id)", category: "User", file: #file, function: #function, line: #line)
            
            return result
            
        } catch {
            // Track error
            let duration = Date().timeIntervalSince(startTime)
            analyticsService?.trackEvent("user_result_error", parameters: [
                "user_id": id,
                "options": options.description,
                "error": error.localizedDescription,
                "duration": duration
            ])
            
            logger?.error("Failed to retrieve user result: \(error.localizedDescription)", category: "User", file: #file, function: #function, line: #line)
            
            throw handleError(error)
        }
    }
    
    // MARK: - Private Methods
    private func validateUserId(_ id: String) throws {
        guard !id.isEmpty else {
            throw GetUserUseCaseError.invalidUserId("User ID cannot be empty")
        }
        
        guard id.count >= 3 else {
            throw GetUserUseCaseError.invalidUserId("User ID must be at least 3 characters")
        }
        
        guard id.count <= 50 else {
            throw GetUserUseCaseError.invalidUserId("User ID must be at most 50 characters")
        }
    }
    
    private func validateOptions(_ options: GetUserOptions) throws {
        guard options.cacheExpiration > 0 else {
            throw GetUserUseCaseError.invalidOptions("Cache expiration must be positive")
        }
        
        guard options.cacheExpiration <= 3600 else {
            throw GetUserUseCaseError.invalidOptions("Cache expiration cannot exceed 1 hour")
        }
    }
    
    private func createMetadata(for user: User, options: GetUserOptions) -> UserMetadata {
        return UserMetadata(
            retrievedAt: Date(),
            userId: user.id,
            includeInactive: options.includeInactive,
            includePermissions: options.includePermissions,
            includeActivity: options.includeActivity,
            cacheUsed: options.useCache,
            cacheExpiration: options.cacheExpiration
        )
    }
    
    private func handleError(_ error: Error) -> Error {
        if let repositoryError = error as? UserRepositoryError {
            switch repositoryError {
            case .userNotFound:
                return GetUserUseCaseError.userNotFound
            case .networkError(let underlyingError):
                return GetUserUseCaseError.networkError(underlyingError)
            case .databaseError(let underlyingError):
                return GetUserUseCaseError.databaseError(underlyingError)
            case .validationError(let message):
                return GetUserUseCaseError.validationError(message)
            case .permissionDenied:
                return GetUserUseCaseError.permissionDenied
            case .rateLimitExceeded:
                return GetUserUseCaseError.rateLimitExceeded
            case .serverError(let message):
                return GetUserUseCaseError.serverError(message)
            default:
                return GetUserUseCaseError.unknown(error)
            }
        }
        
        return GetUserUseCaseError.unknown(error)
    }
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

// MARK: - User Validator Protocol
protocol UserValidatorProtocol {
    func validateUserId(_ id: String) throws
    func validateUser(_ user: User) async -> ValidationResult
}

// MARK: - User Validator Implementation
struct UserValidator: UserValidatorProtocol {
    
    func validateUserId(_ id: String) throws {
        guard !id.isEmpty else {
            throw ValidationError.invalidUserId("User ID cannot be empty")
        }
        
        guard id.count >= 3 else {
            throw ValidationError.invalidUserId("User ID must be at least 3 characters")
        }
        
        guard id.count <= 50 else {
            throw ValidationError.invalidUserId("User ID must be at most 50 characters")
        }
        
        guard id.range(of: "^[a-zA-Z0-9_-]+$", options: .regularExpression) != nil else {
            throw ValidationError.invalidUserId("User ID contains invalid characters")
        }
    }
    
    func validateUser(_ user: User) async -> ValidationResult {
        var errors: [String] = []
        var warnings: [String] = []
        
        if !user.isValid {
            errors.append("User validation failed: \(user.validationErrors.joined(separator: ", "))")
        }
        
        if user.isInactive {
            warnings.append("User is inactive. Consider re-activating if necessary.")
        }
        
        return ValidationResult(isValid: errors.isEmpty, errorMessages: errors, warnings: warnings)
    }
}

// MARK: - Validation Result
struct ValidationResult {
    let isValid: Bool
    let errorMessages: [String]
    let warnings: [String]
}

// MARK: - Validation Error
enum ValidationError: LocalizedError {
    case invalidUserId(String)
    case invalidUser(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidUserId(let message):
            return "Invalid user ID: \(message)"
        case .invalidUser(let message):
            return "Invalid user: \(message)"
        }
    }
}

// MARK: - Cache Manager Protocol
protocol CacheManagerProtocol {
    func get<T: Codable>(forKey key: String) async throws -> T?
    func set<T: Codable>(_ value: T, forKey key: String, expiration: TimeInterval) async throws
    func remove(forKey key: String) async throws
    func clear() async throws
}

// MARK: - Analytics Service Protocol
protocol AnalyticsServiceProtocol {
    func trackEvent(_ event: String, parameters: [String: Any]?)
    func trackScreen(_ screen: String)
    func trackError(_ error: Error)
}

// MARK: - Logger Protocol
protocol LoggerProtocol {
    func info(_ message: String, category: String, file: String, function: String, line: Int)
    func error(_ message: String, category: String, file: String, function: String, line: Int)
}

