import Foundation
import os.log

/**
 * Logger - Infrastructure Layer
 * 
 * Professional logging system with multiple levels and categories.
 * Provides structured logging, performance tracking, and analytics integration.
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

// MARK: - Logger Implementation
class Logger: LoggerProtocol {
    
    // MARK: - Properties
    private let osLog: OSLog
    private var minimumLogLevel: LogLevel = .debug
    private var consoleLoggingEnabled = true
    private var fileLoggingEnabled = false
    private var remoteLoggingEnabled = false
    private let dateFormatter: DateFormatter
    private let fileManager = FileManager.default
    private let logDirectory: URL
    
    // MARK: - Analytics Service
    private let analyticsService: AnalyticsServiceProtocol?
    
    // MARK: - Initialization
    init(
        subsystem: String = Bundle.main.bundleIdentifier ?? "iOSCleanArchitectureTemplate",
        category: String = "Default",
        analyticsService: AnalyticsServiceProtocol? = nil
    ) {
        self.osLog = OSLog(subsystem: subsystem, category: category)
        self.analyticsService = analyticsService
        
        self.dateFormatter = DateFormatter()
        self.dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        
        // Create log directory
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        self.logDirectory = documentsPath.appendingPathComponent("Logs")
        
        try? fileManager.createDirectory(at: logDirectory, withIntermediateDirectories: true)
    }
    
    // MARK: - Public Methods
    func log(_ message: String, level: LogLevel, category: String, file: String, function: String, line: Int) {
        guard level.rawValue >= minimumLogLevel.rawValue else { return }
        
        let timestamp = dateFormatter.string(from: Date())
        let fileName = (file as NSString).lastPathComponent
        let logMessage = "\(level.emoji) [\(timestamp)] [\(level.displayName)] [\(category)] [\(fileName):\(line)] \(function): \(message)"
        
        // Console logging
        if consoleLoggingEnabled {
            print(logMessage)
        }
        
        // OS Log
        let osLogType: OSLogType
        switch level {
        case .debug:
            osLogType = .debug
        case .info:
            osLogType = .info
        case .warning:
            osLogType = .default
        case .error:
            osLogType = .error
        case .critical:
            osLogType = .fault
        }
        
        os_log("%{public}@", log: osLog, type: osLogType, logMessage)
        
        // File logging
        if fileLoggingEnabled {
            writeToFile(logMessage)
        }
        
        // Remote logging
        if remoteLoggingEnabled {
            sendToRemote(logMessage, level: level, category: category)
        }
    }
    
    func debug(_ message: String, category: String, file: String, function: String, line: Int) {
        log(message, level: .debug, category: category, file: file, function: function, line: line)
    }
    
    func info(_ message: String, category: String, file: String, function: String, line: Int) {
        log(message, level: .info, category: category, file: file, function: function, line: line)
    }
    
    func warning(_ message: String, category: String, file: String, function: String, line: Int) {
        log(message, level: .warning, category: category, file: file, function: function, line: line)
    }
    
    func error(_ message: String, category: String, file: String, function: String, line: Int) {
        log(message, level: .error, category: category, file: file, function: function, line: line)
    }
    
    func critical(_ message: String, category: String, file: String, function: String, line: Int) {
        log(message, level: .critical, category: category, file: file, function: function, line: line)
    }
    
    // MARK: - Specialized Logging
    func logPerformance(_ operation: String, duration: TimeInterval, category: String) {
        let message = "Performance: \(operation) took \(String(format: "%.3f", duration))s"
        info(message, category: category, file: #file, function: #function, line: #line)
        
        // Track performance analytics
        analyticsService?.trackEvent("performance_measurement", parameters: [
            "operation": operation,
            "duration": duration,
            "category": category
        ])
    }
    
    func logNetworkCall(_ endpoint: String, duration: TimeInterval, success: Bool, category: String) {
        let status = success ? "SUCCESS" : "FAILED"
        let message = "Network: \(endpoint) - \(status) (\(String(format: "%.3f", duration))s)"
        
        if success {
            info(message, category: category, file: #file, function: #function, line: #line)
        } else {
            error(message, category: category, file: #file, function: #function, line: #line)
        }
        
        // Track network analytics
        analyticsService?.trackEvent("network_call", parameters: [
            "endpoint": endpoint,
            "duration": duration,
            "success": success,
            "category": category
        ])
    }
    
    func logUserAction(_ action: String, parameters: [String: Any]?, category: String) {
        let paramsString = parameters?.description ?? "none"
        let message = "User Action: \(action) - Parameters: \(paramsString)"
        info(message, category: category, file: #file, function: #function, line: #line)
        
        // Track user action analytics
        analyticsService?.trackEvent("user_action", parameters: [
            "action": action,
            "parameters": parameters ?? [:],
            "category": category
        ])
    }
    
    func logError(_ error: Error, context: String, category: String) {
        let message = "Error in \(context): \(error.localizedDescription)"
        error(message, category: category, file: #file, function: #function, line: #line)
        
        // Track error analytics
        analyticsService?.trackEvent("error_occurred", parameters: [
            "context": context,
            "error_description": error.localizedDescription,
            "error_domain": (error as NSError).domain,
            "error_code": (error as NSError).code,
            "category": category
        ])
    }
    
    // MARK: - Configuration
    func setMinimumLogLevel(_ level: LogLevel) {
        minimumLogLevel = level
        info("Minimum log level set to: \(level.displayName)", category: "Logger", file: #file, function: #function, line: #line)
    }
    
    func enableConsoleLogging(_ enabled: Bool) {
        consoleLoggingEnabled = enabled
        info("Console logging \(enabled ? "enabled" : "disabled")", category: "Logger", file: #file, function: #function, line: #line)
    }
    
    func enableFileLogging(_ enabled: Bool) {
        fileLoggingEnabled = enabled
        info("File logging \(enabled ? "enabled" : "disabled")", category: "Logger", file: #file, function: #function, line: #line)
    }
    
    func enableRemoteLogging(_ enabled: Bool) {
        remoteLoggingEnabled = enabled
        info("Remote logging \(enabled ? "enabled" : "disabled")", category: "Logger", file: #file, function: #function, line: #line)
    }
    
    // MARK: - Private Methods
    private func writeToFile(_ message: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let fileName = "app_\(dateFormatter.string(from: Date())).log"
        let fileURL = logDirectory.appendingPathComponent(fileName)
        
        let logEntry = message + "\n"
        
        if let data = logEntry.data(using: .utf8) {
            if fileManager.fileExists(atPath: fileURL.path) {
                if let fileHandle = try? FileHandle(forWritingTo: fileURL) {
                    fileHandle.seekToEndOfFile()
                    fileHandle.write(data)
                    fileHandle.closeFile()
                }
            } else {
                try? data.write(to: fileURL)
            }
        }
    }
    
    private func sendToRemote(_ message: String, level: LogLevel, category: String) {
        // Implementation for remote logging service (e.g., Firebase, Crashlytics)
        // This would typically send logs to a remote service for monitoring
        analyticsService?.trackEvent("log_entry", parameters: [
            "message": message,
            "level": level.displayName,
            "category": category,
            "timestamp": Date().timeIntervalSince1970
        ])
    }
}

// MARK: - Logger Extensions
extension Logger {
    
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
}

// MARK: - Logger Categories
extension Logger {
    
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
    }
}

// MARK: - Global Logger Instance
extension Logger {
    static let shared = Logger()
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
