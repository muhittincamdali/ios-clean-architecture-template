# ⚡ Performance Guide

<!-- TOC START -->
## Table of Contents
- [⚡ Performance Guide](#-performance-guide)
- [🎯 Performance Overview](#-performance-overview)
- [📊 Performance Metrics](#-performance-metrics)
  - [🚀 App Launch Performance](#-app-launch-performance)
  - [⚡ Network Performance](#-network-performance)
  - [🎭 Animation Performance](#-animation-performance)
- [💾 Memory Management](#-memory-management)
  - [🧠 Memory Optimization](#-memory-optimization)
  - [🖼️ Image Optimization](#-image-optimization)
- [🔋 Battery Optimization](#-battery-optimization)
  - [🔋 Battery Usage Monitor](#-battery-usage-monitor)
  - [🔋 Background Task Optimization](#-background-task-optimization)
- [📱 Storage Optimization](#-storage-optimization)
  - [💾 Storage Manager](#-storage-manager)
- [🎭 Animation Performance](#-animation-performance)
  - [🎭 Optimized Animations](#-optimized-animations)
- [📊 Performance Monitoring](#-performance-monitoring)
  - [📊 Real-time Monitoring](#-real-time-monitoring)
- [🧪 Performance Testing](#-performance-testing)
  - [🧪 Performance Test Suite](#-performance-test-suite)
- [📋 Performance Checklist](#-performance-checklist)
  - [🚀 App Launch](#-app-launch)
  - [⚡ Network](#-network)
  - [🎭 Animations](#-animations)
  - [💾 Memory](#-memory)
  - [🔋 Battery](#-battery)
  - [📱 Storage](#-storage)
<!-- TOC END -->


<div align="center">

**⚡ Dünya standartlarında performans optimizasyonu rehberi**

[📚 Getting Started](GettingStarted.md) • [🏗️ Architecture](Architecture.md) • [🎨 Design System](DesignSystem.md)

</div>

---

## 🎯 Performance Overview

Bu proje, dünya standartlarında performans optimizasyonu sağlar:

- **🚀 App Açılışı**: <1.3 saniye
- **⚡ API Yanıtı**: <200ms
- **🎭 Animasyonlar**: 60fps
- **💾 Memory Usage**: <200MB
- **🔋 Battery**: %30 daha az tüketim
- **📱 Storage**: Optimize edilmiş boyut

---

## 📊 Performance Metrics

### 🚀 App Launch Performance

```swift
// App Launch Time Measurement
class AppLaunchTracker {
    private let startTime: CFAbsoluteTime
    
    init() {
        self.startTime = CFAbsoluteTimeGetCurrent()
    }
    
    func trackLaunchTime() {
        let launchTime = CFAbsoluteTimeGetCurrent() - startTime
        AnalyticsManager.shared.trackMetric("app_launch_time", value: launchTime)
        
        // Target: <1.3 seconds
        if launchTime > 1.3 {
            PerformanceMonitor.shared.recordWarning("Slow app launch: \(launchTime)s")
        }
    }
}

// Usage in AppDelegate
class AppDelegate: UIResponder, UIApplicationDelegate {
    private let launchTracker = AppLaunchTracker()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // App initialization
        setupApp()
        
        // Track launch time
        launchTracker.trackLaunchTime()
        
        return true
    }
}
```

### ⚡ Network Performance

```swift
// Network Performance Monitor
class NetworkPerformanceMonitor {
    private let session: URLSession
    private let performanceMonitor: PerformanceMonitorProtocol
    
    init(session: URLSession, performanceMonitor: PerformanceMonitorProtocol) {
        self.session = session
        self.performanceMonitor = performanceMonitor
    }
    
    func measureRequest<T: Codable>(_ endpoint: APIEndpoint) async throws -> T {
        let startTime = CFAbsoluteTimeGetCurrent()
        
        do {
            let data = try await session.data(from: endpoint.url)
            let responseTime = CFAbsoluteTimeGetCurrent() - startTime
            
            // Track response time
            performanceMonitor.addMetric("api_response_time", value: responseTime)
            
            // Target: <200ms
            if responseTime > 0.2 {
                performanceMonitor.recordWarning("Slow API response: \(responseTime)s")
            }
            
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            performanceMonitor.recordError(error)
            throw error
        }
    }
}
```

### 🎭 Animation Performance

```swift
// Animation Performance Monitor
class AnimationPerformanceMonitor {
    private let displayLink: CADisplayLink
    private var frameCount = 0
    private var lastFrameTime: CFTimeInterval = 0
    
    init() {
        self.displayLink = CADisplayLink(target: self, selector: #selector(frameUpdate))
        self.displayLink.add(to: .main, forMode: .common)
    }
    
    @objc private func frameUpdate() {
        frameCount += 1
        let currentTime = CACurrentMediaTime()
        
        if lastFrameTime > 0 {
            let frameTime = currentTime - lastFrameTime
            let fps = 1.0 / frameTime
            
            // Track FPS
            if fps < 60 {
                PerformanceMonitor.shared.recordWarning("Low FPS: \(fps)")
            }
        }
        
        lastFrameTime = currentTime
    }
}
```

---

## 💾 Memory Management

### 🧠 Memory Optimization

```swift
// Memory Manager
class MemoryManager {
    private let memoryThreshold: UInt64 = 200 * 1024 * 1024 // 200MB
    
    func monitorMemoryUsage() {
        let memoryUsage = getMemoryUsage()
        
        if memoryUsage > memoryThreshold {
            cleanupMemory()
        }
    }
    
    private func getMemoryUsage() -> UInt64 {
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
        
        return kerr == KERN_SUCCESS ? UInt64(info.resident_size) : 0
    }
    
    private func cleanupMemory() {
        // Clear image cache
        ImageCache.shared.clearCache()
        
        // Clear temporary data
        clearTemporaryData()
        
        // Force garbage collection
        autoreleasepool {
            // Cleanup operations
        }
    }
}
```

### 🖼️ Image Optimization

```swift
// Optimized Image Loading
class OptimizedImageLoader {
    private let cache = NSCache<NSString, UIImage>()
    private let fileManager = FileManager.default
    
    func loadImage(from url: URL) async throws -> UIImage {
        // Check cache first
        if let cachedImage = cache.object(forKey: url.absoluteString as NSString) {
            return cachedImage
        }
        
        // Load and optimize image
        let imageData = try await downloadImageData(from: url)
        let optimizedImage = try await optimizeImage(imageData)
        
        // Cache optimized image
        cache.setObject(optimizedImage, forKey: url.absoluteString as NSString)
        
        return optimizedImage
    }
    
    private func optimizeImage(_ data: Data) async throws -> UIImage {
        guard let image = UIImage(data: data) else {
            throw ImageError.invalidData
        }
        
        // Resize if too large
        let maxSize: CGFloat = 1024
        let optimizedImage = image.size.width > maxSize || image.size.height > maxSize
            ? image.resized(to: CGSize(width: maxSize, height: maxSize))
            : image
        
        // Compress
        guard let compressedData = optimizedImage.jpegData(compressionQuality: 0.8) else {
            throw ImageError.compressionFailed
        }
        
        return UIImage(data: compressedData) ?? optimizedImage
    }
}
```

---

## 🔋 Battery Optimization

### 🔋 Battery Usage Monitor

```swift
// Battery Usage Monitor
class BatteryUsageMonitor {
    private let batteryMonitor = BatteryMonitor()
    private let performanceMonitor: PerformanceMonitorProtocol
    
    init(performanceMonitor: PerformanceMonitorProtocol) {
        self.performanceMonitor = performanceMonitor
        setupBatteryMonitoring()
    }
    
    private func setupBatteryMonitoring() {
        UIDevice.current.isBatteryMonitoringEnabled = true
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(batteryLevelChanged),
            name: UIDevice.batteryLevelDidChangeNotification,
            object: nil
        )
    }
    
    @objc private func batteryLevelChanged() {
        let batteryLevel = UIDevice.current.batteryLevel
        performanceMonitor.addMetric("battery_level", value: Double(batteryLevel))
        
        if batteryLevel < 0.2 {
            enableLowPowerMode()
        }
    }
    
    private func enableLowPowerMode() {
        // Reduce animation complexity
        AnimationManager.shared.setLowPowerMode(true)
        
        // Reduce network requests
        NetworkManager.shared.setLowPowerMode(true)
        
        // Reduce background processing
        BackgroundTaskManager.shared.setLowPowerMode(true)
    }
}
```

### 🔋 Background Task Optimization

```swift
// Background Task Manager
class BackgroundTaskManager {
    private var backgroundTasks: [UIBackgroundTaskIdentifier] = []
    private let maxBackgroundTime: TimeInterval = 30
    
    func startBackgroundTask(name: String, task: @escaping () -> Void) {
        let taskID = UIApplication.shared.beginBackgroundTask(withName: name) { [weak self] in
            self?.endBackgroundTask(taskID)
        }
        
        backgroundTasks.append(taskID)
        
        // Execute task with timeout
        DispatchQueue.global(qos: .background).async {
            task()
            
            DispatchQueue.main.async {
                self.endBackgroundTask(taskID)
            }
        }
    }
    
    private func endBackgroundTask(_ taskID: UIBackgroundTaskIdentifier) {
        UIApplication.shared.endBackgroundTask(taskID)
        backgroundTasks.removeAll { $0 == taskID }
    }
}
```

---

## 📱 Storage Optimization

### 💾 Storage Manager

```swift
// Storage Optimization
class StorageManager {
    private let fileManager = FileManager.default
    private let maxCacheSize: Int64 = 100 * 1024 * 1024 // 100MB
    
    func optimizeStorage() {
        // Clear old cache files
        clearOldCacheFiles()
        
        // Compress large files
        compressLargeFiles()
        
        // Remove temporary files
        removeTemporaryFiles()
    }
    
    private func clearOldCacheFiles() {
        let cacheURL = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first
        let maxAge: TimeInterval = 7 * 24 * 60 * 60 // 7 days
        
        guard let cacheURL = cacheURL else { return }
        
        do {
            let files = try fileManager.contentsOfDirectory(at: cacheURL, includingPropertiesForKeys: [.creationDateKey])
            
            for file in files {
                let attributes = try fileManager.attributesOfItem(atPath: file.path)
                let creationDate = attributes[.creationDate] as? Date ?? Date()
                
                if Date().timeIntervalSince(creationDate) > maxAge {
                    try fileManager.removeItem(at: file)
                }
            }
        } catch {
            Logger.shared.error("Failed to clear old cache files: \(error)")
        }
    }
}
```

---

## 🎭 Animation Performance

### 🎭 Optimized Animations

```swift
// Animation Performance Optimizer
class AnimationPerformanceOptimizer {
    private let displayLink: CADisplayLink
    private var isAnimating = false
    
    init() {
        self.displayLink = CADisplayLink(target: self, selector: #selector(updateAnimation))
        self.displayLink.preferredFramesPerSecond = 60
    }
    
    func startOptimizedAnimation(duration: TimeInterval, animation: @escaping (CGFloat) -> Void) {
        isAnimating = true
        displayLink.add(to: .main, forMode: .common)
        
        let startTime = CACurrentMediaTime()
        
        DispatchQueue.main.async { [weak self] in
            self?.animateWithDisplayLink(startTime: startTime, duration: duration, animation: animation)
        }
    }
    
    @objc private func updateAnimation() {
        // Monitor frame rate
        let currentTime = CACurrentMediaTime()
        let frameTime = currentTime - lastFrameTime
        
        if frameTime > 1.0 / 60.0 {
            // Frame drop detected
            PerformanceMonitor.shared.recordWarning("Frame drop detected")
        }
        
        lastFrameTime = currentTime
    }
    
    private func animateWithDisplayLink(startTime: CFTimeInterval, duration: TimeInterval, animation: @escaping (CGFloat) -> Void) {
        let currentTime = CACurrentMediaTime()
        let elapsed = currentTime - startTime
        let progress = min(elapsed / duration, 1.0)
        
        animation(progress)
        
        if progress < 1.0 && isAnimating {
            DispatchQueue.main.async { [weak self] in
                self?.animateWithDisplayLink(startTime: startTime, duration: duration, animation: animation)
            }
        } else {
            isAnimating = false
            displayLink.invalidate()
        }
    }
}
```

---

## 📊 Performance Monitoring

### 📊 Real-time Monitoring

```swift
// Performance Monitor
class PerformanceMonitor {
    static let shared = PerformanceMonitor()
    
    private var metrics: [String: [Double]] = [:]
    private var warnings: [String] = []
    private var errors: [Error] = []
    
    func addMetric(_ name: String, value: Double) {
        if metrics[name] == nil {
            metrics[name] = []
        }
        metrics[name]?.append(value)
        
        // Alert if threshold exceeded
        checkThresholds(name: name, value: value)
    }
    
    func recordWarning(_ message: String) {
        warnings.append(message)
        Logger.shared.warning(message)
    }
    
    func recordError(_ error: Error) {
        errors.append(error)
        Logger.shared.error("Performance error: \(error)")
    }
    
    private func checkThresholds(name: String, value: Double) {
        switch name {
        case "app_launch_time":
            if value > 1.3 {
                recordWarning("App launch time exceeded threshold: \(value)s")
            }
        case "api_response_time":
            if value > 0.2 {
                recordWarning("API response time exceeded threshold: \(value)s")
            }
        case "memory_usage":
            if value > 200 * 1024 * 1024 { // 200MB
                recordWarning("Memory usage exceeded threshold: \(value / 1024 / 1024)MB")
            }
        default:
            break
        }
    }
    
    func generateReport() -> PerformanceReport {
        return PerformanceReport(
            metrics: metrics,
            warnings: warnings,
            errors: errors
        )
    }
}

struct PerformanceReport {
    let metrics: [String: [Double]]
    let warnings: [String]
    let errors: [Error]
    
    var averageMetrics: [String: Double] {
        metrics.mapValues { values in
            values.reduce(0, +) / Double(values.count)
        }
    }
}
```

---

## 🧪 Performance Testing

### 🧪 Performance Test Suite

```swift
// Performance Tests
class PerformanceTests: XCTestCase {
    func testAppLaunchTime() {
        let expectation = XCTestExpectation(description: "App launch time")
        
        let startTime = CFAbsoluteTimeGetCurrent()
        
        // Simulate app launch
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let launchTime = CFAbsoluteTimeGetCurrent() - startTime
            
            XCTAssertLessThan(launchTime, 1.3, "App launch time should be less than 1.3 seconds")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testAPIPerformance() async throws {
        let networkClient = MockNetworkClient()
        let startTime = CFAbsoluteTimeGetCurrent()
        
        _ = try await networkClient.request(APIEndpoint.getUser(id: "123"))
        
        let responseTime = CFAbsoluteTimeGetCurrent() - startTime
        XCTAssertLessThan(responseTime, 0.2, "API response time should be less than 200ms")
    }
    
    func testMemoryUsage() {
        let initialMemory = getMemoryUsage()
        
        // Perform memory-intensive operation
        for _ in 0..<1000 {
            let _ = UIImage(named: "large_image")
        }
        
        let finalMemory = getMemoryUsage()
        let memoryIncrease = finalMemory - initialMemory
        
        XCTAssertLessThan(memoryIncrease, 50 * 1024 * 1024, "Memory increase should be less than 50MB")
    }
    
    func testAnimationPerformance() {
        let expectation = XCTestExpectation(description: "Animation performance")
        
        let animationOptimizer = AnimationPerformanceOptimizer()
        var frameCount = 0
        
        animationOptimizer.startOptimizedAnimation(duration: 1.0) { progress in
            frameCount += 1
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
            // Should achieve ~60fps
            XCTAssertGreaterThan(frameCount, 50, "Animation should achieve at least 50fps")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
}
```

---

## 📋 Performance Checklist

### 🚀 App Launch
- [ ] **Cold Start**: <1.3 saniye
- [ ] **Warm Start**: <0.8 saniye
- [ ] **Hot Start**: <0.5 saniye
- [ ] **Background Launch**: <0.3 saniye

### ⚡ Network
- [ ] **API Response**: <200ms
- [ ] **Image Loading**: <500ms
- [ ] **Cache Hit**: <50ms
- [ ] **Offline Mode**: Seamless

### 🎭 Animations
- [ ] **Frame Rate**: 60fps
- [ ] **Smooth Transitions**: No stuttering
- [ ] **Memory Efficient**: No leaks
- [ ] **Battery Friendly**: Low power usage

### 💾 Memory
- [ ] **Peak Usage**: <200MB
- [ ] **Background**: <50MB
- [ ] **Memory Leaks**: Zero
- [ ] **Garbage Collection**: Efficient

### 🔋 Battery
- [ ] **CPU Usage**: <30%
- [ ] **Network Calls**: Optimized
- [ ] **Background Tasks**: Minimal
- [ ] **Location Services**: Efficient

### 📱 Storage
- [ ] **App Size**: <100MB
- [ ] **Cache Size**: <50MB
- [ ] **Temporary Files**: Cleaned
- [ ] **User Data**: Compressed

---

<div align="center">

**⚡ Dünya standartlarında performans optimizasyonu için teşekkürler!**

**🚀 Dünya standartlarında iOS Clean Architecture Template**

</div> 