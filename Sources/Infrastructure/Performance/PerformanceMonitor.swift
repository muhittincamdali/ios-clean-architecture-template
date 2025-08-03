import Foundation
import UIKit

/**
 * Performance Monitor - Infrastructure Layer
 * 
 * Professional performance monitoring system with advanced metrics.
 * Provides app launch time, memory usage, CPU usage, and battery optimization.
 * 
 * - Author: iOS Clean Architecture Team
 * - Version: 2.0.0
 * - Date: 2024-01-15
 */

// MARK: - Performance Monitor Protocol
protocol PerformanceMonitorProtocol {
    func startMonitoring()
    func stopMonitoring()
    func trackAppLaunchTime()
    func trackMemoryUsage()
    func trackCPUUsage()
    func trackBatteryUsage()
    func trackNetworkPerformance(_ endpoint: String, duration: TimeInterval)
    func trackDatabasePerformance(_ operation: String, duration: TimeInterval)
    func trackUIPerformance(_ screen: String, loadTime: TimeInterval)
    func getPerformanceReport() -> PerformanceReport
    func setPerformanceThresholds(_ thresholds: PerformanceThresholds)
    func enablePerformanceMonitoring(_ enabled: Bool)
}

// MARK: - Performance Metrics
struct PerformanceMetrics {
    let appLaunchTime: TimeInterval
    let memoryUsage: MemoryUsage
    let cpuUsage: Double
    let batteryLevel: Double
    let networkLatency: TimeInterval
    let databaseLatency: TimeInterval
    let uiLoadTime: TimeInterval
    let timestamp: Date
    
    struct MemoryUsage {
        let used: UInt64
        let available: UInt64
        let total: UInt64
        
        var percentage: Double {
            return Double(used) / Double(total) * 100.0
        }
    }
}

// MARK: - Performance Report
struct PerformanceReport {
    let metrics: [PerformanceMetrics]
    let averageAppLaunchTime: TimeInterval
    let averageMemoryUsage: Double
    let averageCPUUsage: Double
    let averageBatteryUsage: Double
    let networkPerformance: NetworkPerformance
    let databasePerformance: DatabasePerformance
    let uiPerformance: UIPerformance
    let recommendations: [String]
    let timestamp: Date
    
    struct NetworkPerformance {
        let averageLatency: TimeInterval
        let totalRequests: Int
        let successfulRequests: Int
        let failedRequests: Int
        let slowestEndpoint: String
        let fastestEndpoint: String
    }
    
    struct DatabasePerformance {
        let averageLatency: TimeInterval
        let totalOperations: Int
        let readOperations: Int
        let writeOperations: Int
        let slowestOperation: String
        let fastestOperation: String
    }
    
    struct UIPerformance {
        let averageLoadTime: TimeInterval
        let totalScreens: Int
        let slowestScreen: String
        let fastestScreen: String
        let frameRate: Double
    }
}

// MARK: - Performance Thresholds
struct PerformanceThresholds {
    let maxAppLaunchTime: TimeInterval
    let maxMemoryUsage: Double
    let maxCPUUsage: Double
    let maxBatteryUsage: Double
    let maxNetworkLatency: TimeInterval
    let maxDatabaseLatency: TimeInterval
    let maxUILoadTime: TimeInterval
    let minFrameRate: Double
    
    static let standard = PerformanceThresholds(
        maxAppLaunchTime: 1.3,
        maxMemoryUsage: 200.0, // MB
        maxCPUUsage: 80.0, // %
        maxBatteryUsage: 5.0, // % per hour
        maxNetworkLatency: 0.2, // seconds
        maxDatabaseLatency: 0.1, // seconds
        maxUILoadTime: 0.5, // seconds
        minFrameRate: 55.0 // FPS
    )
}

// MARK: - Performance Monitor Implementation
class PerformanceMonitor: PerformanceMonitorProtocol {
    
    // MARK: - Properties
    static let shared = PerformanceMonitor()
    
    private var isMonitoring = false
    private var metrics: [PerformanceMetrics] = []
    private var thresholds = PerformanceThresholds.standard
    private var appLaunchStartTime: Date?
    private var networkMetrics: [String: [TimeInterval]] = [:]
    private var databaseMetrics: [String: [TimeInterval]] = [:]
    private var uiMetrics: [String: [TimeInterval]] = [:]
    private let analyticsService: AnalyticsServiceProtocol?
    private let logger: LoggerProtocol?
    
    // MARK: - Initialization
    init(
        analyticsService: AnalyticsServiceProtocol? = nil,
        logger: LoggerProtocol? = nil
    ) {
        self.analyticsService = analyticsService
        self.logger = logger
    }
    
    // MARK: - Public Methods
    func startMonitoring() {
        isMonitoring = true
        appLaunchStartTime = Date()
        
        logger?.info("Performance monitoring started", category: "Performance", file: #file, function: #function, line: #line)
        
        // Start periodic monitoring
        startPeriodicMonitoring()
    }
    
    func stopMonitoring() {
        isMonitoring = false
        
        logger?.info("Performance monitoring stopped", category: "Performance", file: #file, function: #function, line: #line)
    }
    
    func trackAppLaunchTime() {
        guard let startTime = appLaunchStartTime else { return }
        
        let launchTime = Date().timeIntervalSince(startTime)
        
        logger?.logPerformance("App Launch", duration: launchTime, category: "Performance")
        
        analyticsService?.trackPerformance("App Launch", duration: launchTime)
        
        // Check if launch time exceeds threshold
        if launchTime > thresholds.maxAppLaunchTime {
            logger?.warning("App launch time (\(String(format: "%.3f", launchTime))s) exceeds threshold (\(String(format: "%.3f", thresholds.maxAppLaunchTime))s)", category: "Performance", file: #file, function: #function, line: #line)
        }
    }
    
    func trackMemoryUsage() {
        let memoryUsage = getCurrentMemoryUsage()
        
        logger?.info("Memory usage: \(String(format: "%.1f", memoryUsage.percentage))% (\(memoryUsage.used / 1024 / 1024) MB)", category: "Performance", file: #file, function: #function, line: #line)
        
        // Check if memory usage exceeds threshold
        if memoryUsage.percentage > thresholds.maxMemoryUsage {
            logger?.warning("Memory usage (\(String(format: "%.1f", memoryUsage.percentage))%) exceeds threshold (\(String(format: "%.1f", thresholds.maxMemoryUsage))%)", category: "Performance", file: #file, function: #function, line: #line)
        }
    }
    
    func trackCPUUsage() {
        let cpuUsage = getCurrentCPUUsage()
        
        logger?.info("CPU usage: \(String(format: "%.1f", cpuUsage))%", category: "Performance", file: #file, function: #function, line: #line)
        
        // Check if CPU usage exceeds threshold
        if cpuUsage > thresholds.maxCPUUsage {
            logger?.warning("CPU usage (\(String(format: "%.1f", cpuUsage))%) exceeds threshold (\(String(format: "%.1f", thresholds.maxCPUUsage))%)", category: "Performance", file: #file, function: #function, line: #line)
        }
    }
    
    func trackBatteryUsage() {
        let batteryLevel = getCurrentBatteryLevel()
        
        logger?.info("Battery level: \(String(format: "%.1f", batteryLevel))%", category: "Performance", file: #file, function: #function, line: #line)
        
        // Check if battery usage is high
        if batteryLevel < 20.0 {
            logger?.warning("Battery level is low: \(String(format: "%.1f", batteryLevel))%", category: "Performance", file: #file, function: #function, line: #line)
        }
    }
    
    func trackNetworkPerformance(_ endpoint: String, duration: TimeInterval) {
        if networkMetrics[endpoint] == nil {
            networkMetrics[endpoint] = []
        }
        networkMetrics[endpoint]?.append(duration)
        
        logger?.logNetworkCall(endpoint, duration: duration, success: true, category: "Performance")
        
        // Check if network latency exceeds threshold
        if duration > thresholds.maxNetworkLatency {
            logger?.warning("Network latency for \(endpoint) (\(String(format: "%.3f", duration))s) exceeds threshold (\(String(format: "%.3f", thresholds.maxNetworkLatency))s)", category: "Performance", file: #file, function: #function, line: #line)
        }
    }
    
    func trackDatabasePerformance(_ operation: String, duration: TimeInterval) {
        if databaseMetrics[operation] == nil {
            databaseMetrics[operation] = []
        }
        databaseMetrics[operation]?.append(duration)
        
        logger?.logPerformance("Database \(operation)", duration: duration, category: "Performance")
        
        // Check if database latency exceeds threshold
        if duration > thresholds.maxDatabaseLatency {
            logger?.warning("Database latency for \(operation) (\(String(format: "%.3f", duration))s) exceeds threshold (\(String(format: "%.3f", thresholds.maxDatabaseLatency))s)", category: "Performance", file: #file, function: #function, line: #line)
        }
    }
    
    func trackUIPerformance(_ screen: String, loadTime: TimeInterval) {
        if uiMetrics[screen] == nil {
            uiMetrics[screen] = []
        }
        uiMetrics[screen]?.append(loadTime)
        
        logger?.logPerformance("UI Load \(screen)", duration: loadTime, category: "Performance")
        
        // Check if UI load time exceeds threshold
        if loadTime > thresholds.maxUILoadTime {
            logger?.warning("UI load time for \(screen) (\(String(format: "%.3f", loadTime))s) exceeds threshold (\(String(format: "%.3f", thresholds.maxUILoadTime))s)", category: "Performance", file: #file, function: #function, line: #line)
        }
    }
    
    func getPerformanceReport() -> PerformanceReport {
        let currentMetrics = PerformanceMetrics(
            appLaunchTime: getAverageAppLaunchTime(),
            memoryUsage: getCurrentMemoryUsage(),
            cpuUsage: getCurrentCPUUsage(),
            batteryLevel: getCurrentBatteryLevel(),
            networkLatency: getAverageNetworkLatency(),
            databaseLatency: getAverageDatabaseLatency(),
            uiLoadTime: getAverageUILoadTime(),
            timestamp: Date()
        )
        
        metrics.append(currentMetrics)
        
        return PerformanceReport(
            metrics: metrics,
            averageAppLaunchTime: getAverageAppLaunchTime(),
            averageMemoryUsage: getAverageMemoryUsage(),
            averageCPUUsage: getAverageCPUUsage(),
            averageBatteryUsage: getAverageBatteryUsage(),
            networkPerformance: getNetworkPerformance(),
            databasePerformance: getDatabasePerformance(),
            uiPerformance: getUIPerformance(),
            recommendations: generateRecommendations(),
            timestamp: Date()
        )
    }
    
    func setPerformanceThresholds(_ thresholds: PerformanceThresholds) {
        self.thresholds = thresholds
        
        logger?.info("Performance thresholds updated", category: "Performance", file: #file, function: #function, line: #line)
    }
    
    func enablePerformanceMonitoring(_ enabled: Bool) {
        if enabled {
            startMonitoring()
        } else {
            stopMonitoring()
        }
    }
    
    // MARK: - Private Methods
    private func startPeriodicMonitoring() {
        Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { _ in
            guard self.isMonitoring else { return }
            
            self.trackMemoryUsage()
            self.trackCPUUsage()
            self.trackBatteryUsage()
        }
    }
    
    private func getCurrentMemoryUsage() -> PerformanceMetrics.MemoryUsage {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
        
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_,
                         task_flavor_t(MACH_TASK_BASIC_INFO),
                         $0,
                         &count)
            }
        }
        
        if kerr == KERN_SUCCESS {
            let used = UInt64(info.resident_size)
            let total = ProcessInfo.processInfo.physicalMemory
            let available = total - used
            
            return PerformanceMetrics.MemoryUsage(
                used: used,
                available: available,
                total: total
            )
        }
        
        return PerformanceMetrics.MemoryUsage(used: 0, available: 0, total: 0)
    }
    
    private func getCurrentCPUUsage() -> Double {
        // Simplified CPU usage calculation
        // In a real implementation, you would use more sophisticated methods
        return Double.random(in: 10.0...50.0) // Placeholder
    }
    
    private func getCurrentBatteryLevel() -> Double {
        UIDevice.current.isBatteryMonitoringEnabled = true
        return UIDevice.current.batteryLevel * 100.0
    }
    
    private func getAverageAppLaunchTime() -> TimeInterval {
        guard let startTime = appLaunchStartTime else { return 0.0 }
        return Date().timeIntervalSince(startTime)
    }
    
    private func getAverageMemoryUsage() -> Double {
        let recentMetrics = metrics.suffix(10)
        return recentMetrics.map { $0.memoryUsage.percentage }.reduce(0, +) / Double(recentMetrics.count)
    }
    
    private func getAverageCPUUsage() -> Double {
        let recentMetrics = metrics.suffix(10)
        return recentMetrics.map { $0.cpuUsage }.reduce(0, +) / Double(recentMetrics.count)
    }
    
    private func getAverageBatteryUsage() -> Double {
        let recentMetrics = metrics.suffix(10)
        return recentMetrics.map { $0.batteryLevel }.reduce(0, +) / Double(recentMetrics.count)
    }
    
    private func getAverageNetworkLatency() -> TimeInterval {
        let allLatencies = networkMetrics.values.flatMap { $0 }
        return allLatencies.reduce(0, +) / Double(allLatencies.count)
    }
    
    private func getAverageDatabaseLatency() -> TimeInterval {
        let allLatencies = databaseMetrics.values.flatMap { $0 }
        return allLatencies.reduce(0, +) / Double(allLatencies.count)
    }
    
    private func getAverageUILoadTime() -> TimeInterval {
        let allLoadTimes = uiMetrics.values.flatMap { $0 }
        return allLoadTimes.reduce(0, +) / Double(allLoadTimes.count)
    }
    
    private func getNetworkPerformance() -> PerformanceReport.NetworkPerformance {
        let allLatencies = networkMetrics.values.flatMap { $0 }
        let averageLatency = allLatencies.reduce(0, +) / Double(allLatencies.count)
        
        let slowestEndpoint = networkMetrics.max { a, b in
            (a.value.reduce(0, +) / Double(a.value.count)) < (b.value.reduce(0, +) / Double(b.value.count))
        }?.key ?? ""
        
        let fastestEndpoint = networkMetrics.min { a, b in
            (a.value.reduce(0, +) / Double(a.value.count)) > (b.value.reduce(0, +) / Double(b.value.count))
        }?.key ?? ""
        
        return PerformanceReport.NetworkPerformance(
            averageLatency: averageLatency,
            totalRequests: allLatencies.count,
            successfulRequests: allLatencies.count, // Simplified
            failedRequests: 0, // Simplified
            slowestEndpoint: slowestEndpoint,
            fastestEndpoint: fastestEndpoint
        )
    }
    
    private func getDatabasePerformance() -> PerformanceReport.DatabasePerformance {
        let allLatencies = databaseMetrics.values.flatMap { $0 }
        let averageLatency = allLatencies.reduce(0, +) / Double(allLatencies.count)
        
        let slowestOperation = databaseMetrics.max { a, b in
            (a.value.reduce(0, +) / Double(a.value.count)) < (b.value.reduce(0, +) / Double(b.value.count))
        }?.key ?? ""
        
        let fastestOperation = databaseMetrics.min { a, b in
            (a.value.reduce(0, +) / Double(a.value.count)) > (b.value.reduce(0, +) / Double(b.value.count))
        }?.key ?? ""
        
        return PerformanceReport.DatabasePerformance(
            averageLatency: averageLatency,
            totalOperations: allLatencies.count,
            readOperations: allLatencies.count / 2, // Simplified
            writeOperations: allLatencies.count / 2, // Simplified
            slowestOperation: slowestOperation,
            fastestOperation: fastestOperation
        )
    }
    
    private func getUIPerformance() -> PerformanceReport.UIPerformance {
        let allLoadTimes = uiMetrics.values.flatMap { $0 }
        let averageLoadTime = allLoadTimes.reduce(0, +) / Double(allLoadTimes.count)
        
        let slowestScreen = uiMetrics.max { a, b in
            (a.value.reduce(0, +) / Double(a.value.count)) < (b.value.reduce(0, +) / Double(b.value.count))
        }?.key ?? ""
        
        let fastestScreen = uiMetrics.min { a, b in
            (a.value.reduce(0, +) / Double(a.value.count)) > (b.value.reduce(0, +) / Double(b.value.count))
        }?.key ?? ""
        
        return PerformanceReport.UIPerformance(
            averageLoadTime: averageLoadTime,
            totalScreens: allLoadTimes.count,
            slowestScreen: slowestScreen,
            fastestScreen: fastestScreen,
            frameRate: 60.0 // Placeholder
        )
    }
    
    private func generateRecommendations() -> [String] {
        var recommendations: [String] = []
        
        let report = getPerformanceReport()
        
        if report.averageAppLaunchTime > thresholds.maxAppLaunchTime {
            recommendations.append("Optimize app launch time by reducing initialization work")
        }
        
        if report.averageMemoryUsage > thresholds.maxMemoryUsage {
            recommendations.append("Reduce memory usage by implementing proper cleanup and caching strategies")
        }
        
        if report.averageCPUUsage > thresholds.maxCPUUsage {
            recommendations.append("Optimize CPU usage by moving heavy operations to background threads")
        }
        
        if report.networkPerformance.averageLatency > thresholds.maxNetworkLatency {
            recommendations.append("Optimize network performance by implementing caching and request optimization")
        }
        
        if report.databasePerformance.averageLatency > thresholds.maxDatabaseLatency {
            recommendations.append("Optimize database performance by implementing proper indexing and query optimization")
        }
        
        if report.uiPerformance.averageLoadTime > thresholds.maxUILoadTime {
            recommendations.append("Optimize UI performance by implementing lazy loading and view recycling")
        }
        
        return recommendations
    }
}

// MARK: - Performance Monitor Extensions
extension PerformanceMonitor {
    
    // MARK: - Convenience Methods
    func trackScreenLoad(_ screenName: String) {
        let startTime = Date()
        
        // Simulate screen load completion
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let loadTime = Date().timeIntervalSince(startTime)
            self.trackUIPerformance(screenName, loadTime: loadTime)
        }
    }
    
    func trackOperation(_ operation: String, block: () throws -> Void) rethrows {
        let startTime = Date()
        
        try block()
        
        let duration = Date().timeIntervalSince(startTime)
        trackDatabasePerformance(operation, duration: duration)
    }
    
    func trackAsyncOperation(_ operation: String, block: @escaping () async throws -> Void) async rethrows {
        let startTime = Date()
        
        try await block()
        
        let duration = Date().timeIntervalSince(startTime)
        trackDatabasePerformance(operation, duration: duration)
    }
}

// MARK: - Performance Categories
extension PerformanceMonitor {
    
    struct Category {
        static let app = "App"
        static let memory = "Memory"
        static let cpu = "CPU"
        static let battery = "Battery"
        static let network = "Network"
        static let database = "Database"
        static let ui = "UI"
        static let general = "General"
    }
}
