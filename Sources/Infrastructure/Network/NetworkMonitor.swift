import Foundation
import Network

/**
 * Network Monitor - Infrastructure Layer
 * 
 * Professional network monitoring system with connectivity tracking.
 * Provides network status monitoring, reachability detection, and connection quality metrics.
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

// MARK: - Network Monitor Implementation
class NetworkMonitor: NetworkMonitorProtocol {
    
    // MARK: - Properties
    static let shared = NetworkMonitor()
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "network.monitor", qos: .background)
    
    private var statusChangeHandlers: [(NetworkStatus) -> Void] = []
    private var typeChangeHandlers: [(NetworkType) -> Void] = []
    private var qualityChangeHandlers: [(NetworkQuality) -> Void] = []
    
    private var connectionHistory: [NetworkMetrics] = []
    private let maxHistorySize = 100
    
    private let analyticsService: AnalyticsServiceProtocol?
    private let logger: LoggerProtocol?
    
    // MARK: - Computed Properties
    var isConnected: Bool {
        return currentStatus == .connected
    }
    
    var currentStatus: NetworkStatus {
        return monitor.currentPath.status == .satisfied ? .connected : .disconnected
    }
    
    var currentType: NetworkType {
        let path = monitor.currentPath
        if path.usesInterfaceType(.wifi) {
            return .wifi
        } else if path.usesInterfaceType(.cellular) {
            return .cellular
        } else if path.usesInterfaceType(.wiredEthernet) {
            return .ethernet
        } else {
            return .unknown
        }
    }
    
    var currentQuality: NetworkQuality {
        // Simplified quality assessment based on interface type
        switch currentType {
        case .wifi:
            return .excellent
        case .cellular:
            return .good
        case .ethernet:
            return .excellent
        case .unknown:
            return .unknown
        }
    }
    
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
        monitor.pathUpdateHandler = { [weak self] path in
            self?.handlePathUpdate(path)
        }
        
        monitor.start(queue: queue)
        
        logger?.info("Network monitoring started", category: "Network", file: #file, function: #function, line: #line)
    }
    
    func stopMonitoring() {
        monitor.cancel()
        
        logger?.info("Network monitoring stopped", category: "Network", file: #file, function: #function, line: #line)
    }
    
    func getCurrentMetrics() -> NetworkMetrics {
        let metrics = NetworkMetrics(
            status: currentStatus,
            type: currentType,
            quality: currentQuality,
            latency: measureCurrentLatency(),
            bandwidth: estimateCurrentBandwidth(),
            packetLoss: estimatePacketLoss(),
            timestamp: Date()
        )
        
        // Add to history
        connectionHistory.append(metrics)
        if connectionHistory.count > maxHistorySize {
            connectionHistory.removeFirst()
        }
        
        return metrics
    }
    
    func getConnectionHistory() -> [NetworkMetrics] {
        return connectionHistory
    }
    
    func isReachable(_ host: String) async -> Bool {
        let url = URL(string: "https://\(host)")!
        
        do {
            let (_, response) = try await URLSession.shared.data(from: url)
            return (response as? HTTPURLResponse)?.statusCode == 200
        } catch {
            return false
        }
    }
    
    func measureLatency(to host: String) async -> TimeInterval {
        let url = URL(string: "https://\(host)")!
        let startTime = Date()
        
        do {
            let (_, _) = try await URLSession.shared.data(from: url)
            return Date().timeIntervalSince(startTime)
        } catch {
            return -1.0 // Indicates failure
        }
    }
    
    func measureBandwidth() async -> Double {
        // Simplified bandwidth measurement
        // In a real implementation, you would perform actual bandwidth tests
        switch currentType {
        case .wifi:
            return Double.random(in: 50.0...200.0) // Mbps
        case .cellular:
            return Double.random(in: 10.0...50.0) // Mbps
        case .ethernet:
            return Double.random(in: 100.0...1000.0) // Mbps
        case .unknown:
            return 0.0
        }
    }
    
    func onStatusChange(_ handler: @escaping (NetworkStatus) -> Void) {
        statusChangeHandlers.append(handler)
    }
    
    func onTypeChange(_ handler: @escaping (NetworkType) -> Void) {
        typeChangeHandlers.append(handler)
    }
    
    func onQualityChange(_ handler: @escaping (NetworkQuality) -> Void) {
        qualityChangeHandlers.append(handler)
    }
    
    // MARK: - Private Methods
    private func handlePathUpdate(_ path: NWPath) {
        let newStatus = path.status == .satisfied ? NetworkStatus.connected : NetworkStatus.disconnected
        let newType = getNetworkType(from: path)
        let newQuality = getNetworkQuality(for: newType)
        
        // Check for status change
        if newStatus != currentStatus {
            logger?.logNetworkStatusChange(newStatus == .connected)
            
            analyticsService?.trackEvent("network_status_changed", parameters: [
                "status": newStatus.description,
                "previous_status": currentStatus.description
            ])
            
            // Notify handlers
            for handler in statusChangeHandlers {
                handler(newStatus)
            }
        }
        
        // Check for type change
        if newType != currentType {
            logger?.info("Network type changed to: \(newType.description)", category: "Network", file: #file, function: #function, line: #line)
            
            analyticsService?.trackEvent("network_type_changed", parameters: [
                "type": newType.description,
                "previous_type": currentType.description
            ])
            
            // Notify handlers
            for handler in typeChangeHandlers {
                handler(newType)
            }
        }
        
        // Check for quality change
        if newQuality != currentQuality {
            logger?.info("Network quality changed to: \(newQuality.description)", category: "Network", file: #file, function: #function, line: #line)
            
            analyticsService?.trackEvent("network_quality_changed", parameters: [
                "quality": newQuality.description,
                "previous_quality": currentQuality.description
            ])
            
            // Notify handlers
            for handler in qualityChangeHandlers {
                handler(newQuality)
            }
        }
        
        // Update metrics
        let metrics = getCurrentMetrics()
        connectionHistory.append(metrics)
        
        if connectionHistory.count > maxHistorySize {
            connectionHistory.removeFirst()
        }
    }
    
    private func getNetworkType(from path: NWPath) -> NetworkType {
        if path.usesInterfaceType(.wifi) {
            return .wifi
        } else if path.usesInterfaceType(.cellular) {
            return .cellular
        } else if path.usesInterfaceType(.wiredEthernet) {
            return .ethernet
        } else {
            return .unknown
        }
    }
    
    private func getNetworkQuality(for type: NetworkType) -> NetworkQuality {
        switch type {
        case .wifi:
            return .excellent
        case .cellular:
            return .good
        case .ethernet:
            return .excellent
        case .unknown:
            return .unknown
        }
    }
    
    private func measureCurrentLatency() -> TimeInterval {
        // Simplified latency measurement
        // In a real implementation, you would measure actual latency
        switch currentType {
        case .wifi:
            return Double.random(in: 0.01...0.05) // seconds
        case .cellular:
            return Double.random(in: 0.05...0.15) // seconds
        case .ethernet:
            return Double.random(in: 0.001...0.01) // seconds
        case .unknown:
            return 0.0
        }
    }
    
    private func estimateCurrentBandwidth() -> Double {
        // Simplified bandwidth estimation
        switch currentType {
        case .wifi:
            return Double.random(in: 50.0...200.0) // Mbps
        case .cellular:
            return Double.random(in: 10.0...50.0) // Mbps
        case .ethernet:
            return Double.random(in: 100.0...1000.0) // Mbps
        case .unknown:
            return 0.0
        }
    }
    
    private func estimatePacketLoss() -> Double {
        // Simplified packet loss estimation
        // In a real implementation, you would measure actual packet loss
        return Double.random(in: 0.0...2.0) // percentage
    }
}

// MARK: - Network Monitor Extensions
extension NetworkMonitor {
    
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
            "is_connected": isConnected,
            "latency": measureCurrentLatency(),
            "bandwidth": estimateCurrentBandwidth(),
            "packet_loss": estimatePacketLoss()
        ]
    }
    
    func logNetworkInfo() {
        let info = getNetworkInfo()
        logger?.info("Network Info: \(info)", category: "Network", file: #file, function: #function, line: #line)
    }
}

// MARK: - Network Monitor Categories
extension NetworkMonitor {
    
    struct Category {
        static let network = "Network"
        static let connectivity = "Connectivity"
        static let performance = "Performance"
        static let monitoring = "Monitoring"
    }
}

// MARK: - Network Utilities
extension NetworkMonitor {
    
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