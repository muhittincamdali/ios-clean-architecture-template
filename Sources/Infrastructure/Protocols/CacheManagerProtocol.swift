import Foundation

/**
 * Cache Manager Protocol - Infrastructure Layer
 * 
 * Abstract interface for cache management operations.
 * Defines the contract for cache manager implementations.
 * 
 * - Author: iOS Clean Architecture Team
 * - Version: 2.0.0
 * - Date: 2024-01-15
 */

// MARK: - Cache Type
enum CacheType {
    case memory
    case disk
    case hybrid
    
    var description: String {
        switch self {
        case .memory:
            return "Memory"
        case .disk:
            return "Disk"
        case .hybrid:
            return "Hybrid"
        }
    }
}

// MARK: - Cache Policy
enum CachePolicy {
    case memoryOnly
    case diskOnly
    case memoryAndDisk
    case memoryAndDiskAsync
}

// MARK: - Cache Entry
struct CacheEntry<T: Codable> {
    let key: String
    let value: T
    let timestamp: Date
    let expirationDate: Date?
    let size: Int
    let type: CacheType
    
    var isExpired: Bool {
        guard let expirationDate = expirationDate else { return false }
        return Date() > expirationDate
    }
    
    var age: TimeInterval {
        return Date().timeIntervalSince(timestamp)
    }
}

// MARK: - Cache Statistics
struct CacheStatistics {
    let totalEntries: Int
    let memoryEntries: Int
    let diskEntries: Int
    let totalSize: Int64
    let memorySize: Int64
    let diskSize: Int64
    let hitCount: Int
    let missCount: Int
    let hitRate: Double
    let evictionCount: Int
    let timestamp: Date
}

// MARK: - Cache Manager Protocol
protocol CacheManagerProtocol {
    func get<T: Codable>(forKey key: String) async throws -> T?
    func set<T: Codable>(_ value: T, forKey key: String, expiration: TimeInterval) async throws
    func remove(forKey key: String) async throws
    func clear() async throws
    func getStatistics() -> CacheStatistics
    func setCachePolicy(_ policy: CachePolicy)
    func setMemoryCapacity(_ capacity: Int64)
    func setDiskCapacity(_ capacity: Int64)
    func enableCache(_ enabled: Bool)
}

// MARK: - Cache Manager Error
enum CacheManagerError: LocalizedError {
    case saveFailed(String)
    case loadFailed(String)
    case removeFailed(String)
    case clearFailed(String)
    case capacityExceeded
    case encodingFailed(String)
    case decodingFailed(String)
    case invalidKey(String)
    case unknown(String)
    
    var errorDescription: String? {
        switch self {
        case .saveFailed(let message):
            return "Failed to save to cache: \(message)"
        case .loadFailed(let message):
            return "Failed to load from cache: \(message)"
        case .removeFailed(let message):
            return "Failed to remove from cache: \(message)"
        case .clearFailed(let message):
            return "Failed to clear cache: \(message)"
        case .capacityExceeded:
            return "Cache capacity exceeded"
        case .encodingFailed(let message):
            return "Failed to encode data: \(message)"
        case .decodingFailed(let message):
            return "Failed to decode data: \(message)"
        case .invalidKey(let message):
            return "Invalid cache key: \(message)"
        case .unknown(let message):
            return "Unknown cache error: \(message)"
        }
    }
    
    var errorCode: Int {
        switch self {
        case .saveFailed:
            return 8001
        case .loadFailed:
            return 8002
        case .removeFailed:
            return 8003
        case .clearFailed:
            return 8004
        case .capacityExceeded:
            return 8005
        case .encodingFailed:
            return 8006
        case .decodingFailed:
            return 8007
        case .invalidKey:
            return 8008
        case .unknown:
            return 8099
        }
    }
}

// MARK: - Cache Manager Configuration
struct CacheManagerConfiguration {
    let enabled: Bool
    let memoryCapacity: Int64
    let diskCapacity: Int64
    let defaultExpiration: TimeInterval
    let policy: CachePolicy
    let compressionEnabled: Bool
    let encryptionEnabled: Bool
    let maxMemoryEntries: Int
    let maxDiskEntries: Int
    
    init(
        enabled: Bool = true,
        memoryCapacity: Int64 = 50 * 1024 * 1024, // 50 MB
        diskCapacity: Int64 = 100 * 1024 * 1024, // 100 MB
        defaultExpiration: TimeInterval = 300, // 5 minutes
        policy: CachePolicy = .memoryAndDisk,
        compressionEnabled: Bool = false,
        encryptionEnabled: Bool = false,
        maxMemoryEntries: Int = 1000,
        maxDiskEntries: Int = 10000
    ) {
        self.enabled = enabled
        self.memoryCapacity = memoryCapacity
        self.diskCapacity = diskCapacity
        self.defaultExpiration = defaultExpiration
        self.policy = policy
        self.compressionEnabled = compressionEnabled
        self.encryptionEnabled = encryptionEnabled
        self.maxMemoryEntries = maxMemoryEntries
        self.maxDiskEntries = maxDiskEntries
    }
}

// MARK: - Cache Manager Extensions
extension CacheManagerProtocol {
    
    // MARK: - Convenience Methods
    func getString(forKey key: String) async throws -> String? {
        return try await get(forKey: key)
    }
    
    func setString(_ value: String, forKey key: String, expiration: TimeInterval = 300) async throws {
        try await set(value, forKey: key, expiration: expiration)
    }
    
    func getData(forKey key: String) async throws -> Data? {
        return try await get(forKey: key)
    }
    
    func setData(_ value: Data, forKey key: String, expiration: TimeInterval = 300) async throws {
        try await set(value, forKey: key, expiration: expiration)
    }
    
    func getImage(forKey key: String) async throws -> Data? {
        return try await get(forKey: key)
    }
    
    func setImage(_ value: Data, forKey key: String, expiration: TimeInterval = 3600) async throws {
        try await set(value, forKey: key, expiration: expiration)
    }
    
    func getJSON<T: Codable>(forKey key: String, type: T.Type) async throws -> T? {
        return try await get(forKey: key)
    }
    
    func setJSON<T: Codable>(_ value: T, forKey key: String, expiration: TimeInterval = 300) async throws {
        try await set(value, forKey: key, expiration: expiration)
    }
    
    func exists(forKey key: String) async -> Bool {
        do {
            let _: String? = try await get(forKey: key)
            return true
        } catch {
            return false
        }
    }
    
    func getCacheSize() -> Int64 {
        let stats = getStatistics()
        return stats.totalSize
    }
    
    func getHitRate() -> Double {
        let stats = getStatistics()
        return stats.hitRate
    }
    
    func isExpired(forKey key: String) async -> Bool {
        do {
            let _: String? = try await get(forKey: key)
            return false
        } catch {
            return true
        }
    }
    
    func getExpirationDate(forKey key: String) async -> Date? {
        // This would need to be implemented based on the specific cache implementation
        return nil
    }
    
    func extendExpiration(forKey key: String, by duration: TimeInterval) async throws {
        // This would need to be implemented based on the specific cache implementation
    }
    
    func getKeys() async -> [String] {
        // This would need to be implemented based on the specific cache implementation
        return []
    }
    
    func getKeys(matching pattern: String) async -> [String] {
        // This would need to be implemented based on the specific cache implementation
        return []
    }
    
    func removeExpired() async throws {
        // This would need to be implemented based on the specific cache implementation
    }
    
    func compact() async throws {
        // This would need to be implemented based on the specific cache implementation
    }
}

// MARK: - Cache Categories
extension CacheManagerProtocol {
    
    struct Category {
        static let cache = "Cache"
        static let memory = "Memory"
        static let disk = "Disk"
        static let performance = "Performance"
    }
} 