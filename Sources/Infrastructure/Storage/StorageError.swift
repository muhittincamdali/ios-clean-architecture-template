import Foundation

/**
 * Storage Error - Infrastructure Layer
 * 
 * Professional storage error types and handling.
 * Provides comprehensive error types for all storage operations.
 * 
 * - Author: iOS Clean Architecture Team
 * - Version: 2.0.0
 * - Date: 2024-01-15
 */

// MARK: - Storage Error
enum StorageError: LocalizedError {
    case saveFailed(String)
    case loadFailed(String)
    case deleteFailed(String)
    case clearFailed(String)
    case notFound(String)
    case invalidData(String)
    case encodingFailed(String)
    case decodingFailed(String)
    case capacityExceeded(String)
    case permissionDenied(String)
    case networkError(String)
    case timeout(String)
    case corrupted(String)
    case unsupported(String)
    case unknown(String)
    
    var errorDescription: String? {
        switch self {
        case .saveFailed(let message):
            return "Failed to save data: \(message)"
        case .loadFailed(let message):
            return "Failed to load data: \(message)"
        case .deleteFailed(let message):
            return "Failed to delete data: \(message)"
        case .clearFailed(let message):
            return "Failed to clear storage: \(message)"
        case .notFound(let message):
            return "Data not found: \(message)"
        case .invalidData(let message):
            return "Invalid data: \(message)"
        case .encodingFailed(let message):
            return "Failed to encode data: \(message)"
        case .decodingFailed(let message):
            return "Failed to decode data: \(message)"
        case .capacityExceeded(let message):
            return "Storage capacity exceeded: \(message)"
        case .permissionDenied(let message):
            return "Permission denied: \(message)"
        case .networkError(let message):
            return "Network error: \(message)"
        case .timeout(let message):
            return "Operation timed out: \(message)"
        case .corrupted(let message):
            return "Data corrupted: \(message)"
        case .unsupported(let message):
            return "Unsupported operation: \(message)"
        case .unknown(let message):
            return "Unknown error: \(message)"
        }
    }
    
    var failureReason: String? {
        switch self {
        case .saveFailed:
            return "The data could not be saved to storage"
        case .loadFailed:
            return "The data could not be loaded from storage"
        case .deleteFailed:
            return "The data could not be deleted from storage"
        case .clearFailed:
            return "The storage could not be cleared"
        case .notFound:
            return "The requested data was not found in storage"
        case .invalidData:
            return "The data format is invalid or corrupted"
        case .encodingFailed:
            return "The data could not be encoded for storage"
        case .decodingFailed:
            return "The data could not be decoded from storage"
        case .capacityExceeded:
            return "The storage capacity has been exceeded"
        case .permissionDenied:
            return "The operation was denied due to insufficient permissions"
        case .networkError:
            return "A network error occurred during the operation"
        case .timeout:
            return "The operation timed out"
        case .corrupted:
            return "The stored data is corrupted and cannot be read"
        case .unsupported:
            return "The operation is not supported by this storage type"
        case .unknown:
            return "An unknown error occurred"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .saveFailed:
            return "Check available storage space and try again"
        case .loadFailed:
            return "Verify the data exists and try again"
        case .deleteFailed:
            return "Check file permissions and try again"
        case .clearFailed:
            return "Check storage permissions and try again"
        case .notFound:
            return "Verify the data key and try again"
        case .invalidData:
            return "Check data format and try again"
        case .encodingFailed:
            return "Verify data structure and try again"
        case .decodingFailed:
            return "Check data format and try again"
        case .capacityExceeded:
            return "Free up storage space and try again"
        case .permissionDenied:
            return "Check app permissions and try again"
        case .networkError:
            return "Check network connection and try again"
        case .timeout:
            return "Check network speed and try again"
        case .corrupted:
            return "Clear corrupted data and try again"
        case .unsupported:
            return "Use a supported storage method"
        case .unknown:
            return "Try again later or contact support"
        }
    }
    
    var errorCode: Int {
        switch self {
        case .saveFailed:
            return 1001
        case .loadFailed:
            return 1002
        case .deleteFailed:
            return 1003
        case .clearFailed:
            return 1004
        case .notFound:
            return 1005
        case .invalidData:
            return 1006
        case .encodingFailed:
            return 1007
        case .decodingFailed:
            return 1008
        case .capacityExceeded:
            return 1009
        case .permissionDenied:
            return 1010
        case .networkError:
            return 1011
        case .timeout:
            return 1012
        case .corrupted:
            return 1013
        case .unsupported:
            return 1014
        case .unknown:
            return 1099
        }
    }
}

// MARK: - Storage Error Extensions
extension StorageError {
    
    // MARK: - Convenience Initializers
    static func saveFailed(_ operation: String, underlying: Error? = nil) -> StorageError {
        let message = underlying?.localizedDescription ?? "Unknown error"
        return .saveFailed("\(operation): \(message)")
    }
    
    static func loadFailed(_ operation: String, underlying: Error? = nil) -> StorageError {
        let message = underlying?.localizedDescription ?? "Unknown error"
        return .loadFailed("\(operation): \(message)")
    }
    
    static func deleteFailed(_ operation: String, underlying: Error? = nil) -> StorageError {
        let message = underlying?.localizedDescription ?? "Unknown error"
        return .deleteFailed("\(operation): \(message)")
    }
    
    static func clearFailed(_ operation: String, underlying: Error? = nil) -> StorageError {
        let message = underlying?.localizedDescription ?? "Unknown error"
        return .clearFailed("\(operation): \(message)")
    }
    
    static func notFound(_ key: String) -> StorageError {
        return .notFound("Key: \(key)")
    }
    
    static func invalidData(_ type: String, details: String? = nil) -> StorageError {
        let message = details ?? "Invalid format"
        return .invalidData("\(type): \(message)")
    }
    
    static func encodingFailed(_ type: String, underlying: Error? = nil) -> StorageError {
        let message = underlying?.localizedDescription ?? "Unknown error"
        return .encodingFailed("\(type): \(message)")
    }
    
    static func decodingFailed(_ type: String, underlying: Error? = nil) -> StorageError {
        let message = underlying?.localizedDescription ?? "Unknown error"
        return .decodingFailed("\(type): \(message)")
    }
    
    static func capacityExceeded(_ current: Int64, limit: Int64) -> StorageError {
        return .capacityExceeded("Current: \(current), Limit: \(limit)")
    }
    
    static func permissionDenied(_ operation: String) -> StorageError {
        return .permissionDenied("Operation: \(operation)")
    }
    
    static func networkError(_ endpoint: String, underlying: Error? = nil) -> StorageError {
        let message = underlying?.localizedDescription ?? "Unknown error"
        return .networkError("\(endpoint): \(message)")
    }
    
    static func timeout(_ operation: String, duration: TimeInterval) -> StorageError {
        return .timeout("\(operation): \(duration)s")
    }
    
    static func corrupted(_ type: String, details: String? = nil) -> StorageError {
        let message = details ?? "Data integrity check failed"
        return .corrupted("\(type): \(message)")
    }
    
    static func unsupported(_ operation: String, storageType: String) -> StorageError {
        return .unsupported("\(operation) not supported by \(storageType)")
    }
    
    static func unknown(_ context: String, underlying: Error? = nil) -> StorageError {
        let message = underlying?.localizedDescription ?? "Unknown error"
        return .unknown("\(context): \(message)")
    }
}

// MARK: - Storage Error Categories
extension StorageError {
    
    enum Category {
        case fileSystem
        case keychain
        case userDefaults
        case coreData
        case network
        case cache
        case database
        case cloud
        case encryption
        case compression
        case serialization
        case validation
        case permission
        case capacity
        case corruption
        case timeout
        case network
        case unknown
        
        var description: String {
            switch self {
            case .fileSystem:
                return "File System"
            case .keychain:
                return "Keychain"
            case .userDefaults:
                return "User Defaults"
            case .coreData:
                return "Core Data"
            case .network:
                return "Network"
            case .cache:
                return "Cache"
            case .database:
                return "Database"
            case .cloud:
                return "Cloud"
            case .encryption:
                return "Encryption"
            case .compression:
                return "Compression"
            case .serialization:
                return "Serialization"
            case .validation:
                return "Validation"
            case .permission:
                return "Permission"
            case .capacity:
                return "Capacity"
            case .corruption:
                return "Corruption"
            case .timeout:
                return "Timeout"
            case .unknown:
                return "Unknown"
            }
        }
    }
    
    var category: Category {
        switch self {
        case .saveFailed, .loadFailed, .deleteFailed, .clearFailed:
            return .fileSystem
        case .notFound:
            return .fileSystem
        case .invalidData, .encodingFailed, .decodingFailed:
            return .serialization
        case .capacityExceeded:
            return .capacity
        case .permissionDenied:
            return .permission
        case .networkError:
            return .network
        case .timeout:
            return .timeout
        case .corrupted:
            return .corruption
        case .unsupported:
            return .unknown
        case .unknown:
            return .unknown
        }
    }
}

// MARK: - Storage Error Utilities
extension StorageError {
    
    struct Utilities {
        
        static func isRecoverable(_ error: StorageError) -> Bool {
            switch error {
            case .saveFailed, .loadFailed, .deleteFailed, .clearFailed:
                return true
            case .notFound:
                return false
            case .invalidData, .encodingFailed, .decodingFailed:
                return true
            case .capacityExceeded:
                return true
            case .permissionDenied:
                return true
            case .networkError:
                return true
            case .timeout:
                return true
            case .corrupted:
                return false
            case .unsupported:
                return false
            case .unknown:
                return true
            }
        }
        
        static func shouldRetry(_ error: StorageError) -> Bool {
            switch error {
            case .saveFailed, .loadFailed, .deleteFailed, .clearFailed:
                return true
            case .notFound:
                return false
            case .invalidData, .encodingFailed, .decodingFailed:
                return false
            case .capacityExceeded:
                return false
            case .permissionDenied:
                return false
            case .networkError:
                return true
            case .timeout:
                return true
            case .corrupted:
                return false
            case .unsupported:
                return false
            case .unknown:
                return true
            }
        }
        
        static func getRetryDelay(_ error: StorageError, attempt: Int) -> TimeInterval {
            let baseDelay: TimeInterval = 1.0
            let maxDelay: TimeInterval = 30.0
            let exponentialDelay = baseDelay * pow(2.0, Double(attempt - 1))
            return min(exponentialDelay, maxDelay)
        }
        
        static func getMaxRetryAttempts(_ error: StorageError) -> Int {
            switch error {
            case .saveFailed, .loadFailed, .deleteFailed, .clearFailed:
                return 3
            case .networkError, .timeout:
                return 5
            case .unknown:
                return 2
            default:
                return 0
            }
        }
        
        static func shouldLog(_ error: StorageError) -> Bool {
            switch error {
            case .saveFailed, .loadFailed, .deleteFailed, .clearFailed:
                return true
            case .notFound:
                return false
            case .invalidData, .encodingFailed, .decodingFailed:
                return true
            case .capacityExceeded:
                return true
            case .permissionDenied:
                return true
            case .networkError:
                return true
            case .timeout:
                return true
            case .corrupted:
                return true
            case .unsupported:
                return true
            case .unknown:
                return true
            }
        }
        
        static func shouldReport(_ error: StorageError) -> Bool {
            switch error {
            case .corrupted, .permissionDenied, .unsupported:
                return true
            case .capacityExceeded:
                return true
            default:
                return false
            }
        }
    }
}

// MARK: - Storage Error Handling
extension StorageError {
    
    struct Handler {
        
        static func handle(_ error: StorageError, context: String, logger: LoggerProtocol?) {
            // Log the error
            if Utilities.shouldLog(error) {
                logger?.logError(error, context: context, category: "Storage")
            }
            
            // Report critical errors
            if Utilities.shouldReport(error) {
                // Report to analytics/crash reporting service
                logger?.critical("Critical storage error: \(error.localizedDescription)", category: "Storage", file: #file, function: #function, line: #line)
            }
        }
        
        static func retry<T>(_ operation: () async throws -> T, 
                           error: StorageError, 
                           maxAttempts: Int? = nil,
                           logger: LoggerProtocol?) async throws -> T {
            let maxAttempts = maxAttempts ?? Utilities.getMaxRetryAttempts(error)
            var lastError = error
            
            for attempt in 1...maxAttempts {
                do {
                    return try await operation()
                } catch let newError as StorageError {
                    lastError = newError
                    
                    if !Utilities.shouldRetry(newError) {
                        throw newError
                    }
                    
                    if attempt < maxAttempts {
                        let delay = Utilities.getRetryDelay(newError, attempt: attempt)
                        logger?.warning("Storage operation failed, retrying in \(delay)s (attempt \(attempt)/\(maxAttempts))", category: "Storage", file: #file, function: #function, line: #line)
                        try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                    }
                } catch {
                    throw error
                }
            }
            
            throw lastError
        }
    }
} 