import Foundation

/**
 * Analytics Service Protocol - Infrastructure Layer
 * 
 * Abstract interface for analytics operations.
 * Defines the contract for analytics service implementations.
 * 
 * - Author: iOS Clean Architecture Team
 * - Version: 2.0.0
 * - Date: 2024-01-15
 */

// MARK: - Analytics Service Protocol
protocol AnalyticsServiceProtocol {
    func trackEvent(_ event: String, parameters: [String: Any]?)
    func trackScreen(_ screenName: String, parameters: [String: Any]?)
    func trackUserProperty(_ property: String, value: Any)
    func trackError(_ error: Error, context: String)
    func trackPerformance(_ operation: String, duration: TimeInterval)
    func trackConversion(_ event: String, value: Double)
    func setUserID(_ userID: String)
    func setUserProperties(_ properties: [String: Any])
    func enableAnalytics(_ enabled: Bool)
    func flushEvents()
}

// MARK: - Analytics Event
struct AnalyticsEvent {
    let name: String
    let parameters: [String: Any]
    let timestamp: Date
    let sessionID: String
    let userID: String?
    
    init(name: String, parameters: [String: Any]? = nil, userID: String? = nil) {
        self.name = name
        self.parameters = parameters ?? [:]
        self.timestamp = Date()
        self.sessionID = AnalyticsService.shared.sessionID
        self.userID = userID
    }
}

// MARK: - Analytics Provider Protocol
protocol AnalyticsProviderProtocol {
    func trackEvent(_ event: AnalyticsEvent)
    func trackScreen(_ screenName: String, parameters: [String: Any]?)
    func trackUserProperty(_ property: String, value: Any)
    func setUserID(_ userID: String)
    func enableTracking(_ enabled: Bool)
    func flushEvents()
}

// MARK: - Analytics Error
enum AnalyticsError: LocalizedError {
    case invalidEvent(String)
    case invalidParameter(String)
    case networkError(String)
    case serverError(String)
    case rateLimitExceeded
    case authenticationError(String)
    case configurationError(String)
    case unknown(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidEvent(let message):
            return "Invalid analytics event: \(message)"
        case .invalidParameter(let message):
            return "Invalid analytics parameter: \(message)"
        case .networkError(let message):
            return "Analytics network error: \(message)"
        case .serverError(let message):
            return "Analytics server error: \(message)"
        case .rateLimitExceeded:
            return "Analytics rate limit exceeded"
        case .authenticationError(let message):
            return "Analytics authentication error: \(message)"
        case .configurationError(let message):
            return "Analytics configuration error: \(message)"
        case .unknown(let message):
            return "Unknown analytics error: \(message)"
        }
    }
    
    var errorCode: Int {
        switch self {
        case .invalidEvent:
            return 5001
        case .invalidParameter:
            return 5002
        case .networkError:
            return 5003
        case .serverError:
            return 5004
        case .rateLimitExceeded:
            return 5005
        case .authenticationError:
            return 5006
        case .configurationError:
            return 5007
        case .unknown:
            return 5099
        }
    }
}

// MARK: - Analytics Configuration
struct AnalyticsConfiguration {
    let enabled: Bool
    let debugMode: Bool
    let batchSize: Int
    let flushInterval: TimeInterval
    let maxQueueSize: Int
    let sessionTimeout: TimeInterval
    let trackScreenViews: Bool
    let trackUserActions: Bool
    let trackPerformance: Bool
    let trackErrors: Bool
    let trackConversions: Bool
    
    init(
        enabled: Bool = true,
        debugMode: Bool = false,
        batchSize: Int = 20,
        flushInterval: TimeInterval = 30.0,
        maxQueueSize: Int = 1000,
        sessionTimeout: TimeInterval = 1800.0, // 30 minutes
        trackScreenViews: Bool = true,
        trackUserActions: Bool = true,
        trackPerformance: Bool = true,
        trackErrors: Bool = true,
        trackConversions: Bool = true
    ) {
        self.enabled = enabled
        self.debugMode = debugMode
        self.batchSize = batchSize
        self.flushInterval = flushInterval
        self.maxQueueSize = maxQueueSize
        self.sessionTimeout = sessionTimeout
        self.trackScreenViews = trackScreenViews
        self.trackUserActions = trackUserActions
        self.trackPerformance = trackPerformance
        self.trackErrors = trackErrors
        self.trackConversions = trackConversions
    }
}

// MARK: - Analytics Statistics
struct AnalyticsStatistics {
    let totalEvents: Int
    let successfulEvents: Int
    let failedEvents: Int
    let averageEventSize: Int
    let lastFlushTime: Date?
    let queueSize: Int
    let sessionCount: Int
    let userCount: Int
    let timestamp: Date
    
    init(
        totalEvents: Int = 0,
        successfulEvents: Int = 0,
        failedEvents: Int = 0,
        averageEventSize: Int = 0,
        lastFlushTime: Date? = nil,
        queueSize: Int = 0,
        sessionCount: Int = 0,
        userCount: Int = 0
    ) {
        self.totalEvents = totalEvents
        self.successfulEvents = successfulEvents
        self.failedEvents = failedEvents
        self.averageEventSize = averageEventSize
        self.lastFlushTime = lastFlushTime
        self.queueSize = queueSize
        self.sessionCount = sessionCount
        self.userCount = userCount
        self.timestamp = Date()
    }
}

// MARK: - Analytics Service Extensions
extension AnalyticsServiceProtocol {
    
    // MARK: - Convenience Methods
    func trackAppLaunch() {
        trackEvent("app_launch", parameters: nil)
    }
    
    func trackAppBackground() {
        trackEvent("app_background", parameters: nil)
    }
    
    func trackAppForeground() {
        trackEvent("app_foreground", parameters: nil)
    }
    
    func trackButtonTap(_ buttonName: String, screen: String) {
        let parameters: [String: Any] = [
            "button_name": buttonName,
            "screen": screen
        ]
        trackEvent("button_tap", parameters: parameters)
    }
    
    func trackFeatureUsage(_ featureName: String, parameters: [String: Any]? = nil) {
        var eventParameters = parameters ?? [:]
        eventParameters["feature_name"] = featureName
        trackEvent("feature_usage", parameters: eventParameters)
    }
    
    func trackError(_ error: Error, screen: String, action: String? = nil) {
        var parameters: [String: Any] = [
            "screen": screen,
            "error_description": error.localizedDescription,
            "error_domain": (error as NSError).domain,
            "error_code": (error as NSError).code
        ]
        
        if let action = action {
            parameters["action"] = action
        }
        
        trackEvent("error_occurred", parameters: parameters)
    }
    
    func trackNetworkCall(_ endpoint: String, method: String, statusCode: Int, duration: TimeInterval) {
        let parameters: [String: Any] = [
            "endpoint": endpoint,
            "method": method,
            "status_code": statusCode,
            "duration": duration,
            "success": statusCode >= 200 && statusCode < 300
        ]
        
        trackEvent("network_call", parameters: parameters)
    }
    
    func trackDatabaseOperation(_ operation: String, table: String, duration: TimeInterval) {
        let parameters: [String: Any] = [
            "operation": operation,
            "table": table,
            "duration": duration
        ]
        
        trackEvent("database_operation", parameters: parameters)
    }
    
    func trackCacheOperation(_ operation: String, key: String, success: Bool) {
        let parameters: [String: Any] = [
            "operation": operation,
            "key": key,
            "success": success
        ]
        
        trackEvent("cache_operation", parameters: parameters)
    }
    
    func trackUserAction(_ action: String, screen: String, parameters: [String: Any]? = nil) {
        var eventParameters = parameters ?? [:]
        eventParameters["action"] = action
        eventParameters["screen"] = screen
        
        trackEvent("user_action", parameters: eventParameters)
    }
    
    func trackPurchase(_ productID: String, price: Double, currency: String = "USD") {
        let parameters: [String: Any] = [
            "product_id": productID,
            "price": price,
            "currency": currency
        ]
        
        trackEvent("purchase", parameters: parameters)
        trackConversion("purchase", value: price)
    }
    
    func trackSubscription(_ planName: String, price: Double, currency: String = "USD") {
        let parameters: [String: Any] = [
            "plan_name": planName,
            "price": price,
            "currency": currency
        ]
        
        trackEvent("subscription", parameters: parameters)
        trackConversion("subscription", value: price)
    }
}

// MARK: - Analytics Categories
extension AnalyticsServiceProtocol {
    
    struct Category {
        static let app = "App"
        static let user = "User"
        static let feature = "Feature"
        static let error = "Error"
        static let performance = "Performance"
        static let network = "Network"
        static let database = "Database"
        static let cache = "Cache"
        static let purchase = "Purchase"
        static let conversion = "Conversion"
    }
    
    struct Event {
        static let appLaunch = "app_launch"
        static let appBackground = "app_background"
        static let appForeground = "app_foreground"
        static let buttonTap = "button_tap"
        static let featureUsage = "feature_usage"
        static let errorOccurred = "error_occurred"
        static let networkCall = "network_call"
        static let databaseOperation = "database_operation"
        static let cacheOperation = "cache_operation"
        static let userAction = "user_action"
        static let purchase = "purchase"
        static let subscription = "subscription"
        static let screenView = "screen_view"
        static let userIdentified = "user_identified"
        static let userPropertiesUpdated = "user_properties_updated"
        static let analyticsEnabled = "analytics_enabled"
        static let analyticsDisabled = "analytics_disabled"
        static let performanceMeasurement = "performance_measurement"
        static let conversion = "conversion"
    }
} 