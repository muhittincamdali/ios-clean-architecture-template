# 📊 Analytics Guide

<!-- TOC START -->
## Table of Contents
- [📊 Analytics Guide](#-analytics-guide)
- [🎯 Analytics Overview](#-analytics-overview)
- [📊 Analytics Manager](#-analytics-manager)
  - [🔧 Analytics Manager](#-analytics-manager)
- [🎯 User Behavior Tracking](#-user-behavior-tracking)
  - [🎯 User Journey Tracking](#-user-journey-tracking)
- [🎯 Conversion Tracking](#-conversion-tracking)
  - [🎯 Conversion Events](#-conversion-events)
- [📈 Retention Analysis](#-retention-analysis)
  - [📈 Retention Tracker](#-retention-tracker)
- [💰 Revenue Tracking](#-revenue-tracking)
  - [💰 Revenue Tracker](#-revenue-tracker)
- [⚡ Performance Monitoring](#-performance-monitoring)
  - [⚡ Performance Tracker](#-performance-tracker)
- [🐛 Error Tracking](#-error-tracking)
  - [🐛 Error Tracker](#-error-tracker)
- [🧪 A/B Testing](#-ab-testing)
  - [🧪 A/B Test Manager](#-ab-test-manager)
- [🎨 Heat Mapping](#-heat-mapping)
  - [🎨 Heat Map Tracker](#-heat-map-tracker)
- [📊 Analytics Dashboard](#-analytics-dashboard)
  - [📊 Dashboard Manager](#-dashboard-manager)
- [🧪 Analytics Testing](#-analytics-testing)
  - [🧪 Analytics Tests](#-analytics-tests)
- [📋 Analytics Checklist](#-analytics-checklist)
  - [📊 Event Tracking](#-event-tracking)
  - [🎯 Conversion Tracking](#-conversion-tracking)
  - [📈 Retention Analysis](#-retention-analysis)
  - [💰 Revenue Tracking](#-revenue-tracking)
  - [⚡ Performance Monitoring](#-performance-monitoring)
  - [🐛 Error Tracking](#-error-tracking)
  - [🧪 A/B Testing](#-ab-testing)
  - [🎨 Heat Mapping](#-heat-mapping)
<!-- TOC END -->


<div align="center">

**📊 Dünya standartlarında analitik ve metrik sistemi rehberi**

[📚 Getting Started](GettingStarted.md) • [🏗️ Architecture](Architecture.md) • [⚡ Performance](Performance.md)

</div>

---

## 🎯 Analytics Overview

Bu proje, dünya standartlarında analitik ve metrik sistemi sağlar:

- **📊 User Behavior Tracking** - Kullanıcı davranış analizi
- **🎯 Conversion Optimization** - Dönüşüm optimizasyonu
- **📈 Retention Analysis** - Kullanıcı tutma analizi
- **💰 Revenue Tracking** - Gelir takibi
- **⚡ Performance Monitoring** - Performans izleme
- **🐛 Error Tracking** - Hata takibi
- **🧪 A/B Testing** - A/B testleri
- **🎨 Heat Mapping** - Isı haritaları

---

## 📊 Analytics Manager

### 🔧 Analytics Manager

```swift
// Analytics Manager
class AnalyticsManager: ObservableObject {
    static let shared = AnalyticsManager()
    
    private let firebaseAnalytics: FirebaseAnalyticsProtocol
    private let crashlytics: CrashlyticsProtocol
    private let amplitude: AmplitudeProtocol
    private let mixpanel: MixpanelProtocol
    
    init(
        firebaseAnalytics: FirebaseAnalyticsProtocol,
        crashlytics: CrashlyticsProtocol,
        amplitude: AmplitudeProtocol,
        mixpanel: MixpanelProtocol
    ) {
        self.firebaseAnalytics = firebaseAnalytics
        self.crashlytics = crashlytics
        self.amplitude = amplitude
        self.mixpanel = mixpanel
    }
    
    // Event Tracking
    func trackEvent(_ event: AnalyticsEvent) {
        firebaseAnalytics.logEvent(event.name, parameters: event.parameters)
        amplitude.logEvent(event.name, properties: event.parameters)
        mixpanel.track(event.name, properties: event.parameters)
    }
    
    // Screen Tracking
    func trackScreen(_ screen: AnalyticsScreen) {
        firebaseAnalytics.logEvent("screen_view", parameters: [
            "screen_name": screen.name,
            "screen_class": screen.className
        ])
    }
    
    // User Properties
    func setUserProperty(_ value: String, forKey key: String) {
        firebaseAnalytics.setUserProperty(value, forName: key)
        amplitude.setUserProperty(key, value: value)
        mixpanel.setPeople(key, value: value)
    }
    
    // Error Tracking
    func trackError(_ error: Error) {
        crashlytics.recordError(error)
        firebaseAnalytics.logEvent("app_error", parameters: [
            "error_message": error.localizedDescription,
            "error_domain": (error as NSError).domain,
            "error_code": (error as NSError).code
        ])
    }
    
    // Performance Tracking
    func trackPerformance(_ metric: PerformanceMetric) {
        firebaseAnalytics.logEvent("performance_metric", parameters: [
            "metric_name": metric.name,
            "metric_value": metric.value,
            "metric_unit": metric.unit
        ])
    }
}

// Analytics Event
struct AnalyticsEvent {
    let name: String
    let parameters: [String: Any]
    
    init(name: String, parameters: [String: Any] = [:]) {
        self.name = name
        self.parameters = parameters
    }
}

// Analytics Screen
struct AnalyticsScreen {
    let name: String
    let className: String
    
    init(name: String, className: String) {
        self.name = name
        self.className = className
    }
}

// Performance Metric
struct PerformanceMetric {
    let name: String
    let value: Double
    let unit: String
    
    init(name: String, value: Double, unit: String) {
        self.name = name
        self.value = value
        self.unit = unit
    }
}
```

---

## 🎯 User Behavior Tracking

### 🎯 User Journey Tracking

```swift
// User Journey Tracker
class UserJourneyTracker {
    private let analyticsManager = AnalyticsManager.shared
    
    func trackUserJourney() {
        // App Launch
        analyticsManager.trackEvent(AnalyticsEvent(
            name: "app_launch",
            parameters: [
                "launch_type": "cold",
                "device_model": UIDevice.current.model,
                "ios_version": UIDevice.current.systemVersion
            ]
        ))
    }
    
    func trackScreenView(_ screen: AnalyticsScreen) {
        analyticsManager.trackScreen(screen)
        
        // Track screen time
        analyticsManager.trackEvent(AnalyticsEvent(
            name: "screen_view",
            parameters: [
                "screen_name": screen.name,
                "screen_class": screen.className,
                "timestamp": Date().timeIntervalSince1970
            ]
        ))
    }
    
    func trackUserAction(_ action: String, screen: String, parameters: [String: Any] = [:]) {
        analyticsManager.trackEvent(AnalyticsEvent(
            name: "user_action",
            parameters: [
                "action": action,
                "screen": screen,
                "timestamp": Date().timeIntervalSince1970
            ].merging(parameters) { _, new in new }
        ))
    }
    
    func trackUserFlow(_ flow: String, step: String, parameters: [String: Any] = [:]) {
        analyticsManager.trackEvent(AnalyticsEvent(
            name: "user_flow",
            parameters: [
                "flow": flow,
                "step": step,
                "timestamp": Date().timeIntervalSince1970
            ].merging(parameters) { _, new in new }
        ))
    }
}

// Usage in ViewModels
extension UserViewModel {
    func trackUserProfileView() {
        UserJourneyTracker().trackScreenView(AnalyticsScreen(
            name: "User Profile",
            className: "UserView"
        ))
    }
    
    func trackUserEdit() {
        UserJourneyTracker().trackUserAction(
            "edit_profile",
            screen: "UserView",
            parameters: ["user_id": user?.id ?? ""]
        )
    }
}
```

---

## 🎯 Conversion Tracking

### 🎯 Conversion Events

```swift
// Conversion Tracker
class ConversionTracker {
    private let analyticsManager = AnalyticsManager.shared
    
    func trackSignUp(method: String, parameters: [String: Any] = [:]) {
        analyticsManager.trackEvent(AnalyticsEvent(
            name: "sign_up",
            parameters: [
                "method": method,
                "timestamp": Date().timeIntervalSince1970
            ].merging(parameters) { _, new in new }
        ))
    }
    
    func trackPurchase(productId: String, amount: Decimal, currency: String) {
        analyticsManager.trackEvent(AnalyticsEvent(
            name: "purchase",
            parameters: [
                "product_id": productId,
                "amount": amount,
                "currency": currency,
                "timestamp": Date().timeIntervalSince1970
            ]
        ))
    }
    
    func trackSubscription(plan: String, amount: Decimal, currency: String) {
        analyticsManager.trackEvent(AnalyticsEvent(
            name: "subscription",
            parameters: [
                "plan": plan,
                "amount": amount,
                "currency": currency,
                "timestamp": Date().timeIntervalSince1970
            ]
        ))
    }
    
    func trackFeatureUsage(feature: String, parameters: [String: Any] = [:]) {
        analyticsManager.trackEvent(AnalyticsEvent(
            name: "feature_usage",
            parameters: [
                "feature": feature,
                "timestamp": Date().timeIntervalSince1970
            ].merging(parameters) { _, new in new }
        ))
    }
}
```

---

## 📈 Retention Analysis

### 📈 Retention Tracker

```swift
// Retention Tracker
class RetentionTracker {
    private let analyticsManager = AnalyticsManager.shared
    private let userDefaults = UserDefaults.standard
    
    func trackUserRetention() {
        let firstLaunchDate = userDefaults.object(forKey: "first_launch_date") as? Date ?? Date()
        let currentDate = Date()
        let daysSinceFirstLaunch = Calendar.current.dateComponents([.day], from: firstLaunchDate, to: currentDate).day ?? 0
        
        analyticsManager.trackEvent(AnalyticsEvent(
            name: "user_retention",
            parameters: [
                "days_since_first_launch": daysSinceFirstLaunch,
                "is_returning_user": daysSinceFirstLaunch > 0
            ]
        ))
    }
    
    func trackSessionStart() {
        let sessionCount = userDefaults.integer(forKey: "session_count") + 1
        userDefaults.set(sessionCount, forKey: "session_count")
        
        analyticsManager.trackEvent(AnalyticsEvent(
            name: "session_start",
            parameters: [
                "session_count": sessionCount,
                "timestamp": Date().timeIntervalSince1970
            ]
        ))
    }
    
    func trackSessionEnd(duration: TimeInterval) {
        analyticsManager.trackEvent(AnalyticsEvent(
            name: "session_end",
            parameters: [
                "session_duration": duration,
                "timestamp": Date().timeIntervalSince1970
            ]
        ))
    }
}
```

---

## 💰 Revenue Tracking

### 💰 Revenue Tracker

```swift
// Revenue Tracker
class RevenueTracker {
    private let analyticsManager = AnalyticsManager.shared
    
    func trackRevenue(amount: Decimal, currency: String, source: String) {
        analyticsManager.trackEvent(AnalyticsEvent(
            name: "revenue",
            parameters: [
                "amount": amount,
                "currency": currency,
                "source": source,
                "timestamp": Date().timeIntervalSince1970
            ]
        ))
    }
    
    func trackInAppPurchase(productId: String, price: Decimal, currency: String) {
        analyticsManager.trackEvent(AnalyticsEvent(
            name: "in_app_purchase",
            parameters: [
                "product_id": productId,
                "price": price,
                "currency": currency,
                "timestamp": Date().timeIntervalSince1970
            ]
        ))
    }
    
    func trackSubscriptionRevenue(plan: String, monthlyRevenue: Decimal, currency: String) {
        analyticsManager.trackEvent(AnalyticsEvent(
            name: "subscription_revenue",
            parameters: [
                "plan": plan,
                "monthly_revenue": monthlyRevenue,
                "currency": currency,
                "timestamp": Date().timeIntervalSince1970
            ]
        ))
    }
}
```

---

## ⚡ Performance Monitoring

### ⚡ Performance Tracker

```swift
// Performance Tracker
class PerformanceTracker {
    private let analyticsManager = AnalyticsManager.shared
    
    func trackAppLaunchTime(_ duration: TimeInterval) {
        analyticsManager.trackPerformance(PerformanceMetric(
            name: "app_launch_time",
            value: duration,
            unit: "seconds"
        ))
    }
    
    func trackAPIResponseTime(_ duration: TimeInterval, endpoint: String) {
        analyticsManager.trackPerformance(PerformanceMetric(
            name: "api_response_time",
            value: duration,
            unit: "milliseconds"
        ))
        
        analyticsManager.trackEvent(AnalyticsEvent(
            name: "api_performance",
            parameters: [
                "endpoint": endpoint,
                "response_time": duration,
                "timestamp": Date().timeIntervalSince1970
            ]
        ))
    }
    
    func trackMemoryUsage(_ usage: UInt64) {
        analyticsManager.trackPerformance(PerformanceMetric(
            name: "memory_usage",
            value: Double(usage) / 1024 / 1024, // Convert to MB
            unit: "MB"
        ))
    }
    
    func trackBatteryUsage(_ level: Float) {
        analyticsManager.trackPerformance(PerformanceMetric(
            name: "battery_level",
            value: Double(level * 100), // Convert to percentage
            unit: "percentage"
        ))
    }
}
```

---

## 🐛 Error Tracking

### 🐛 Error Tracker

```swift
// Error Tracker
class ErrorTracker {
    private let analyticsManager = AnalyticsManager.shared
    
    func trackError(_ error: Error, context: String = "") {
        analyticsManager.trackError(error)
        
        analyticsManager.trackEvent(AnalyticsEvent(
            name: "app_error",
            parameters: [
                "error_message": error.localizedDescription,
                "error_domain": (error as NSError).domain,
                "error_code": (error as NSError).code,
                "context": context,
                "timestamp": Date().timeIntervalSince1970
            ]
        ))
    }
    
    func trackNetworkError(_ error: NetworkError, endpoint: String) {
        analyticsManager.trackEvent(AnalyticsEvent(
            name: "network_error",
            parameters: [
                "error_type": String(describing: error),
                "endpoint": endpoint,
                "timestamp": Date().timeIntervalSince1970
            ]
        ))
    }
    
    func trackCrash(_ exception: NSException) {
        analyticsManager.trackEvent(AnalyticsEvent(
            name: "app_crash",
            parameters: [
                "exception_name": exception.name.rawValue,
                "exception_reason": exception.reason ?? "",
                "timestamp": Date().timeIntervalSince1970
            ]
        ))
    }
}
```

---

## 🧪 A/B Testing

### 🧪 A/B Test Manager

```swift
// A/B Test Manager
class ABTestManager {
    private let analyticsManager = AnalyticsManager.shared
    private let userDefaults = UserDefaults.standard
    
    func getVariant(for test: String) -> String {
        let key = "ab_test_\(test)"
        
        if let variant = userDefaults.string(forKey: key) {
            return variant
        }
        
        // Assign random variant
        let variants = ["A", "B", "C"]
        let randomVariant = variants.randomElement() ?? "A"
        userDefaults.set(randomVariant, forKey: key)
        
        return randomVariant
    }
    
    func trackABTest(_ test: String, variant: String, action: String) {
        analyticsManager.trackEvent(AnalyticsEvent(
            name: "ab_test",
            parameters: [
                "test_name": test,
                "variant": variant,
                "action": action,
                "timestamp": Date().timeIntervalSince1970
            ]
        ))
    }
    
    func isInVariant(_ test: String, variant: String) -> Bool {
        return getVariant(for: test) == variant
    }
}

// Usage example
struct ABTestView: View {
    private let abTestManager = ABTestManager()
    
    var body: some View {
        if abTestManager.isInVariant("button_color", "red") {
            Button("Click me") {
                abTestManager.trackABTest("button_color", variant: "red", action: "click")
            }
            .background(Color.red)
        } else {
            Button("Click me") {
                abTestManager.trackABTest("button_color", variant: "blue", action: "click")
            }
            .background(Color.blue)
        }
    }
}
```

---

## 🎨 Heat Mapping

### 🎨 Heat Map Tracker

```swift
// Heat Map Tracker
class HeatMapTracker {
    private let analyticsManager = AnalyticsManager.shared
    
    func trackTap(x: CGFloat, y: CGFloat, screen: String, element: String) {
        analyticsManager.trackEvent(AnalyticsEvent(
            name: "heat_map_tap",
            parameters: [
                "x_coordinate": x,
                "y_coordinate": y,
                "screen": screen,
                "element": element,
                "timestamp": Date().timeIntervalSince1970
            ]
        ))
    }
    
    func trackScroll(distance: CGFloat, screen: String) {
        analyticsManager.trackEvent(AnalyticsEvent(
            name: "heat_map_scroll",
            parameters: [
                "scroll_distance": distance,
                "screen": screen,
                "timestamp": Date().timeIntervalSince1970
            ]
        ))
    }
    
    func trackViewTime(duration: TimeInterval, screen: String) {
        analyticsManager.trackEvent(AnalyticsEvent(
            name: "heat_map_view_time",
            parameters: [
                "view_duration": duration,
                "screen": screen,
                "timestamp": Date().timeIntervalSince1970
            ]
        ))
    }
}

// SwiftUI Heat Map View
struct HeatMapView<Content: View>: View {
    let content: Content
    let screenName: String
    @State private var tapLocation: CGPoint = .zero
    
    init(screenName: String, @ViewBuilder content: () -> Content) {
        self.screenName = screenName
        self.content = content()
    }
    
    var body: some View {
        content
            .onTapGesture { location in
                HeatMapTracker().trackTap(
                    x: location.x,
                    y: location.y,
                    screen: screenName,
                    element: "unknown"
                )
            }
    }
}
```

---

## 📊 Analytics Dashboard

### 📊 Dashboard Manager

```swift
// Analytics Dashboard Manager
class AnalyticsDashboardManager {
    private let analyticsManager = AnalyticsManager.shared
    
    func generateUserReport() -> UserAnalyticsReport {
        // This would typically fetch data from analytics services
        return UserAnalyticsReport(
            totalUsers: 10000,
            activeUsers: 5000,
            newUsers: 1000,
            retentionRate: 0.85
        )
    }
    
    func generateRevenueReport() -> RevenueAnalyticsReport {
        return RevenueAnalyticsReport(
            totalRevenue: 50000,
            monthlyRevenue: 5000,
            averageRevenuePerUser: 5.0,
            conversionRate: 0.05
        )
    }
    
    func generatePerformanceReport() -> PerformanceAnalyticsReport {
        return PerformanceAnalyticsReport(
            averageLaunchTime: 1.2,
            averageAPIResponseTime: 150,
            crashRate: 0.01,
            memoryUsage: 150
        )
    }
}

// Analytics Reports
struct UserAnalyticsReport {
    let totalUsers: Int
    let activeUsers: Int
    let newUsers: Int
    let retentionRate: Double
}

struct RevenueAnalyticsReport {
    let totalRevenue: Decimal
    let monthlyRevenue: Decimal
    let averageRevenuePerUser: Decimal
    let conversionRate: Double
}

struct PerformanceAnalyticsReport {
    let averageLaunchTime: TimeInterval
    let averageAPIResponseTime: TimeInterval
    let crashRate: Double
    let memoryUsage: Double
}
```

---

## 🧪 Analytics Testing

### 🧪 Analytics Tests

```swift
// Analytics Tests
class AnalyticsTests: XCTestCase {
    var mockAnalyticsManager: MockAnalyticsManager!
    
    override func setUp() {
        super.setUp()
        mockAnalyticsManager = MockAnalyticsManager()
    }
    
    func testEventTracking() {
        // Given
        let event = AnalyticsEvent(name: "test_event", parameters: ["key": "value"])
        
        // When
        mockAnalyticsManager.trackEvent(event)
        
        // Then
        XCTAssertEqual(mockAnalyticsManager.trackedEvents.count, 1)
        XCTAssertEqual(mockAnalyticsManager.trackedEvents.first?.name, "test_event")
    }
    
    func testScreenTracking() {
        // Given
        let screen = AnalyticsScreen(name: "Test Screen", className: "TestView")
        
        // When
        mockAnalyticsManager.trackScreen(screen)
        
        // Then
        XCTAssertEqual(mockAnalyticsManager.trackedScreens.count, 1)
        XCTAssertEqual(mockAnalyticsManager.trackedScreens.first?.name, "Test Screen")
    }
    
    func testErrorTracking() {
        // Given
        let error = NSError(domain: "TestDomain", code: 1, userInfo: nil)
        
        // When
        mockAnalyticsManager.trackError(error)
        
        // Then
        XCTAssertEqual(mockAnalyticsManager.trackedErrors.count, 1)
        XCTAssertEqual(mockAnalyticsManager.trackedErrors.first?.localizedDescription, error.localizedDescription)
    }
}

// Mock Analytics Manager
class MockAnalyticsManager: AnalyticsManagerProtocol {
    var trackedEvents: [AnalyticsEvent] = []
    var trackedScreens: [AnalyticsScreen] = []
    var trackedErrors: [Error] = []
    
    func trackEvent(_ event: AnalyticsEvent) {
        trackedEvents.append(event)
    }
    
    func trackScreen(_ screen: AnalyticsScreen) {
        trackedScreens.append(screen)
    }
    
    func trackError(_ error: Error) {
        trackedErrors.append(error)
    }
}
```

---

## 📋 Analytics Checklist

### 📊 Event Tracking
- [ ] **User Actions** - Button clicks, form submissions
- [ ] **Screen Views** - Page/screen visits
- [ ] **User Flows** - Complete user journeys
- [ ] **Feature Usage** - Feature adoption rates

### 🎯 Conversion Tracking
- [ ] **Sign-ups** - User registration events
- [ ] **Purchases** - Revenue events
- [ ] **Subscriptions** - Recurring revenue
- [ ] **Feature Adoption** - Feature usage

### 📈 Retention Analysis
- [ ] **User Retention** - Daily/weekly/monthly
- [ ] **Session Tracking** - Session duration
- [ ] **Return Visits** - Repeat usage
- [ ] **Churn Analysis** - User loss

### 💰 Revenue Tracking
- [ ] **Revenue Events** - All revenue sources
- [ ] **In-app Purchases** - One-time purchases
- [ ] **Subscriptions** - Recurring revenue
- [ ] **Revenue Attribution** - Source tracking

### ⚡ Performance Monitoring
- [ ] **App Launch Time** - Performance metrics
- [ ] **API Response Time** - Network performance
- [ ] **Memory Usage** - Resource usage
- [ ] **Battery Usage** - Device impact

### 🐛 Error Tracking
- [ ] **Crash Reports** - App crashes
- [ ] **Network Errors** - API failures
- [ ] **User Errors** - User-facing errors
- [ ] **Performance Issues** - Slow operations

### 🧪 A/B Testing
- [ ] **Test Setup** - Variant assignment
- [ ] **Event Tracking** - Test interactions
- [ ] **Results Analysis** - Statistical significance
- [ ] **Implementation** - Feature rollouts

### 🎨 Heat Mapping
- [ ] **Tap Tracking** - User interaction points
- [ ] **Scroll Tracking** - Content engagement
- [ ] **View Time** - Content consumption
- [ ] **User Paths** - Navigation patterns

---

<div align="center">

**📊 Dünya standartlarında analitik sistemi için teşekkürler!**

**🚀 Dünya standartlarında iOS Clean Architecture Template**

</div> 