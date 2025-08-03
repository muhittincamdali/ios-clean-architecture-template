import Foundation

/**
 * Network Monitor Protocol - Infrastructure Layer
 * 
 * Abstract interface for network monitoring operations.
 * Defines the contract for network monitoring implementations.
 * 
 * - Author: iOS Clean Architecture Team
 * - Version: 2.0.0
 * - Date: 2024-01-15
 */

// MARK: - Network Status
enum NetworkStatus {
    case connected
    case disconnected
    case connecting
    case unknown
    
    var description: String {
        switch self {
        case .connected:
            return "Connected"
        case .disconnected:
            return "Disconnected"
        case .connecting:
            return "Connecting"
        case .unknown:
            return "Unknown"
        }
    }
}

// MARK: - Network Type
enum NetworkType {
    case wifi
    case cellular
    case ethernet
    case unknown
    
    var description: String {
        switch self {
        case .wifi:
            return "WiFi"
        case .cellular:
            return "Cellular"
        case .ethernet:
            return "Ethernet"
        case .unknown:
            return "Unknown"
        }
    }
}

// MARK: - Network Quality
enum NetworkQuality {
    case excellent
    case good
    case fair
    case poor
    case unknown
    
    var description: String {
        switch self {
        case .excellent:
            return "Excellent"
        case .good:
            return "Good"
        case .fair:
            return "Fair"
        case .poor:
            return "Poor"
        case .unknown:
            return "Unknown"
        }
    }
    
    var color: String {
        switch self {
        case .excellent:
            return "green"
        case .good:
            return "blue"
        case .fair:
            return "yellow"
        case .poor:
            return "red"
        case .unknown:
            return "gray"
        }
    }
}

// MARK: - Network Metrics
struct NetworkMetrics {
    let status: NetworkStatus
    let type: NetworkType
    let quality: NetworkQuality
    let latency: TimeInterval
    let bandwidth: Double // Mbps
    let packetLoss: Double // Percentage
    let timestamp: Date
}

// MARK: - Network Monitor Protocol
protocol NetworkMonitorProtocol {
    var isConnected: Bool { get }
    var currentStatus: NetworkStatus { get }
    var currentType: NetworkType { get }
    var currentQuality: NetworkQuality { get }
    
    func startMonitoring()
    func stopMonitoring()
    func getCurrentMetrics() -> NetworkMetrics
    func getConnectionHistory() -> [NetworkMetrics]
    func isReachable(_ host: String) async -> Bool
    func measureLatency(to host: String) async -> TimeInterval
    func measureBandwidth() async -> Double
    func onStatusChange(_ handler: @escaping (NetworkStatus) -> Void)
    func onTypeChange(_ handler: @escaping (NetworkType) -> Void)
    func onQualityChange(_ handler: @escaping (NetworkQuality) -> Void)
}

// MARK: - Network Monitor Error
enum NetworkMonitorError: LocalizedError {
    case monitoringFailed(String)
    case reachabilityCheckFailed(String)
    case latencyMeasurementFailed(String)
    case bandwidthMeasurementFailed(String)
    case configurationError(String)
    case permissionDenied(String)
    case unknown(String)
    
    var errorDescription: String? {
        switch self {
        case .monitoringFailed(let message):
            return "Network monitoring failed: \(message)"
        case .reachabilityCheckFailed(let message):
            return "Reachability check failed: \(message)"
        case .latencyMeasurementFailed(let message):
            return "Latency measurement failed: \(message)"
        case .bandwidthMeasurementFailed(let message):
            return "Bandwidth measurement failed: \(message)"
        case .configurationError(let message):
            return "Network monitor configuration error: \(message)"
        case .permissionDenied(let message):
            return "Network monitor permission denied: \(message)"
        case .unknown(let message):
            return "Unknown network monitor error: \(message)"
        }
    }
    
    var errorCode: Int {
        switch self {
        case .monitoringFailed:
            return 7001
        case .reachabilityCheckFailed:
            return 7002
        case .latencyMeasurementFailed:
            return 7003
        case .bandwidthMeasurementFailed:
            return 7004
        case .configurationError:
            return 7005
        case .permissionDenied:
            return 7006
        case .unknown:
            return 7099
        }
    }
}

// MARK: - Network Monitor Configuration
struct NetworkMonitorConfiguration {
    let enabled: Bool
    let checkInterval: TimeInterval
    let timeout: TimeInterval
    let maxRetryCount: Int
    let retryDelay: TimeInterval
    let trackHistory: Bool
    let maxHistorySize: Int
    let qualityThresholds: NetworkQualityThresholds
    
    struct NetworkQualityThresholds {
        let excellentLatency: TimeInterval
        let goodLatency: TimeInterval
        let fairLatency: TimeInterval
        let excellentBandwidth: Double
        let goodBandwidth: Double
        let fairBandwidth: Double
        
        init(
            excellentLatency: TimeInterval = 0.05,
            goodLatency: TimeInterval = 0.1,
            fairLatency: TimeInterval = 0.2,
            excellentBandwidth: Double = 100.0,
            goodBandwidth: Double = 50.0,
            fairBandwidth: Double = 10.0
        ) {
            self.excellentLatency = excellentLatency
            self.goodLatency = goodLatency
            self.fairLatency = fairLatency
            self.excellentBandwidth = excellentBandwidth
            self.goodBandwidth = goodBandwidth
            self.fairBandwidth = fairBandwidth
        }
    }
    
    init(
        enabled: Bool = true,
        checkInterval: TimeInterval = 30.0,
        timeout: TimeInterval = 10.0,
        maxRetryCount: Int = 3,
        retryDelay: TimeInterval = 1.0,
        trackHistory: Bool = true,
        maxHistorySize: Int = 100,
        qualityThresholds: NetworkQualityThresholds = NetworkQualityThresholds()
    ) {
        self.enabled = enabled
        self.checkInterval = checkInterval
        self.timeout = timeout
        self.maxRetryCount = maxRetryCount
        self.retryDelay = retryDelay
        self.trackHistory = trackHistory
        self.maxHistorySize = maxHistorySize
        self.qualityThresholds = qualityThresholds
    }
}

// MARK: - Network Monitor Statistics
struct NetworkMonitorStatistics {
    let totalChecks: Int
    let successfulChecks: Int
    let failedChecks: Int
    let averageLatency: TimeInterval
    let averageBandwidth: Double
    let connectionUptime: TimeInterval
    let lastCheckTime: Date?
    let timestamp: Date
    
    init(
        totalChecks: Int = 0,
        successfulChecks: Int = 0,
        failedChecks: Int = 0,
        averageLatency: TimeInterval = 0,
        averageBandwidth: Double = 0,
        connectionUptime: TimeInterval = 0,
        lastCheckTime: Date? = nil
    ) {
        self.totalChecks = totalChecks
        self.successfulChecks = successfulChecks
        self.failedChecks = failedChecks
        self.averageLatency = averageLatency
        self.averageBandwidth = averageBandwidth
        self.connectionUptime = connectionUptime
        self.lastCheckTime = lastCheckTime
        self.timestamp = Date()
    }
}

// MARK: - Network Monitor Extensions
extension NetworkMonitorProtocol {
    
    // MARK: - Convenience Methods
    func isWifiConnected() -> Bool {
        return currentType == .wifi && isConnected
    }
    
    func isCellularConnected() -> Bool {
        return currentType == .cellular && isConnected
    }
    
    func isEthernetConnected() -> Bool {
        return currentType == .ethernet && isConnected
    }
    
    func getConnectionTypeDescription() -> String {
        return "\(currentType.description) (\(currentQuality.description))"
    }
    
    func getNetworkInfo() -> [String: Any] {
        return [
            "status": currentStatus.description,
            "type": currentType.description,
            "quality": currentQuality.description,
            "is_connected": isConnected
        ]
    }
    
    func logNetworkInfo() {
        let info = getNetworkInfo()
        // This would typically use a logger
        print("Network Info: \(info)")
    }
}

// MARK: - Network Monitor Categories
extension NetworkMonitorProtocol {
    
    struct Category {
        static let network = "Network"
        static let connectivity = "Connectivity"
        static let performance = "Performance"
        static let monitoring = "Monitoring"
    }
}

// MARK: - Network Utilities
extension NetworkMonitorProtocol {
    
    struct Utilities {
        
        static func formatBandwidth(_ bandwidth: Double) -> String {
            if bandwidth >= 1000.0 {
                return String(format: "%.1f Gbps", bandwidth / 1000.0)
            } else {
                return String(format: "%.1f Mbps", bandwidth)
            }
        }
        
        static func formatLatency(_ latency: TimeInterval) -> String {
            if latency < 0.001 {
                return String(format: "%.0f μs", latency * 1000000)
            } else if latency < 1.0 {
                return String(format: "%.1f ms", latency * 1000)
            } else {
                return String(format: "%.2f s", latency)
            }
        }
        
        static func formatPacketLoss(_ packetLoss: Double) -> String {
            return String(format: "%.2f%%", packetLoss)
        }
        
        static func getQualityColor(_ quality: NetworkQuality) -> String {
            return quality.color
        }
        
        static func getQualityIcon(_ quality: NetworkQuality) -> String {
            switch quality {
            case .excellent:
                return "🟢"
            case .good:
                return "🔵"
            case .fair:
                return "🟡"
            case .poor:
                return "🔴"
            case .unknown:
                return "⚪"
            }
        }
    }
} 