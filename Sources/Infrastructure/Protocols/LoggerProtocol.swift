import Foundation

/**
 * Logger Protocol - Infrastructure Layer
 * 
 * Abstract interface for logging operations.
 * Defines the contract for logger implementations.
 * 
 * - Author: iOS Clean Architecture Team
 * - Version: 2.0.0
 * - Date: 2024-01-15
 */

// MARK: - Log Level
enum LogLevel: Int, CaseIterable {
    case debug = 0
    case info = 1
    case warning = 2
    case error = 3
    case critical = 4
    
    var displayName: String {
        switch self {
        case .debug:
            return "DEBUG"
        case .info:
            return "INFO"
        case .warning:
            return "WARNING"
        case .error:
            return "ERROR"
        case .critical:
            return "CRITICAL"
        }
    }
    
    var emoji: String {
        switch self {
        case .debug:
            return "🔍"
        case .info:
            return "ℹ️"
        case .warning:
            return "⚠️"
        case .error:
            return "❌"
        case .critical:
            return "🚨"
        }
    }
}

// MARK: - Logger Protocol
protocol LoggerProtocol {
    func log(_ message: String, level: LogLevel, category: String, file: String, function: String, line: Int)
    func debug(_ message: String, category: String, file: String, function: String, line: Int)
    func info(_ message: String, category: String, file: String, function: String, line: Int)
    func warning(_ message: String, category: String, file: String, function: String, line: Int)
    func error(_ message: String, category: String, file: String, function: String, line: Int)
    func critical(_ message: String, category: String, file: String, function: String, line: Int)
    
    // MARK: - Specialized Logging
    func logPerformance(_ operation: String, duration: TimeInterval, category: String)
    func logNetworkCall(_ endpoint: String, duration: TimeInterval, success: Bool, category: String)
    func logUserAction(_ action: String, parameters: [String: Any]?, category: String)
    func logError(_ error: Error, context: String, category: String)
    
    // MARK: - Configuration
    func setMinimumLogLevel(_ level: LogLevel)
    func enableConsoleLogging(_ enabled: Bool)
    func enableFileLogging(_ enabled: Bool)
    func enableRemoteLogging(_ enabled: Bool)
}

// MARK: - Logger Error
enum LoggerError: LocalizedError {
    case invalidLogLevel(String)
    case invalidCategory(String)
    case fileWriteFailed(String)
    case remoteLoggingFailed(String)
    case configurationError(String)
    case unknown(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidLogLevel(let message):
            return "Invalid log level: \(message)"
        case .invalidCategory(let message):
            return "Invalid log category: \(message)"
        case .fileWriteFailed(let message):
            return "Failed to write to log file: \(message)"
        case .remoteLoggingFailed(let message):
            return "Failed to send log to remote service: \(message)"
        case .configurationError(let message):
            return "Logger configuration error: \(message)"
        case .unknown(let message):
            return "Unknown logger error: \(message)"
        }
    }
    
    var errorCode: Int {
        switch self {
        case .invalidLogLevel:
            return 6001
        case .invalidCategory:
            return 6002
        case .fileWriteFailed:
            return 6003
        case .remoteLoggingFailed:
            return 6004
        case .configurationError:
            return 6005
        case .unknown:
            return 6099
        }
    }
}

// MARK: - Logger Configuration
struct LoggerConfiguration {
    let minimumLogLevel: LogLevel
    let consoleLoggingEnabled: Bool
    let fileLoggingEnabled: Bool
    let remoteLoggingEnabled: Bool
    let maxFileSize: Int64
    let maxFileCount: Int
    let logDirectory: String
    let dateFormat: String
    let includeTimestamp: Bool
    let includeFileInfo: Bool
    let includeFunctionInfo: Bool
    let includeLineNumber: Bool
    
    init(
        minimumLogLevel: LogLevel = .debug,
        consoleLoggingEnabled: Bool = true,
        fileLoggingEnabled: Bool = false,
        remoteLoggingEnabled: Bool = false,
        maxFileSize: Int64 = 10 * 1024 * 1024, // 10 MB
        maxFileCount: Int = 5,
        logDirectory: String = "Logs",
        dateFormat: String = "yyyy-MM-dd HH:mm:ss.SSS",
        includeTimestamp: Bool = true,
        includeFileInfo: Bool = true,
        includeFunctionInfo: Bool = true,
        includeLineNumber: Bool = true
    ) {
        self.minimumLogLevel = minimumLogLevel
        self.consoleLoggingEnabled = consoleLoggingEnabled
        self.fileLoggingEnabled = fileLoggingEnabled
        self.remoteLoggingEnabled = remoteLoggingEnabled
        self.maxFileSize = maxFileSize
        self.maxFileCount = maxFileCount
        self.logDirectory = logDirectory
        self.dateFormat = dateFormat
        self.includeTimestamp = includeTimestamp
        self.includeFileInfo = includeFileInfo
        self.includeFunctionInfo = includeFunctionInfo
        self.includeLineNumber = includeLineNumber
    }
}

// MARK: - Logger Statistics
struct LoggerStatistics {
    let totalLogs: Int
    let debugLogs: Int
    let infoLogs: Int
    let warningLogs: Int
    let errorLogs: Int
    let criticalLogs: Int
    let fileLogs: Int
    let remoteLogs: Int
    let lastLogTime: Date?
    let timestamp: Date
    
    init(
        totalLogs: Int = 0,
        debugLogs: Int = 0,
        infoLogs: Int = 0,
        warningLogs: Int = 0,
        errorLogs: Int = 0,
        criticalLogs: Int = 0,
        fileLogs: Int = 0,
        remoteLogs: Int = 0,
        lastLogTime: Date? = nil
    ) {
        self.totalLogs = totalLogs
        self.debugLogs = debugLogs
        self.infoLogs = infoLogs
        self.warningLogs = warningLogs
        self.errorLogs = errorLogs
        self.criticalLogs = criticalLogs
        self.fileLogs = fileLogs
        self.remoteLogs = remoteLogs
        self.lastLogTime = lastLogTime
        self.timestamp = Date()
    }
}

// MARK: - Logger Extensions
extension LoggerProtocol {
    
    // MARK: - Convenience Methods
    func logAppLaunch() {
        info("App launched", category: "App", file: #file, function: #function, line: #line)
    }
    
    func logAppBackground() {
        info("App entered background", category: "App", file: #file, function: #function, line: #line)
    }
    
    func logAppForeground() {
        info("App entered foreground", category: "App", file: #file, function: #function, line: #line)
    }
    
    func logMemoryWarning() {
        warning("Memory warning received", category: "App", file: #file, function: #function, line: #line)
    }
    
    func logNetworkStatusChange(_ isConnected: Bool) {
        let status = isConnected ? "connected" : "disconnected"
        info("Network status changed: \(status)", category: "Network", file: #file, function: #function, line: #line)
    }
    
    func logDatabaseOperation(_ operation: String, success: Bool) {
        let status = success ? "SUCCESS" : "FAILED"
        let message = "Database \(operation): \(status)"
        
        if success {
            info(message, category: "Database", file: #file, function: #function, line: #line)
        } else {
            error(message, category: "Database", file: #file, function: #function, line: #line)
        }
    }
    
    func logCacheOperation(_ operation: String, key: String, success: Bool) {
        let status = success ? "SUCCESS" : "FAILED"
        let message = "Cache \(operation) for key '\(key)': \(status)"
        
        if success {
            debug(message, category: "Cache", file: #file, function: #function, line: #line)
        } else {
            warning(message, category: "Cache", file: #file, function: #function, line: #line)
        }
    }
    
    func logUserLogin(_ userId: String, success: Bool) {
        let status = success ? "SUCCESS" : "FAILED"
        let message = "User login: \(userId) - \(status)"
        
        if success {
            info(message, category: "User", file: #file, function: #function, line: #line)
        } else {
            warning(message, category: "User", file: #file, function: #function, line: #line)
        }
    }
    
    func logUserLogout(_ userId: String) {
        info("User logout: \(userId)", category: "User", file: #file, function: #function, line: #line)
    }
    
    func logFeatureUsage(_ feature: String, userId: String? = nil) {
        var message = "Feature used: \(feature)"
        if let userId = userId {
            message += " by user: \(userId)"
        }
        info(message, category: "Feature", file: #file, function: #function, line: #line)
    }
    
    func logSecurityEvent(_ event: String, details: String? = nil) {
        var message = "Security event: \(event)"
        if let details = details {
            message += " - \(details)"
        }
        warning(message, category: "Security", file: #file, function: #function, line: #line)
    }
    
    func logPerformanceIssue(_ operation: String, duration: TimeInterval, threshold: TimeInterval) {
        let message = "Performance issue: \(operation) took \(String(format: "%.3f", duration))s (threshold: \(String(format: "%.3f", threshold))s)"
        warning(message, category: "Performance", file: #file, function: #function, line: #line)
    }
}

// MARK: - Logger Categories
extension LoggerProtocol {
    
    struct Category {
        static let app = "App"
        static let network = "Network"
        static let database = "Database"
        static let cache = "Cache"
        static let ui = "UI"
        static let security = "Security"
        static let analytics = "Analytics"
        static let performance = "Performance"
        static let user = "User"
        static let error = "Error"
        static let feature = "Feature"
        static let system = "System"
    }
}

// MARK: - Logging Macros
#if DEBUG
    func logDebug(_ message: String, category: String = "Debug", file: String = #file, function: String = #function, line: Int = #line) {
        Logger.shared.debug(message, category: category, file: file, function: function, line: line)
    }
    
    func logInfo(_ message: String, category: String = "Info", file: String = #file, function: String = #function, line: Int = #line) {
        Logger.shared.info(message, category: category, file: file, function: function, line: line)
    }
    
    func logWarning(_ message: String, category: String = "Warning", file: String = #file, function: String = #function, line: Int = #line) {
        Logger.shared.warning(message, category: category, file: file, function: function, line: line)
    }
    
    func logError(_ message: String, category: String = "Error", file: String = #file, function: String = #function, line: Int = #line) {
        Logger.shared.error(message, category: category, file: file, function: function, line: line)
    }
    
    func logCritical(_ message: String, category: String = "Critical", file: String = #file, function: String = #function, line: Int = #line) {
        Logger.shared.critical(message, category: category, file: file, function: function, line: line)
    }
#else
    func logDebug(_ message: String, category: String = "Debug", file: String = #file, function: String = #function, line: Int = #line) {}
    func logInfo(_ message: String, category: String = "Info", file: String = #file, function: String = #function, line: Int = #line) {}
    func logWarning(_ message: String, category: String = "Warning", file: String = #file, function: String = #function, line: Int = #line) {}
    func logError(_ message: String, category: String = "Error", file: String = #file, function: String = #function, line: Int = #line) {}
    func logCritical(_ message: String, category: String = "Critical", file: String = #file, function: String = #function, line: Int = #line) {}
#endif 