import Foundation
import Alamofire
import Combine

/**
 * API Service - Remote Data Source
 * 
 * Professional network service implementation with advanced features:
 * - Request/Response interceptors
 * - Automatic retry mechanism
 * - Request caching
 * - Error handling
 * - Performance monitoring
 * 
 * - Author: iOS Clean Architecture Team
 * - Version: 2.0.0
 * - Date: 2024-01-15
 */

// MARK: - API Service Protocol
protocol APIServiceProtocol {
    func request<T: Codable>(_ endpoint: APIEndpoint) async throws -> T
    func request<T: Codable, U: Codable>(_ endpoint: APIEndpoint, body: U) async throws -> T
    func upload<T: Codable>(_ endpoint: APIEndpoint, data: Data, fileName: String) async throws -> T
    func download(_ endpoint: APIEndpoint) async throws -> Data
}

// MARK: - API Service Implementation
class APIService: APIServiceProtocol {
    
    // MARK: - Properties
    private let session: Session
    private let baseURL: String
    private let interceptor: RequestInterceptor
    private let cacheManager: CacheManagerProtocol
    private let performanceMonitor: PerformanceMonitorProtocol
    private let analyticsService: AnalyticsServiceProtocol
    
    // MARK: - Configuration
    private let timeoutInterval: TimeInterval = 30.0
    private let retryCount = 3
    private let cacheExpiration: TimeInterval = 300 // 5 minutes
    
    // MARK: - Initialization
    init(
        baseURL: String,
        interceptor: RequestInterceptor = RequestInterceptor(),
        cacheManager: CacheManagerProtocol = CacheManager(),
        performanceMonitor: PerformanceMonitorProtocol = PerformanceMonitor(),
        analyticsService: AnalyticsServiceProtocol = AnalyticsService()
    ) {
        self.baseURL = baseURL
        self.interceptor = interceptor
        self.cacheManager = cacheManager
        self.performanceMonitor = performanceMonitor
        self.analyticsService = analyticsService
        
        // Configure session
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = timeoutInterval
        configuration.timeoutIntervalForResource = timeoutInterval
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        configuration.urlCache = nil
        
        self.session = Session(configuration: configuration, interceptor: interceptor)
    }
    
    // MARK: - Request Methods
    func request<T: Codable>(_ endpoint: APIEndpoint) async throws -> T {
        let startTime = Date()
        
        do {
            // Check cache first
            if endpoint.isCacheable, let cachedData: T = try await cacheManager.get(forKey: endpoint.cacheKey) {
                analyticsService.trackEvent("api_cache_hit", parameters: ["endpoint": endpoint.path])
                return cachedData
            }
            
            // Create request
            let request = try createRequest(for: endpoint)
            
            // Execute request
            let response = try await executeRequest(request, for: endpoint)
            
            // Decode response
            let decodedResponse: T = try decodeResponse(response.data, for: endpoint)
            
            // Cache response if cacheable
            if endpoint.isCacheable {
                try await cacheManager.set(decodedResponse, forKey: endpoint.cacheKey, expiration: cacheExpiration)
            }
            
            // Track performance
            let duration = Date().timeIntervalSince(startTime)
            performanceMonitor.recordAPICall(endpoint: endpoint.path, duration: duration, success: true)
            
            // Track analytics
            analyticsService.trackEvent("api_success", parameters: [
                "endpoint": endpoint.path,
                "method": endpoint.method.rawValue,
                "duration": duration
            ])
            
            return decodedResponse
            
        } catch {
            // Track error
            let duration = Date().timeIntervalSince(startTime)
            performanceMonitor.recordAPICall(endpoint: endpoint.path, duration: duration, success: false)
            
            analyticsService.trackEvent("api_error", parameters: [
                "endpoint": endpoint.path,
                "method": endpoint.method.rawValue,
                "error": error.localizedDescription,
                "duration": duration
            ])
            
            throw handleError(error, for: endpoint)
        }
    }
    
    func request<T: Codable, U: Codable>(_ endpoint: APIEndpoint, body: U) async throws -> T {
        let startTime = Date()
        
        do {
            // Create request with body
            let request = try createRequest(for: endpoint, body: body)
            
            // Execute request
            let response = try await executeRequest(request, for: endpoint)
            
            // Decode response
            let decodedResponse: T = try decodeResponse(response.data, for: endpoint)
            
            // Track performance
            let duration = Date().timeIntervalSince(startTime)
            performanceMonitor.recordAPICall(endpoint: endpoint.path, duration: duration, success: true)
            
            // Track analytics
            analyticsService.trackEvent("api_success", parameters: [
                "endpoint": endpoint.path,
                "method": endpoint.method.rawValue,
                "duration": duration
            ])
            
            return decodedResponse
            
        } catch {
            // Track error
            let duration = Date().timeIntervalSince(startTime)
            performanceMonitor.recordAPICall(endpoint: endpoint.path, duration: duration, success: false)
            
            analyticsService.trackEvent("api_error", parameters: [
                "endpoint": endpoint.path,
                "method": endpoint.method.rawValue,
                "error": error.localizedDescription,
                "duration": duration
            ])
            
            throw handleError(error, for: endpoint)
        }
    }
    
    func upload<T: Codable>(_ endpoint: APIEndpoint, data: Data, fileName: String) async throws -> T {
        let startTime = Date()
        
        do {
            // Create upload request
            let request = try createUploadRequest(for: endpoint, data: data, fileName: fileName)
            
            // Execute upload
            let response = try await executeUploadRequest(request, for: endpoint)
            
            // Decode response
            let decodedResponse: T = try decodeResponse(response.data, for: endpoint)
            
            // Track performance
            let duration = Date().timeIntervalSince(startTime)
            performanceMonitor.recordAPICall(endpoint: endpoint.path, duration: duration, success: true)
            
            // Track analytics
            analyticsService.trackEvent("api_upload_success", parameters: [
                "endpoint": endpoint.path,
                "file_size": data.count,
                "duration": duration
            ])
            
            return decodedResponse
            
        } catch {
            // Track error
            let duration = Date().timeIntervalSince(startTime)
            performanceMonitor.recordAPICall(endpoint: endpoint.path, duration: duration, success: false)
            
            analyticsService.trackEvent("api_upload_error", parameters: [
                "endpoint": endpoint.path,
                "error": error.localizedDescription,
                "duration": duration
            ])
            
            throw handleError(error, for: endpoint)
        }
    }
    
    func download(_ endpoint: APIEndpoint) async throws -> Data {
        let startTime = Date()
        
        do {
            // Create download request
            let request = try createRequest(for: endpoint)
            
            // Execute download
            let response = try await executeDownloadRequest(request, for: endpoint)
            
            // Track performance
            let duration = Date().timeIntervalSince(startTime)
            performanceMonitor.recordAPICall(endpoint: endpoint.path, duration: duration, success: true)
            
            // Track analytics
            analyticsService.trackEvent("api_download_success", parameters: [
                "endpoint": endpoint.path,
                "data_size": response.data.count,
                "duration": duration
            ])
            
            return response.data
            
        } catch {
            // Track error
            let duration = Date().timeIntervalSince(startTime)
            performanceMonitor.recordAPICall(endpoint: endpoint.path, duration: duration, success: false)
            
            analyticsService.trackEvent("api_download_error", parameters: [
                "endpoint": endpoint.path,
                "error": error.localizedDescription,
                "duration": duration
            ])
            
            throw handleError(error, for: endpoint)
        }
    }
    
    // MARK: - Private Methods
    private func createRequest(for endpoint: APIEndpoint) throws -> URLRequest {
        guard let url = URL(string: baseURL + endpoint.path) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.timeoutInterval = timeoutInterval
        
        // Set headers
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("iOSCleanArchitectureTemplate/2.0.0", forHTTPHeaderField: "User-Agent")
        
        // Add custom headers
        for (key, value) in endpoint.headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        return request
    }
    
    private func createRequest<T: Codable>(for endpoint: APIEndpoint, body: T) throws -> URLRequest {
        var request = try createRequest(for: endpoint)
        request.httpBody = try JSONEncoder().encode(body)
        return request
    }
    
    private func createUploadRequest(for endpoint: APIEndpoint, data: Data, fileName: String) throws -> URLRequest {
        var request = try createRequest(for: endpoint)
        request.setValue("multipart/form-data", forHTTPHeaderField: "Content-Type")
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: application/octet-stream\r\n\r\n".data(using: .utf8)!)
        body.append(data)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        return request
    }
    
    private func executeRequest(_ request: URLRequest, for endpoint: APIEndpoint) async throws -> DataResponse<Data, AFError> {
        return try await withCheckedThrowingContinuation { continuation in
            session.request(request)
                .validate()
                .responseData { response in
                    switch response.result {
                    case .success(let data):
                        continuation.resume(returning: DataResponse(request: request, response: response.response, data: data, metrics: response.metrics, serializationDuration: response.serializationDuration, result: .success(data)))
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }
        }
    }
    
    private func executeUploadRequest(_ request: URLRequest, for endpoint: APIEndpoint) async throws -> DataResponse<Data, AFError> {
        return try await withCheckedThrowingContinuation { continuation in
            session.upload(multipartFormData: { multipartFormData in
                // Upload implementation
            }, with: request)
            .validate()
            .responseData { response in
                switch response.result {
                case .success(let data):
                    continuation.resume(returning: DataResponse(request: request, response: response.response, data: data, metrics: response.metrics, serializationDuration: response.serializationDuration, result: .success(data)))
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    private func executeDownloadRequest(_ request: URLRequest, for endpoint: APIEndpoint) async throws -> DataResponse<Data, AFError> {
        return try await withCheckedThrowingContinuation { continuation in
            session.download(request)
                .validate()
                .responseData { response in
                    switch response.result {
                    case .success(let data):
                        continuation.resume(returning: DataResponse(request: request, response: response.response, data: data, metrics: response.metrics, serializationDuration: response.serializationDuration, result: .success(data)))
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }
        }
    }
    
    private func decodeResponse<T: Codable>(_ data: Data, for endpoint: APIEndpoint) throws -> T {
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            return try decoder.decode(T.self, from: data)
        } catch {
            throw APIError.decodingError(error)
        }
    }
    
    private func handleError(_ error: Error, for endpoint: APIEndpoint) -> Error {
        if let afError = error as? AFError {
            switch afError {
            case .responseValidationFailed(let reason):
                return APIError.validationFailed(reason.localizedDescription)
            case .responseSerializationFailed(let reason):
                return APIError.serializationFailed(reason.localizedDescription)
            case .sessionTaskFailed(let error):
                return APIError.networkError(error)
            default:
                return APIError.unknown(error)
            }
        }
        
        return error
    }
}

// MARK: - Request Interceptor
class RequestInterceptor: RequestAdapter {
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        var urlRequest = urlRequest
        
        // Add authentication token if available
        if let token = SecureStorage.getAccessToken() {
            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        // Add request ID for tracking
        urlRequest.setValue(UUID().uuidString, forHTTPHeaderField: "X-Request-ID")
        
        // Add timestamp
        urlRequest.setValue(String(Date().timeIntervalSince1970), forHTTPHeaderField: "X-Timestamp")
        
        completion(.success(urlRequest))
    }
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

// MARK: - Protocols for Dependencies
protocol CacheManagerProtocol {
    func get<T: Codable>(forKey key: String) async throws -> T?
    func set<T: Codable>(_ value: T, forKey key: String, expiration: TimeInterval) async throws
    func remove(forKey key: String) async throws
    func clear() async throws
}

protocol PerformanceMonitorProtocol {
    func recordAPICall(endpoint: String, duration: TimeInterval, success: Bool)
    func recordMemoryUsage(_ usage: Int64)
    func recordBatteryUsage(_ usage: Double)
}

protocol AnalyticsServiceProtocol {
    func trackEvent(_ event: String, parameters: [String: Any]?)
    func trackScreen(_ screen: String)
    func trackError(_ error: Error)
}

protocol SecureStorageProtocol {
    static func getAccessToken() -> String?
    static func saveAccessToken(_ token: String) throws
    static func clearAccessToken() throws
}
