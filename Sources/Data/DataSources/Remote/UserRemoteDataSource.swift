import Foundation

/**
 * User Remote Data Source - Data Layer
 * 
 * Remote data source implementation for user data access via API.
 * Handles network communication and data transformation.
 * 
 * - Author: iOS Clean Architecture Team
 * - Version: 2.0.0
 * - Date: 2024-01-15
 */

// MARK: - User Remote Data Source Implementation
class UserRemoteDataSource: UserRemoteDataSourceProtocol {
    
    // MARK: - Dependencies
    private let apiService: APIServiceProtocol
    private let logger: LoggerProtocol
    
    // MARK: - Initialization
    init(
        apiService: APIServiceProtocol = APIService(baseURL: "https://api.example.com"),
        logger: LoggerProtocol = Logger()
    ) {
        self.apiService = apiService
        self.logger = logger
    }
    
    // MARK: - User Operations
    func getUser(id: String) async throws -> User {
        let endpoint = APIEndpoint(
            path: "/users/\(id)",
            method: .get,
            isCacheable: true,
            cacheKey: "user_\(id)"
        )
        
        do {
            let user: User = try await apiService.request(endpoint)
            logger.log("User retrieved from remote", level: .info, category: "UserRemoteDataSource", file: #file, function: #function, line: #line)
            return user
        } catch {
            logger.log("Failed to get user from remote: \(error.localizedDescription)", level: .error, category: "UserRemoteDataSource", file: #file, function: #function, line: #line)
            throw handleError(error)
        }
    }
    
    func getUsers(limit: Int, offset: Int, isActive: Bool?) async throws -> [User] {
        var path = "/users?limit=\(limit)&offset=\(offset)"
        if let isActive = isActive {
            path += "&isActive=\(isActive)"
        }
        
        let endpoint = APIEndpoint(
            path: path,
            method: .get,
            isCacheable: true,
            cacheKey: "users_\(limit)_\(offset)_\(isActive?.description ?? "nil")"
        )
        
        do {
            let users: [User] = try await apiService.request(endpoint)
            logger.log("Users retrieved from remote", level: .info, category: "UserRemoteDataSource", file: #file, function: #function, line: #line)
            return users
        } catch {
            logger.log("Failed to get users from remote: \(error.localizedDescription)", level: .error, category: "UserRemoteDataSource", file: #file, function: #function, line: #line)
            throw handleError(error)
        }
    }
    
    func createUser(_ user: User) async throws -> User {
        let endpoint = APIEndpoint(
            path: "/users",
            method: .post,
            isCacheable: false
        )
        
        do {
            let createdUser: User = try await apiService.request(endpoint, body: user)
            logger.log("User created remotely", level: .info, category: "UserRemoteDataSource", file: #file, function: #function, line: #line)
            return createdUser
        } catch {
            logger.log("Failed to create user remotely: \(error.localizedDescription)", level: .error, category: "UserRemoteDataSource", file: #file, function: #function, line: #line)
            throw handleError(error)
        }
    }
    
    func updateUser(_ user: User) async throws -> User {
        let endpoint = APIEndpoint(
            path: "/users/\(user.id)",
            method: .put,
            isCacheable: false
        )
        
        do {
            let updatedUser: User = try await apiService.request(endpoint, body: user)
            logger.log("User updated remotely", level: .info, category: "UserRemoteDataSource", file: #file, function: #function, line: #line)
            return updatedUser
        } catch {
            logger.log("Failed to update user remotely: \(error.localizedDescription)", level: .error, category: "UserRemoteDataSource", file: #file, function: #function, line: #line)
            throw handleError(error)
        }
    }
    
    func deleteUser(id: String) async throws {
        let endpoint = APIEndpoint(
            path: "/users/\(id)",
            method: .delete,
            isCacheable: false
        )
        
        do {
            let _: EmptyResponse = try await apiService.request(endpoint)
            logger.log("User deleted remotely", level: .info, category: "UserRemoteDataSource", file: #file, function: #function, line: #line)
        } catch {
            logger.log("Failed to delete user remotely: \(error.localizedDescription)", level: .error, category: "UserRemoteDataSource", file: #file, function: #function, line: #line)
            throw handleError(error)
        }
    }
    
    func searchUsers(query: String) async throws -> [User] {
        let endpoint = APIEndpoint(
            path: "/users/search?q=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query)",
            method: .get,
            isCacheable: true,
            cacheKey: "search_users_\(query)"
        )
        
        do {
            let users: [User] = try await apiService.request(endpoint)
            logger.log("Users searched remotely", level: .info, category: "UserRemoteDataSource", file: #file, function: #function, line: #line)
            return users
        } catch {
            logger.log("Failed to search users remotely: \(error.localizedDescription)", level: .error, category: "UserRemoteDataSource", file: #file, function: #function, line: #line)
            throw handleError(error)
        }
    }
    
    func getUsersByRole(_ role: UserRole) async throws -> [User] {
        let endpoint = APIEndpoint(
            path: "/users/role/\(role.rawValue)",
            method: .get,
            isCacheable: true,
            cacheKey: "users_by_role_\(role.rawValue)"
        )
        
        do {
            let users: [User] = try await apiService.request(endpoint)
            logger.log("Users by role retrieved remotely", level: .info, category: "UserRemoteDataSource", file: #file, function: #function, line: #line)
            return users
        } catch {
            logger.log("Failed to get users by role remotely: \(error.localizedDescription)", level: .error, category: "UserRemoteDataSource", file: #file, function: #function, line: #line)
            throw handleError(error)
        }
    }
    
    // MARK: - Private Methods
    private func handleError(_ error: Error) -> Error {
        if let apiError = error as? APIError {
            switch apiError {
            case .networkError(let underlyingError):
                return UserRepositoryError.networkError(underlyingError)
            case .validationFailed(let message):
                return UserRepositoryError.validationError(message)
            case .serializationFailed(let message):
                return UserRepositoryError.databaseError(NSError(domain: "SerializationError", code: 0, userInfo: [NSLocalizedDescriptionKey: message]))
            case .decodingError(let underlyingError):
                return UserRepositoryError.databaseError(underlyingError)
            case .unknown(let underlyingError):
                return UserRepositoryError.unknown(underlyingError)
            default:
                return UserRepositoryError.serverError(apiError.localizedDescription)
            }
        }
        
        return UserRepositoryError.unknown(error)
    }
}

// MARK: - Empty Response
struct EmptyResponse: Codable {}

// MARK: - API Service Protocol
protocol APIServiceProtocol {
    func request<T: Codable>(_ endpoint: APIEndpoint) async throws -> T
    func request<T: Codable, U: Codable>(_ endpoint: APIEndpoint, body: U) async throws -> T
}

// MARK: - API Endpoint
struct APIEndpoint {
    let path: String
    let method: HTTPMethod
    let headers: [String: String]
    let isCacheable: Bool
    let cacheKey: String
    
    init(
        path: String,
        method: HTTPMethod = .get,
        headers: [String: String] = [:],
        isCacheable: Bool = false,
        cacheKey: String? = nil
    ) {
        self.path = path
        self.method = method
        self.headers = headers
        self.isCacheable = isCacheable
        self.cacheKey = cacheKey ?? "\(method.rawValue)_\(path)"
    }
}

// MARK: - HTTP Method
enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
}

// MARK: - API Error
enum APIError: LocalizedError {
    case invalidURL
    case networkError(Error)
    case validationFailed(String)
    case serializationFailed(String)
    case decodingError(Error)
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .validationFailed(let message):
            return "Validation failed: \(message)"
        case .serializationFailed(let message):
            return "Serialization failed: \(message)"
        case .decodingError(let error):
            return "Decoding error: \(error.localizedDescription)"
        case .unknown(let error):
            return "Unknown error: \(error.localizedDescription)"
        }
    }
} 