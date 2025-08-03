import Foundation
import Combine
import UIKit // Added for UIDevice

/**
 * Analytics Service - Infrastructure Layer
 * 
 * Professional analytics service with multiple provider support.
 * Provides user behavior tracking, conversion optimization, and error tracking.
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

// MARK: - Analytics Service Implementation
class AnalyticsService: AnalyticsServiceProtocol {
    
    // MARK: - Properties
    static let shared = AnalyticsService()
    
    private var providers: [AnalyticsProviderProtocol] = []
    private var isEnabled = true
    private var userID: String?
    private var userProperties: [String: Any] = [:]
    private let sessionID = UUID().uuidString
    private let eventQueue = DispatchQueue(label: "analytics.events", qos: .background)
    private let eventBuffer: [AnalyticsEvent] = []
    private let maxBufferSize = 100
    
    // MARK: - Initialization
    private init() {
        setupDefaultProviders()
    }
    
    // MARK: - Public Methods
    func trackEvent(_ event: String, parameters: [String: Any]?) {
        guard isEnabled else { return }
        
        let analyticsEvent = AnalyticsEvent(name: event, parameters: parameters, userID: userID)
        
        eventQueue.async {
            self.processEvent(analyticsEvent)
        }
    }
    
    func trackScreen(_ screenName: String, parameters: [String: Any]?) {
        guard isEnabled else { return }
        
        let eventName = "screen_view"
        var eventParameters = parameters ?? [:]
        eventParameters["screen_name"] = screenName
        eventParameters["screen_class"] = screenName
        
        trackEvent(eventName, parameters: eventParameters)
        
        // Track screen view to all providers
        for provider in providers {
            provider.trackScreen(screenName, parameters: parameters)
        }
    }
    
    func trackUserProperty(_ property: String, value: Any) {
        guard isEnabled else { return }
        
        userProperties[property] = value
        
        // Track user property to all providers
        for provider in providers {
            provider.trackUserProperty(property, value: value)
        }
    }
    
    func trackError(_ error: Error, context: String) {
        guard isEnabled else { return }
        
        let parameters: [String: Any] = [
            "error_description": error.localizedDescription,
            "error_domain": (error as NSError).domain,
            "error_code": (error as NSError).code,
            "context": context,
            "timestamp": Date().timeIntervalSince1970
        ]
        
        trackEvent("error_occurred", parameters: parameters)
    }
    
    func trackPerformance(_ operation: String, duration: TimeInterval) {
        guard isEnabled else { return }
        
        let parameters: [String: Any] = [
            "operation": operation,
            "duration": duration,
            "timestamp": Date().timeIntervalSince1970
        ]
        
        trackEvent("performance_measurement", parameters: parameters)
    }
    
    func trackConversion(_ event: String, value: Double) {
        guard isEnabled else { return }
        
        let parameters: [String: Any] = [
            "event": event,
            "value": value,
            "currency": "USD",
            "timestamp": Date().timeIntervalSince1970
        ]
        
        trackEvent("conversion", parameters: parameters)
    }
    
    func setUserID(_ userID: String) {
        self.userID = userID
        
        // Set user ID to all providers
        for provider in providers {
            provider.setUserID(userID)
        }
        
        // Track user identification
        trackEvent("user_identified", parameters: ["user_id": userID])
    }
    
    func setUserProperties(_ properties: [String: Any]) {
        userProperties.merge(properties) { _, new in new }
        
        // Set user properties to all providers
        for (property, value) in properties {
            for provider in providers {
                provider.trackUserProperty(property, value: value)
            }
        }
        
        // Track user properties update
        trackEvent("user_properties_updated", parameters: properties)
    }
    
    func enableAnalytics(_ enabled: Bool) {
        isEnabled = enabled
        
        // Enable/disable tracking for all providers
        for provider in providers {
            provider.enableTracking(enabled)
        }
        
        // Track analytics state change
        if enabled {
            trackEvent("analytics_enabled", parameters: nil)
        } else {
            trackEvent("analytics_disabled", parameters: nil)
        }
    }
    
    func flushEvents() {
        // Flush events to all providers
        for provider in providers {
            provider.flushEvents()
        }
    }
    
    // MARK: - Private Methods
    private func setupDefaultProviders() {
        // Add Firebase Analytics provider
        let firebaseProvider = FirebaseAnalyticsProvider()
        providers.append(firebaseProvider)
        
        // Add Facebook Analytics provider
        let facebookProvider = FacebookAnalyticsProvider()
        providers.append(facebookProvider)
        
        // Add custom analytics provider
        let customProvider = CustomAnalyticsProvider()
        providers.append(customProvider)
    }
    
    private func processEvent(_ event: AnalyticsEvent) {
        // Add common parameters
        var enhancedParameters = event.parameters
        enhancedParameters["timestamp"] = event.timestamp.timeIntervalSince1970
        enhancedParameters["session_id"] = event.sessionID
        enhancedParameters["app_version"] = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
        enhancedParameters["build_number"] = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
        enhancedParameters["platform"] = "iOS"
        enhancedParameters["os_version"] = UIDevice.current.systemVersion
        
        // Add user properties to event
        for (key, value) in userProperties {
            enhancedParameters["user_\(key)"] = value
        }
        
        let enhancedEvent = AnalyticsEvent(
            name: event.name,
            parameters: enhancedParameters,
            userID: event.userID
        )
        
        // Send to all providers
        for provider in providers {
            provider.trackEvent(enhancedEvent)
        }
    }
}

// MARK: - Firebase Analytics Provider
class FirebaseAnalyticsProvider: AnalyticsProviderProtocol {
    
    func trackEvent(_ event: AnalyticsEvent) {
        // Firebase Analytics implementation
        // This would typically use Firebase Analytics SDK
        print("Firebase Analytics: \(event.name) - \(event.parameters)")
    }
    
    func trackScreen(_ screenName: String, parameters: [String: Any]?) {
        print("Firebase Analytics Screen: \(screenName)")
    }
    
    func trackUserProperty(_ property: String, value: Any) {
        print("Firebase Analytics User Property: \(property) = \(value)")
    }
    
    func setUserID(_ userID: String) {
        print("Firebase Analytics User ID: \(userID)")
    }
    
    func enableTracking(_ enabled: Bool) {
        print("Firebase Analytics Tracking: \(enabled)")
    }
    
    func flushEvents() {
        print("Firebase Analytics: Flushing events")
    }
}

// MARK: - Facebook Analytics Provider
class FacebookAnalyticsProvider: AnalyticsProviderProtocol {
    
    func trackEvent(_ event: AnalyticsEvent) {
        // Facebook Analytics implementation
        // This would typically use Facebook SDK
        print("Facebook Analytics: \(event.name) - \(event.parameters)")
    }
    
    func trackScreen(_ screenName: String, parameters: [String: Any]?) {
        print("Facebook Analytics Screen: \(screenName)")
    }
    
    func trackUserProperty(_ property: String, value: Any) {
        print("Facebook Analytics User Property: \(property) = \(value)")
    }
    
    func setUserID(_ userID: String) {
        print("Facebook Analytics User ID: \(userID)")
    }
    
    func enableTracking(_ enabled: Bool) {
        print("Facebook Analytics Tracking: \(enabled)")
    }
    
    func flushEvents() {
        print("Facebook Analytics: Flushing events")
    }
}

// MARK: - Custom Analytics Provider
class CustomAnalyticsProvider: AnalyticsProviderProtocol {
    
    func trackEvent(_ event: AnalyticsEvent) {
        // Custom analytics implementation
        // This could send events to your own analytics server
        print("Custom Analytics: \(event.name) - \(event.parameters)")
    }
    
    func trackScreen(_ screenName: String, parameters: [String: Any]?) {
        print("Custom Analytics Screen: \(screenName)")
    }
    
    func trackUserProperty(_ property: String, value: Any) {
        print("Custom Analytics User Property: \(property) = \(value)")
    }
    
    func setUserID(_ userID: String) {
        print("Custom Analytics User ID: \(userID)")
    }
    
    func enableTracking(_ enabled: Bool) {
        print("Custom Analytics Tracking: \(enabled)")
    }
    
    func flushEvents() {
        print("Custom Analytics: Flushing events")
    }
}

// MARK: - Analytics Extensions
extension AnalyticsService {
    
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
extension AnalyticsService {
    
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
