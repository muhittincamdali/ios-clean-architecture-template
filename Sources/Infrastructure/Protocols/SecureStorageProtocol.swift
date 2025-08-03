import Foundation

/**
 * Secure Storage Protocol - Infrastructure Layer
 * 
 * Abstract interface for secure storage operations.
 * Defines the contract for secure storage implementations.
 * 
 * - Author: iOS Clean Architecture Team
 * - Version: 2.0.0
 * - Date: 2024-01-15
 */

// MARK: - Secure Storage Protocol
protocol SecureStorageProtocol {
    func saveString(_ value: String, forKey key: String) async throws
    func loadString(forKey key: String) async throws -> String?
    func saveData(_ value: Data, forKey key: String) async throws
    func loadData(forKey key: String) async throws -> Data?
    func saveObject<T: Codable>(_ value: T, forKey key: String) async throws
    func loadObject<T: Codable>(forKey key: String, type: T.Type) async throws -> T?
    func delete(forKey key: String) async throws
    func clear() async throws
    func exists(forKey key: String) async -> Bool
    func getAllKeys() async -> [String]
}

// MARK: - Secure Storage Error
enum SecureStorageError: LocalizedError {
    case saveFailed(String)
    case loadFailed(String)
    case deleteFailed(String)
    case clearFailed(String)
    case encodingFailed(String)
    case decodingFailed(String)
    case keyNotFound(String)
    case invalidKey(String)
    case permissionDenied(String)
    case encryptionFailed(String)
    case decryptionFailed(String)
    case unknown(String)
    
    var errorDescription: String? {
        switch self {
        case .saveFailed(let message):
            return "Failed to save to secure storage: \(message)"
        case .loadFailed(let message):
            return "Failed to load from secure storage: \(message)"
        case .deleteFailed(let message):
            return "Failed to delete from secure storage: \(message)"
        case .clearFailed(let message):
            return "Failed to clear secure storage: \(message)"
        case .encodingFailed(let message):
            return "Failed to encode data: \(message)"
        case .decodingFailed(let message):
            return "Failed to decode data: \(message)"
        case .keyNotFound(let message):
            return "Key not found in secure storage: \(message)"
        case .invalidKey(let message):
            return "Invalid key for secure storage: \(message)"
        case .permissionDenied(let message):
            return "Permission denied for secure storage: \(message)"
        case .encryptionFailed(let message):
            return "Failed to encrypt data: \(message)"
        case .decryptionFailed(let message):
            return "Failed to decrypt data: \(message)"
        case .unknown(let message):
            return "Unknown secure storage error: \(message)"
        }
    }
    
    var errorCode: Int {
        switch self {
        case .saveFailed:
            return 9001
        case .loadFailed:
            return 9002
        case .deleteFailed:
            return 9003
        case .clearFailed:
            return 9004
        case .encodingFailed:
            return 9005
        case .decodingFailed:
            return 9006
        case .keyNotFound:
            return 9007
        case .invalidKey:
            return 9008
        case .permissionDenied:
            return 9009
        case .encryptionFailed:
            return 9010
        case .decryptionFailed:
            return 9011
        case .unknown:
            return 9099
        }
    }
}

// MARK: - Secure Storage Configuration
struct SecureStorageConfiguration {
    let enabled: Bool
    let encryptionEnabled: Bool
    let biometricEnabled: Bool
    let accessControlEnabled: Bool
    let keychainAccessibility: KeychainAccessibility
    let keychainSharingEnabled: Bool
    let maxKeyLength: Int
    let maxValueSize: Int
    
    enum KeychainAccessibility {
        case whenUnlocked
        case afterFirstUnlock
        case always
        case whenPasscodeSetThisDeviceOnly
        case whenUnlockedThisDeviceOnly
        case afterFirstUnlockThisDeviceOnly
        case alwaysThisDeviceOnly
        
        var rawValue: String {
            switch self {
            case .whenUnlocked:
                return "kSecAttrAccessibleWhenUnlocked"
            case .afterFirstUnlock:
                return "kSecAttrAccessibleAfterFirstUnlock"
            case .always:
                return "kSecAttrAccessibleAlways"
            case .whenPasscodeSetThisDeviceOnly:
                return "kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly"
            case .whenUnlockedThisDeviceOnly:
                return "kSecAttrAccessibleWhenUnlockedThisDeviceOnly"
            case .afterFirstUnlockThisDeviceOnly:
                return "kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly"
            case .alwaysThisDeviceOnly:
                return "kSecAttrAccessibleAlwaysThisDeviceOnly"
            }
        }
    }
    
    init(
        enabled: Bool = true,
        encryptionEnabled: Bool = true,
        biometricEnabled: Bool = false,
        accessControlEnabled: Bool = false,
        keychainAccessibility: KeychainAccessibility = .whenUnlocked,
        keychainSharingEnabled: Bool = false,
        maxKeyLength: Int = 255,
        maxValueSize: Int = 1024 * 1024 // 1 MB
    ) {
        self.enabled = enabled
        self.encryptionEnabled = encryptionEnabled
        self.biometricEnabled = biometricEnabled
        self.accessControlEnabled = accessControlEnabled
        self.keychainAccessibility = keychainAccessibility
        self.keychainSharingEnabled = keychainSharingEnabled
        self.maxKeyLength = maxKeyLength
        self.maxValueSize = maxValueSize
    }
}

// MARK: - Secure Storage Statistics
struct SecureStorageStatistics {
    let totalEntries: Int
    let totalSize: Int64
    let encryptedEntries: Int
    let biometricProtectedEntries: Int
    let lastAccessTime: Date?
    let timestamp: Date
    
    init(
        totalEntries: Int = 0,
        totalSize: Int64 = 0,
        encryptedEntries: Int = 0,
        biometricProtectedEntries: Int = 0,
        lastAccessTime: Date? = nil
    ) {
        self.totalEntries = totalEntries
        self.totalSize = totalSize
        self.encryptedEntries = encryptedEntries
        self.biometricProtectedEntries = biometricProtectedEntries
        self.lastAccessTime = lastAccessTime
        self.timestamp = Date()
    }
}

// MARK: - Secure Storage Extensions
extension SecureStorageProtocol {
    
    // MARK: - Convenience Methods
    func saveBool(_ value: Bool, forKey key: String) async throws {
        try await saveString(String(value), forKey: key)
    }
    
    func loadBool(forKey key: String) async throws -> Bool? {
        guard let stringValue = try await loadString(forKey: key) else { return nil }
        return Bool(stringValue)
    }
    
    func saveInt(_ value: Int, forKey key: String) async throws {
        try await saveString(String(value), forKey: key)
    }
    
    func loadInt(forKey key: String) async throws -> Int? {
        guard let stringValue = try await loadString(forKey: key) else { return nil }
        return Int(stringValue)
    }
    
    func saveDouble(_ value: Double, forKey key: String) async throws {
        try await saveString(String(value), forKey: key)
    }
    
    func loadDouble(forKey key: String) async throws -> Double? {
        guard let stringValue = try await loadString(forKey: key) else { return nil }
        return Double(stringValue)
    }
    
    func saveDate(_ value: Date, forKey key: String) async throws {
        let timeInterval = value.timeIntervalSince1970
        try await saveDouble(timeInterval, forKey: key)
    }
    
    func loadDate(forKey key: String) async throws -> Date? {
        guard let timeInterval = try await loadDouble(forKey: key) else { return nil }
        return Date(timeIntervalSince1970: timeInterval)
    }
    
    func saveArray<T: Codable>(_ value: [T], forKey key: String) async throws {
        try await saveObject(value, forKey: key)
    }
    
    func loadArray<T: Codable>(forKey key: String, type: T.Type) async throws -> [T]? {
        return try await loadObject(forKey: key, type: [T].self)
    }
    
    func saveDictionary<K: Codable, V: Codable>(_ value: [K: V], forKey key: String) async throws {
        try await saveObject(value, forKey: key)
    }
    
    func loadDictionary<K: Codable, V: Codable>(forKey key: String, keyType: K.Type, valueType: V.Type) async throws -> [K: V]? {
        return try await loadObject(forKey: key, type: [K: V].self)
    }
    
    // MARK: - Utility Methods
    func getStatistics() -> SecureStorageStatistics {
        // This would typically return actual statistics
        return SecureStorageStatistics()
    }
    
    func validateKey(_ key: String) -> Bool {
        return !key.isEmpty && key.count <= 255
    }
    
    func validateValue(_ value: Data) -> Bool {
        return value.count <= 1024 * 1024 // 1 MB
    }
    
    func isKeyExists(_ key: String) async -> Bool {
        return await exists(forKey: key)
    }
    
    func getValueSize(forKey key: String) async -> Int? {
        guard let data = try await loadData(forKey: key) else { return nil }
        return data.count
    }
    
    func getKeys(matching pattern: String) async -> [String] {
        let allKeys = await getAllKeys()
        return allKeys.filter { $0.contains(pattern) }
    }
    
    func getKeys(withPrefix prefix: String) async -> [String] {
        let allKeys = await getAllKeys()
        return allKeys.filter { $0.hasPrefix(prefix) }
    }
    
    func getKeys(withSuffix suffix: String) async -> [String] {
        let allKeys = await getAllKeys()
        return allKeys.filter { $0.hasSuffix(suffix) }
    }
    
    func deleteKeys(matching pattern: String) async throws {
        let keysToDelete = await getKeys(matching: pattern)
        for key in keysToDelete {
            try await delete(forKey: key)
        }
    }
    
    func deleteKeys(withPrefix prefix: String) async throws {
        let keysToDelete = await getKeys(withPrefix: prefix)
        for key in keysToDelete {
            try await delete(forKey: key)
        }
    }
    
    func deleteKeys(withSuffix suffix: String) async throws {
        let keysToDelete = await getKeys(withSuffix: suffix)
        for key in keysToDelete {
            try await delete(forKey: key)
        }
    }
    
    func migrate(from oldKey: String, to newKey: String) async throws {
        guard let value = try await loadData(forKey: oldKey) else {
            throw SecureStorageError.keyNotFound(oldKey)
        }
        
        try await saveData(value, forKey: newKey)
        try await delete(forKey: oldKey)
    }
    
    func backup() async throws -> Data {
        let allKeys = await getAllKeys()
        var backupData: [String: Data] = [:]
        
        for key in allKeys {
            if let data = try await loadData(forKey: key) {
                backupData[key] = data
            }
        }
        
        return try JSONEncoder().encode(backupData)
    }
    
    func restore(from backupData: Data) async throws {
        let backupDict = try JSONDecoder().decode([String: Data].self, from: backupData)
        
        for (key, data) in backupDict {
            try await saveData(data, forKey: key)
        }
    }
}

// MARK: - Secure Storage Categories
extension SecureStorageProtocol {
    
    struct Category {
        static let storage = "Storage"
        static let security = "Security"
        static let keychain = "Keychain"
        static let encryption = "Encryption"
    }
} 