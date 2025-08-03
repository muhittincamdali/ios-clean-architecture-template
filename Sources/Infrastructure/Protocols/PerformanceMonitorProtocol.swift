import Foundation

/**
 * Performance Monitor Protocol - Infrastructure Layer
 * 
 * Abstract interface for performance monitoring operations.
 * Defines the contract for performance monitoring implementations.
 * 
 * - Author: iOS Clean Architecture Team
 * - Version: 2.0.0
 * - Date: 2024-01-15
 */

// MARK: - Performance Metric Type
enum PerformanceMetricType {
    case appLaunch
    case screenLoad
    case networkCall
    case databaseOperation
    case cacheOperation
    case memoryUsage
    case cpuUsage
    case batteryUsage
    case frameRate
    case custom(String)
    
    var description: String {
        switch self {
        case .appLaunch:
            return "App Launch"
        case .screenLoad:
            return "Screen Load"
        case .networkCall:
            return "Network Call"
        case .databaseOperation:
            return "Database Operation"
        case .cacheOperation:
            return "Cache Operation"
        case .memoryUsage:
            return "Memory Usage"
        case .cpuUsage:
            return "CPU Usage"
        case .batteryUsage:
            return "Battery Usage"
        case .frameRate:
            return "Frame Rate"
        case .custom(let name):
            return "Custom: \(name)"
        }
    }
}

// MARK: - Performance Metric
struct PerformanceMetric {
    let type: PerformanceMetricType
    let value: Double
    let unit: String
    let timestamp: Date
    let context: [String: Any]
    let threshold: Double?
    
    init(type: PerformanceMetricType, value: Double, unit: String, context: [String: Any] = [:], threshold: Double? = nil) {
        self.type = type
        self.value = value
        self.unit = unit
        self.timestamp = Date()
        self.context = context
        self.threshold = threshold
    }
    
    var isOverThreshold: Bool {
        guard let threshold = threshold else { return false }
        return value > threshold
    }
}

// MARK: - Performance Report
struct PerformanceReport {
    let metrics: [PerformanceMetric]
    let summary: PerformanceSummary
    let recommendations: [String]
    let timestamp: Date
    
    init(metrics: [PerformanceMetric], summary: PerformanceSummary, recommendations: [String] = []) {
        self.metrics = metrics
        self.summary = summary
        self.recommendations = recommendations
        self.timestamp = Date()
    }
}

// MARK: - Performance Summary
struct PerformanceSummary {
    let averageAppLaunchTime: TimeInterval
    let averageScreenLoadTime: TimeInterval
    let averageNetworkCallTime: TimeInterval
    let averageDatabaseOperationTime: TimeInterval
    let averageMemoryUsage: Double
    let averageCpuUsage: Double
    let averageFrameRate: Double
    let totalMetrics: Int
    let overThresholdCount: Int
    let timestamp: Date
    
    init(
        averageAppLaunchTime: TimeInterval = 0,
        averageScreenLoadTime: TimeInterval = 0,
        averageNetworkCallTime: TimeInterval = 0,
        averageDatabaseOperationTime: TimeInterval = 0,
        averageMemoryUsage: Double = 0,
        averageCpuUsage: Double = 0,
        averageFrameRate: Double = 0,
        totalMetrics: Int = 0,
        overThresholdCount: Int = 0
    ) {
        self.averageAppLaunchTime = averageAppLaunchTime
        self.averageScreenLoadTime = averageScreenLoadTime
        self.averageNetworkCallTime = averageNetworkCallTime
        self.averageDatabaseOperationTime = averageDatabaseOperationTime
        self.averageMemoryUsage = averageMemoryUsage
        self.averageCpuUsage = averageCpuUsage
        self.averageFrameRate = averageFrameRate
        self.totalMetrics = totalMetrics
        self.overThresholdCount = overThresholdCount
        self.timestamp = Date()
    }
}

// MARK: - Performance Monitor Protocol
protocol PerformanceMonitorProtocol {
    func startMonitoring()
    func stopMonitoring()
    func trackMetric(_ metric: PerformanceMetric)
    func trackAppLaunch(duration: TimeInterval)
    func trackScreenLoad(screenName: String, duration: TimeInterval)
    func trackNetworkCall(endpoint: String, duration: TimeInterval)
    func trackDatabaseOperation(operation: String, duration: TimeInterval)
    func trackCacheOperation(operation: String, duration: TimeInterval)
    func trackMemoryUsage(usage: Double)
    func trackCpuUsage(usage: Double)
    func trackBatteryUsage(usage: Double)
    func trackFrameRate(fps: Double)
    func getCurrentMetrics() -> [PerformanceMetric]
    func getPerformanceReport() -> PerformanceReport
    func setThreshold(for metricType: PerformanceMetricType, threshold: Double)
    func enableMonitoring(_ enabled: Bool)
}

// MARK: - Performance Monitor Error
enum PerformanceMonitorError: LocalizedError {
    case monitoringFailed(String)
    case metricTrackingFailed(String)
    case reportGenerationFailed(String)
    case configurationError(String)
    case permissionDenied(String)
    case unknown(String)
    
    var errorDescription: String? {
        switch self {
        case .monitoringFailed(let message):
            return "Performance monitoring failed: \(message)"
        case .metricTrackingFailed(let message):
            return "Metric tracking failed: \(message)"
        case .reportGenerationFailed(let message):
            return "Report generation failed: \(message)"
        case .configurationError(let message):
            return "Performance monitor configuration error: \(message)"
        case .permissionDenied(let message):
            return "Performance monitor permission denied: \(message)"
        case .unknown(let message):
            return "Unknown performance monitor error: \(message)"
        }
    }
    
    var errorCode: Int {
        switch self {
        case .monitoringFailed:
            return 10001
        case .metricTrackingFailed:
            return 10002
        case .reportGenerationFailed:
            return 10003
        case .configurationError:
            return 10004
        case .permissionDenied:
            return 10005
        case .unknown:
            return 10099
        }
    }
}

// MARK: - Performance Monitor Configuration
struct PerformanceMonitorConfiguration {
    let enabled: Bool
    let trackAppLaunch: Bool
    let trackScreenLoad: Bool
    let trackNetworkCalls: Bool
    let trackDatabaseOperations: Bool
    let trackCacheOperations: Bool
    let trackMemoryUsage: Bool
    let trackCpuUsage: Bool
    let trackBatteryUsage: Bool
    let trackFrameRate: Bool
    let samplingInterval: TimeInterval
    let maxMetricsHistory: Int
    let thresholds: [PerformanceMetricType: Double]
    
    init(
        enabled: Bool = true,
        trackAppLaunch: Bool = true,
        trackScreenLoad: Bool = true,
        trackNetworkCalls: Bool = true,
        trackDatabaseOperations: Bool = true,
        trackCacheOperations: Bool = true,
        trackMemoryUsage: Bool = true,
        trackCpuUsage: Bool = true,
        trackBatteryUsage: Bool = true,
        trackFrameRate: Bool = true,
        samplingInterval: TimeInterval = 1.0,
        maxMetricsHistory: Int = 1000,
        thresholds: [PerformanceMetricType: Double] = [:]
    ) {
        self.enabled = enabled
        self.trackAppLaunch = trackAppLaunch
        self.trackScreenLoad = trackScreenLoad
        self.trackNetworkCalls = trackNetworkCalls
        self.trackDatabaseOperations = trackDatabaseOperations
        self.trackCacheOperations = trackCacheOperations
        self.trackMemoryUsage = trackMemoryUsage
        self.trackCpuUsage = trackCpuUsage
        self.trackBatteryUsage = trackBatteryUsage
        self.trackFrameRate = trackFrameRate
        self.samplingInterval = samplingInterval
        self.maxMetricsHistory = maxMetricsHistory
        self.thresholds = thresholds
    }
}

// MARK: - Performance Monitor Statistics
struct PerformanceMonitorStatistics {
    let totalMetrics: Int
    let metricsByType: [PerformanceMetricType: Int]
    let averageValues: [PerformanceMetricType: Double]
    let overThresholdCount: Int
    let lastMetricTime: Date?
    let timestamp: Date
    
    init(
        totalMetrics: Int = 0,
        metricsByType: [PerformanceMetricType: Int] = [:],
        averageValues: [PerformanceMetricType: Double] = [:],
        overThresholdCount: Int = 0,
        lastMetricTime: Date? = nil
    ) {
        self.totalMetrics = totalMetrics
        self.metricsByType = metricsByType
        self.averageValues = averageValues
        self.overThresholdCount = overThresholdCount
        self.lastMetricTime = lastMetricTime
        self.timestamp = Date()
    }
}

// MARK: - Performance Monitor Extensions
extension PerformanceMonitorProtocol {
    
    // MARK: - Convenience Methods
    func trackCustomMetric(name: String, value: Double, unit: String, context: [String: Any] = [:], threshold: Double? = nil) {
        let metric = PerformanceMetric(
            type: .custom(name),
            value: value,
            unit: unit,
            context: context,
            threshold: threshold
        )
        trackMetric(metric)
    }
    
    func trackOperation<T>(_ operation: String, block: () throws -> T) rethrows -> T {
        let startTime = Date()
        let result = try block()
        let duration = Date().timeIntervalSince(startTime)
        
        trackCustomMetric(
            name: operation,
            value: duration,
            unit: "seconds",
            context: ["operation": operation]
        )
        
        return result
    }
    
    func trackAsyncOperation<T>(_ operation: String, block: () async throws -> T) async rethrows -> T {
        let startTime = Date()
        let result = try await block()
        let duration = Date().timeIntervalSince(startTime)
        
        trackCustomMetric(
            name: operation,
            value: duration,
            unit: "seconds",
            context: ["operation": operation]
        )
        
        return result
    }
    
    func getAverageValue(for metricType: PerformanceMetricType) -> Double {
        let metrics = getCurrentMetrics().filter { $0.type == metricType }
        guard !metrics.isEmpty else { return 0.0 }
        
        let total = metrics.reduce(0.0) { $0 + $1.value }
        return total / Double(metrics.count)
    }
    
    func getMetricsCount(for metricType: PerformanceMetricType) -> Int {
        return getCurrentMetrics().filter { $0.type == metricType }.count
    }
    
    func getOverThresholdMetrics() -> [PerformanceMetric] {
        return getCurrentMetrics().filter { $0.isOverThreshold }
    }
    
    func getMetricsInTimeRange(from startDate: Date, to endDate: Date) -> [PerformanceMetric] {
        return getCurrentMetrics().filter { metric in
            metric.timestamp >= startDate && metric.timestamp <= endDate
        }
    }
    
    func getMetricsForLastMinutes(_ minutes: Int) -> [PerformanceMetric] {
        let startDate = Date().addingTimeInterval(-TimeInterval(minutes * 60))
        return getMetricsInTimeRange(from: startDate, to: Date())
    }
    
    func getMetricsForLastHours(_ hours: Int) -> [PerformanceMetric] {
        let startDate = Date().addingTimeInterval(-TimeInterval(hours * 3600))
        return getMetricsInTimeRange(from: startDate, to: Date())
    }
    
    func getMetricsForLastDays(_ days: Int) -> [PerformanceMetric] {
        let startDate = Date().addingTimeInterval(-TimeInterval(days * 24 * 3600))
        return getMetricsInTimeRange(from: startDate, to: Date())
    }
    
    func clearMetrics() {
        // This would need to be implemented based on the specific performance monitor implementation
    }
    
    func exportMetrics() -> Data? {
        let metrics = getCurrentMetrics()
        return try? JSONEncoder().encode(metrics)
    }
    
    func importMetrics(from data: Data) throws {
        let metrics = try JSONDecoder().decode([PerformanceMetric].self, from: data)
        for metric in metrics {
            trackMetric(metric)
        }
    }
}

// MARK: - Performance Monitor Categories
extension PerformanceMonitorProtocol {
    
    struct Category {
        static let performance = "Performance"
        static let monitoring = "Monitoring"
        static let metrics = "Metrics"
        static let analysis = "Analysis"
    }
} 