import Foundation

/**
 * Cache Manager - Infrastructure Layer
 * 
 * Professional cache management system with multiple storage types.
 * Provides memory cache, disk cache, and intelligent cache eviction strategies.
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

// MARK: - Cache Manager Implementation
class CacheManager: CacheManagerProtocol {
    
    // MARK: - Properties
    static let shared = CacheManager()
    
    private let memoryCache = NSCache<NSString, AnyObject>()
    private let diskCache: DiskCache
    private let fileManager = FileManager.default
    private let cacheDirectory: URL
    
    private var cachePolicy: CachePolicy = .memoryAndDisk
    private var memoryCapacity: Int64 = 50 * 1024 * 1024 // 50 MB
    private var diskCapacity: Int64 = 100 * 1024 * 1024 // 100 MB
    private var isEnabled = true
    
    private var hitCount = 0
    private var missCount = 0
    private var evictionCount = 0
    
    private let analyticsService: AnalyticsServiceProtocol?
    private let logger: LoggerProtocol?
    
    // MARK: - Initialization
    init(
        analyticsService: AnalyticsServiceProtocol? = nil,
        logger: LoggerProtocol? = nil
    ) {
        self.analyticsService = analyticsService
        self.logger = logger
        
        // Configure memory cache
        memoryCache.totalCostLimit = Int(memoryCapacity)
        memoryCache.countLimit = 1000
        
        // Setup disk cache
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        self.cacheDirectory = documentsPath.appendingPathComponent("Cache")
        self.diskCache = DiskCache(directory: cacheDirectory, capacity: diskCapacity)
        
        // Create cache directory
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        
        logger?.info("Cache manager initialized", category: "Cache", file: #file, function: #function, line: #line)
    }
    
    // MARK: - Public Methods
    func get<T: Codable>(forKey key: String) async throws -> T? {
        guard isEnabled else { return nil }
        
        let cacheKey = NSString(string: key)
        
        // Try memory cache first
        if let cachedValue = memoryCache.object(forKey: cacheKey) as? CacheEntry<T> {
            if !cachedValue.isExpired {
                hitCount += 1
                logger?.logCacheOperation("get", key: key, success: true)
                return cachedValue.value
            } else {
                // Remove expired entry
                memoryCache.removeObject(forKey: cacheKey)
            }
        }
        
        // Try disk cache
        if cachePolicy != .memoryOnly {
            if let diskEntry: CacheEntry<T> = try await diskCache.get(forKey: key) {
                if !diskEntry.isExpired {
                    hitCount += 1
                    
                    // Add to memory cache if policy allows
                    if cachePolicy == .memoryAndDisk || cachePolicy == .memoryAndDiskAsync {
                        memoryCache.setObject(diskEntry as AnyObject, forKey: cacheKey)
                    }
                    
                    logger?.logCacheOperation("get", key: key, success: true)
                    return diskEntry.value
                } else {
                    // Remove expired entry
                    try await diskCache.remove(forKey: key)
                }
            }
        }
        
        missCount += 1
        logger?.logCacheOperation("get", key: key, success: false)
        return nil
    }
    
    func set<T: Codable>(_ value: T, forKey key: String, expiration: TimeInterval = 300) async throws {
        guard isEnabled else { return }
        
        let cacheKey = NSString(string: key)
        let expirationDate = Date().addingTimeInterval(expiration)
        let size = estimateSize(of: value)
        
        let entry = CacheEntry(
            key: key,
            value: value,
            timestamp: Date(),
            expirationDate: expirationDate,
            size: size,
            type: cachePolicy == .diskOnly ? .disk : .memory
        )
        
        // Store in memory cache
        if cachePolicy != .diskOnly {
            memoryCache.setObject(entry as AnyObject, forKey: cacheKey)
        }
        
        // Store in disk cache
        if cachePolicy != .memoryOnly {
            try await diskCache.set(entry, forKey: key)
        }
        
        logger?.logCacheOperation("set", key: key, success: true)
        
        // Track analytics
        analyticsService?.trackEvent("cache_entry_set", parameters: [
            "key": key,
            "size": size,
            "expiration": expiration,
            "policy": cachePolicy.description
        ])
    }
    
    func remove(forKey key: String) async throws {
        let cacheKey = NSString(string: key)
        
        // Remove from memory cache
        memoryCache.removeObject(forKey: cacheKey)
        
        // Remove from disk cache
        try await diskCache.remove(forKey: key)
        
        logger?.logCacheOperation("remove", key: key, success: true)
    }
    
    func clear() async throws {
        // Clear memory cache
        memoryCache.removeAllObjects()
        
        // Clear disk cache
        try await diskCache.clear()
        
        // Reset statistics
        hitCount = 0
        missCount = 0
        evictionCount = 0
        
        logger?.info("Cache cleared", category: "Cache", file: #file, function: #function, line: #line)
    }
    
    func getStatistics() -> CacheStatistics {
        let totalHitRate = hitCount + missCount > 0 ? Double(hitCount) / Double(hitCount + missCount) : 0.0
        
        return CacheStatistics(
            totalEntries: memoryCache.totalCostLimit + diskCache.getEntryCount(),
            memoryEntries: memoryCache.countLimit,
            diskEntries: diskCache.getEntryCount(),
            totalSize: Int64(memoryCache.totalCostLimit) + diskCache.getTotalSize(),
            memorySize: Int64(memoryCache.totalCostLimit),
            diskSize: diskCache.getTotalSize(),
            hitCount: hitCount,
            missCount: missCount,
            hitRate: totalHitRate,
            evictionCount: evictionCount,
            timestamp: Date()
        )
    }
    
    func setCachePolicy(_ policy: CachePolicy) {
        cachePolicy = policy
        logger?.info("Cache policy set to: \(policy)", category: "Cache", file: #file, function: #function, line: #line)
    }
    
    func setMemoryCapacity(_ capacity: Int64) {
        memoryCapacity = capacity
        memoryCache.totalCostLimit = Int(capacity)
        logger?.info("Memory cache capacity set to: \(capacity) bytes", category: "Cache", file: #file, function: #function, line: #line)
    }
    
    func setDiskCapacity(_ capacity: Int64) {
        diskCapacity = capacity
        diskCache.setCapacity(capacity)
        logger?.info("Disk cache capacity set to: \(capacity) bytes", category: "Cache", file: #file, function: #function, line: #line)
    }
    
    func enableCache(_ enabled: Bool) {
        isEnabled = enabled
        logger?.info("Cache \(enabled ? "enabled" : "disabled")", category: "Cache", file: #file, function: #function, line: #line)
    }
    
    // MARK: - Private Methods
    private func estimateSize<T>(of value: T) -> Int {
        // Simplified size estimation
        // In a real implementation, you would calculate actual size
        return MemoryLayout<T>.size
    }
}

// MARK: - Disk Cache
class DiskCache {
    
    private let directory: URL
    private var capacity: Int64
    private let fileManager = FileManager.default
    
    init(directory: URL, capacity: Int64) {
        self.directory = directory
        self.capacity = capacity
    }
    
    func get<T: Codable>(forKey key: String) async throws -> CacheEntry<T>? {
        let fileURL = directory.appendingPathComponent(key)
        
        guard fileManager.fileExists(atPath: fileURL.path) else {
            return nil
        }
        
        do {
            let data = try Data(contentsOf: fileURL)
            let entry = try JSONDecoder().decode(CacheEntry<T>.self, from: data)
            
            if entry.isExpired {
                try fileManager.removeItem(at: fileURL)
                return nil
            }
            
            return entry
        } catch {
            return nil
        }
    }
    
    func set<T: Codable>(_ entry: CacheEntry<T>, forKey key: String) async throws {
        let fileURL = directory.appendingPathComponent(key)
        
        do {
            let data = try JSONEncoder().encode(entry)
            try data.write(to: fileURL)
            
            // Check capacity and evict if necessary
            await checkCapacity()
        } catch {
            throw CacheError.saveFailed(error.localizedDescription)
        }
    }
    
    func remove(forKey key: String) async throws {
        let fileURL = directory.appendingPathComponent(key)
        
        if fileManager.fileExists(atPath: fileURL.path) {
            try fileManager.removeItem(at: fileURL)
        }
    }
    
    func clear() async throws {
        let contents = try fileManager.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)
        
        for fileURL in contents {
            try fileManager.removeItem(at: fileURL)
        }
    }
    
    func getEntryCount() -> Int {
        do {
            let contents = try fileManager.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)
            return contents.count
        } catch {
            return 0
        }
    }
    
    func getTotalSize() -> Int64 {
        do {
            let contents = try fileManager.contentsOfDirectory(at: directory, includingPropertiesForKeys: [.fileSizeKey])
            return try contents.reduce(0) { total, fileURL in
                let resourceValues = try fileURL.resourceValues(forKeys: [.fileSizeKey])
                return total + Int64(resourceValues.fileSize ?? 0)
            }
        } catch {
            return 0
        }
    }
    
    func setCapacity(_ capacity: Int64) {
        self.capacity = capacity
    }
    
    private func checkCapacity() async {
        let currentSize = getTotalSize()
        
        if currentSize > capacity {
            // Implement LRU eviction
            await evictOldestEntries()
        }
    }
    
    private func evictOldestEntries() async {
        do {
            let contents = try fileManager.contentsOfDirectory(at: directory, includingPropertiesForKeys: [.creationDateKey])
            
            let sortedFiles = try contents.sorted { fileURL1, fileURL2 in
                let date1 = try fileURL1.resourceValues(forKeys: [.creationDateKey]).creationDate ?? Date.distantPast
                let date2 = try fileURL2.resourceValues(forKeys: [.creationDateKey]).creationDate ?? Date.distantPast
                return date1 < date2
            }
            
            // Remove oldest files until under capacity
            var currentSize = getTotalSize()
            for fileURL in sortedFiles {
                if currentSize <= capacity {
                    break
                }
                
                let resourceValues = try fileURL.resourceValues(forKeys: [.fileSizeKey])
                let fileSize = Int64(resourceValues.fileSize ?? 0)
                
                try fileManager.removeItem(at: fileURL)
                currentSize -= fileSize
            }
        } catch {
            // Handle error
        }
    }
}

// MARK: - Cache Error
enum CacheError: LocalizedError {
    case saveFailed(String)
    case loadFailed(String)
    case removeFailed(String)
    case clearFailed(String)
    case capacityExceeded
    
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
        }
    }
}

// MARK: - Cache Manager Extensions
extension CacheManager {
    
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
}

// MARK: - Cache Categories
extension CacheManager {
    
    struct Category {
        static let cache = "Cache"
        static let memory = "Memory"
        static let disk = "Disk"
        static let performance = "Performance"
    }
} 