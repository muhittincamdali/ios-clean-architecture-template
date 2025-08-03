import Foundation

/**
 * API Service Protocol - Infrastructure Layer
 * 
 * Abstract interface for API operations.
 * Defines the contract for API service implementations.
 * 
 * - Author: iOS Clean Architecture Team
 * - Version: 2.0.0
 * - Date: 2024-01-15
 */

// MARK: - HTTP Method
enum HTTPMethod: String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case DELETE = "DELETE"
    case PATCH = "PATCH"
    case HEAD = "HEAD"
    case OPTIONS = "OPTIONS"
}

// MARK: - API Endpoint
struct APIEndpoint {
    let path: String
    let method: HTTPMethod
    let parameters: [String: Any]?
    let headers: [String: String]?
    let body: Data?
    let timeout: TimeInterval
    let retryCount: Int
    
    init(
        path: String,
        method: HTTPMethod = .GET,
        parameters: [String: Any]? = nil,
        headers: [String: String]? = nil,
        body: Data? = nil,
        timeout: TimeInterval = 30.0,
        retryCount: Int = 3
    ) {
        self.path = path
        self.method = method
        self.parameters = parameters
        self.headers = headers
        self.body = body
        self.timeout = timeout
        self.retryCount = retryCount
    }
}

// MARK: - API Response
struct APIResponse<T: Codable> {
    let data: T?
    let statusCode: Int
    let headers: [String: String]
    let timestamp: Date
    let duration: TimeInterval
    let url: URL?
    
    init(
        data: T?,
        statusCode: Int,
        headers: [String: String] = [:],
        timestamp: Date = Date(),
        duration: TimeInterval = 0,
        url: URL? = nil
    ) {
        self.data = data
        self.statusCode = statusCode
        self.headers = headers
        self.timestamp = timestamp
        self.duration = duration
        self.url = url
    }
    
    var isSuccess: Bool {
        return statusCode >= 200 && statusCode < 300
    }
    
    var isClientError: Bool {
        return statusCode >= 400 && statusCode < 500
    }
    
    var isServerError: Bool {
        return statusCode >= 500 && statusCode < 600
    }
}

// MARK: - API Service Protocol
protocol APIServiceProtocol {
    func request<T: Codable>(_ endpoint: APIEndpoint, responseType: T.Type) async throws -> APIResponse<T>
    func get<T: Codable>(_ path: String, parameters: [String: Any]?, responseType: T.Type) async throws -> APIResponse<T>
    func post<T: Codable>(_ path: String, body: Data?, responseType: T.Type) async throws -> APIResponse<T>
    func put<T: Codable>(_ path: String, body: Data?, responseType: T.Type) async throws -> APIResponse<T>
    func delete<T: Codable>(_ path: String, responseType: T.Type) async throws -> APIResponse<T>
    func patch<T: Codable>(_ path: String, body: Data?, responseType: T.Type) async throws -> APIResponse<T>
    func setBaseURL(_ url: String)
    func setDefaultHeaders(_ headers: [String: String])
    func setAuthentication(token: String)
    func clearAuthentication()
    func enableLogging(_ enabled: Bool)
    func enableCaching(_ enabled: Bool)
    func setCachePolicy(_ policy: CachePolicy)
}

// MARK: - API Error
enum APIError: LocalizedError {
    case invalidURL(String)
    case invalidRequest(String)
    case networkError(String)
    case serverError(String)
    case clientError(String)
    case authenticationError(String)
    case authorizationError(String)
    case rateLimitExceeded(String)
    case timeout(String)
    case invalidResponse(String)
    case decodingError(String)
    case encodingError(String)
    case unknown(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL(let message):
            return "Invalid URL: \(message)"
        case .invalidRequest(let message):
            return "Invalid request: \(message)"
        case .networkError(let message):
            return "Network error: \(message)"
        case .serverError(let message):
            return "Server error: \(message)"
        case .clientError(let message):
            return "Client error: \(message)"
        case .authenticationError(let message):
            return "Authentication error: \(message)"
        case .authorizationError(let message):
            return "Authorization error: \(message)"
        case .rateLimitExceeded(let message):
            return "Rate limit exceeded: \(message)"
        case .timeout(let message):
            return "Request timeout: \(message)"
        case .invalidResponse(let message):
            return "Invalid response: \(message)"
        case .decodingError(let message):
            return "Response decoding error: \(message)"
        case .encodingError(let message):
            return "Request encoding error: \(message)"
        case .unknown(let message):
            return "Unknown API error: \(message)"
        }
    }
    
    var errorCode: Int {
        switch self {
        case .invalidURL:
            return 11001
        case .invalidRequest:
            return 11002
        case .networkError:
            return 11003
        case .serverError:
            return 11004
        case .clientError:
            return 11005
        case .authenticationError:
            return 11006
        case .authorizationError:
            return 11007
        case .rateLimitExceeded:
            return 11008
        case .timeout:
            return 11009
        case .invalidResponse:
            return 11010
        case .decodingError:
            return 11011
        case .encodingError:
            return 11012
        case .unknown:
            return 11099
        }
    }
}

// MARK: - API Configuration
struct APIConfiguration {
    let baseURL: String
    let defaultHeaders: [String: String]
    let timeout: TimeInterval
    let retryCount: Int
    let retryDelay: TimeInterval
    let enableLogging: Bool
    let enableCaching: Bool
    let cachePolicy: CachePolicy
    let enableCertificatePinning: Bool
    let enableSSL: Bool
    let maxConcurrentRequests: Int
    
    init(
        baseURL: String = "",
        defaultHeaders: [String: String] = [:],
        timeout: TimeInterval = 30.0,
        retryCount: Int = 3,
        retryDelay: TimeInterval = 1.0,
        enableLogging: Bool = true,
        enableCaching: Bool = true,
        cachePolicy: CachePolicy = .memoryAndDisk,
        enableCertificatePinning: Bool = false,
        enableSSL: Bool = true,
        maxConcurrentRequests: Int = 10
    ) {
        self.baseURL = baseURL
        self.defaultHeaders = defaultHeaders
        self.timeout = timeout
        self.retryCount = retryCount
        self.retryDelay = retryDelay
        self.enableLogging = enableLogging
        self.enableCaching = enableCaching
        self.cachePolicy = cachePolicy
        self.enableCertificatePinning = enableCertificatePinning
        self.enableSSL = enableSSL
        self.maxConcurrentRequests = maxConcurrentRequests
    }
}

// MARK: - API Statistics
struct APIStatistics {
    let totalRequests: Int
    let successfulRequests: Int
    let failedRequests: Int
    let averageResponseTime: TimeInterval
    let totalDataTransferred: Int64
    let cacheHitRate: Double
    let lastRequestTime: Date?
    let timestamp: Date
    
    init(
        totalRequests: Int = 0,
        successfulRequests: Int = 0,
        failedRequests: Int = 0,
        averageResponseTime: TimeInterval = 0,
        totalDataTransferred: Int64 = 0,
        cacheHitRate: Double = 0,
        lastRequestTime: Date? = nil
    ) {
        self.totalRequests = totalRequests
        self.successfulRequests = successfulRequests
        self.failedRequests = failedRequests
        self.averageResponseTime = averageResponseTime
        self.totalDataTransferred = totalDataTransferred
        self.cacheHitRate = cacheHitRate
        self.lastRequestTime = lastRequestTime
        self.timestamp = Date()
    }
}

// MARK: - API Service Extensions
extension APIServiceProtocol {
    
    // MARK: - Convenience Methods
    func request<T: Codable>(_ path: String, method: HTTPMethod = .GET, responseType: T.Type) async throws -> APIResponse<T> {
        let endpoint = APIEndpoint(path: path, method: method)
        return try await request(endpoint, responseType: responseType)
    }
    
    func request<T: Codable>(_ path: String, method: HTTPMethod = .GET, parameters: [String: Any]?, responseType: T.Type) async throws -> APIResponse<T> {
        let endpoint = APIEndpoint(path: path, method: method, parameters: parameters)
        return try await request(endpoint, responseType: responseType)
    }
    
    func request<T: Codable>(_ path: String, method: HTTPMethod = .POST, body: Data?, responseType: T.Type) async throws -> APIResponse<T> {
        let endpoint = APIEndpoint(path: path, method: method, body: body)
        return try await request(endpoint, responseType: responseType)
    }
    
    func request<T: Codable>(_ path: String, method: HTTPMethod = .POST, body: [String: Any], responseType: T.Type) async throws -> APIResponse<T> {
        let jsonData = try JSONSerialization.data(withJSONObject: body)
        let endpoint = APIEndpoint(path: path, method: method, body: jsonData)
        return try await request(endpoint, responseType: responseType)
    }
    
    func request<T: Codable>(_ path: String, method: HTTPMethod = .POST, body: Codable, responseType: T.Type) async throws -> APIResponse<T> {
        let jsonData = try JSONEncoder().encode(body)
        let endpoint = APIEndpoint(path: path, method: method, body: jsonData)
        return try await request(endpoint, responseType: responseType)
    }
    
    func getStatistics() -> APIStatistics {
        // This would typically return actual statistics
        return APIStatistics()
    }
    
    func clearCache() {
        // This would need to be implemented based on the specific API service implementation
    }
    
    func cancelAllRequests() {
        // This would need to be implemented based on the specific API service implementation
    }
    
    func isReachable() async -> Bool {
        // This would need to be implemented based on the specific API service implementation
        return true
    }
}

// MARK: - API Categories
extension APIServiceProtocol {
    
    struct Category {
        static let api = "API"
        static let network = "Network"
        static let http = "HTTP"
        static let rest = "REST"
    }
} 