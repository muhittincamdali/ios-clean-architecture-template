import Foundation
import Combine

/**
 * Dependency Container - Infrastructure Layer
 * 
 * Professional dependency injection container with advanced features:
 * - Type-safe dependency registration
 * - Singleton and factory patterns
 * - Circular dependency detection
 * - Lifecycle management
 * - Thread safety
 * - Memory management
 * 
 * - Author: iOS Clean Architecture Team
 * - Version: 2.0.0
 * - Date: 2024-01-15
 */

// MARK: - Dependency Container Protocol
protocol DependencyContainerProtocol {
    func register<T>(_ type: T.Type, factory: @escaping (DependencyContainer) -> T)
    func registerSingleton<T>(_ type: T.Type, factory: @escaping (DependencyContainer) -> T)
    func resolve<T>(_ type: T.Type) -> T?
    func resolve<T>(_ type: T.Type, name: String) -> T?
    func unregister<T>(_ type: T.Type)
    func clear()
}

// MARK: - Dependency Container Implementation
class DependencyContainer: DependencyContainerProtocol {
    
    // MARK: - Properties
    private var factories: [String: DependencyFactory] = [:]
    private var singletons: [String: Any] = [:]
    private let queue = DispatchQueue(label: "com.ioscleanarchitecture.dependencycontainer", attributes: .concurrent)
    private var circularDependencyDetector = CircularDependencyDetector()
    
    // MARK: - Dependency Factory
    private struct DependencyFactory {
        let factory: (DependencyContainer) -> Any
        let isSingleton: Bool
        let type: Any.Type
    }
    
    // MARK: - Registration Methods
    func register<T>(_ type: T.Type, factory: @escaping (DependencyContainer) -> T) {
        let key = String(describing: type)
        let dependencyFactory = DependencyFactory(
            factory: factory,
            isSingleton: false,
            type: type
        )
        
        queue.async(flags: .barrier) {
            self.factories[key] = dependencyFactory
        }
    }
    
    func registerSingleton<T>(_ type: T.Type, factory: @escaping (DependencyContainer) -> T) {
        let key = String(describing: type)
        let dependencyFactory = DependencyFactory(
            factory: factory,
            isSingleton: true,
            type: type
        )
        
        queue.async(flags: .barrier) {
            self.factories[key] = dependencyFactory
        }
    }
    
    func register<T>(_ type: T.Type, name: String, factory: @escaping (DependencyContainer) -> T) {
        let key = "\(String(describing: type))_\(name)"
        let dependencyFactory = DependencyFactory(
            factory: factory,
            isSingleton: false,
            type: type
        )
        
        queue.async(flags: .barrier) {
            self.factories[key] = dependencyFactory
        }
    }
    
    func registerSingleton<T>(_ type: T.Type, name: String, factory: @escaping (DependencyContainer) -> T) {
        let key = "\(String(describing: type))_\(name)"
        let dependencyFactory = DependencyFactory(
            factory: factory,
            isSingleton: true,
            type: type
        )
        
        queue.async(flags: .barrier) {
            self.factories[key] = dependencyFactory
        }
    }
    
    // MARK: - Resolution Methods
    func resolve<T>(_ type: T.Type) -> T? {
        let key = String(describing: type)
        return resolve(key: key)
    }
    
    func resolve<T>(_ type: T.Type, name: String) -> T? {
        let key = "\(String(describing: type))_\(name)"
        return resolve(key: key)
    }
    
    private func resolve<T>(key: String) -> T? {
        return queue.sync {
            // Check for circular dependency
            guard !circularDependencyDetector.isCircular(key: key) else {
                fatalError("Circular dependency detected for key: \(key)")
            }
            
            // Check if singleton already exists
            if let singleton = singletons[key] as? T {
                return singleton
            }
            
            // Get factory
            guard let factory = factories[key] else {
                return nil
            }
            
            // Create instance
            circularDependencyDetector.push(key: key)
            defer { circularDependencyDetector.pop() }
            
            guard let instance = factory.factory(self) as? T else {
                fatalError("Failed to create instance of type \(T.self) for key: \(key)")
            }
            
            // Store singleton if needed
            if factory.isSingleton {
                singletons[key] = instance
            }
            
            return instance
        }
    }
    
    // MARK: - Management Methods
    func unregister<T>(_ type: T.Type) {
        let key = String(describing: type)
        queue.async(flags: .barrier) {
            self.factories.removeValue(forKey: key)
            self.singletons.removeValue(forKey: key)
        }
    }
    
    func unregister<T>(_ type: T.Type, name: String) {
        let key = "\(String(describing: type))_\(name)"
        queue.async(flags: .barrier) {
            self.factories.removeValue(forKey: key)
            self.singletons.removeValue(forKey: key)
        }
    }
    
    func clear() {
        queue.async(flags: .barrier) {
            self.factories.removeAll()
            self.singletons.removeAll()
            self.circularDependencyDetector.clear()
        }
    }
    
    // MARK: - Utility Methods
    func hasRegistration<T>(_ type: T.Type) -> Bool {
        let key = String(describing: type)
        return queue.sync {
            return factories[key] != nil
        }
    }
    
    func hasRegistration<T>(_ type: T.Type, name: String) -> Bool {
        let key = "\(String(describing: type))_\(name)"
        return queue.sync {
            return factories[key] != nil
        }
    }
    
    func getRegisteredTypes() -> [String] {
        return queue.sync {
            return Array(factories.keys)
        }
    }
    
    func getSingletonTypes() -> [String] {
        return queue.sync {
            return Array(singletons.keys)
        }
    }
}

// MARK: - Circular Dependency Detector
private class CircularDependencyDetector {
    private var dependencyStack: [String] = []
    
    func push(key: String) {
        dependencyStack.append(key)
    }
    
    func pop() {
        _ = dependencyStack.popLast()
    }
    
    func isCircular(key: String) -> Bool {
        return dependencyStack.contains(key)
    }
    
    func clear() {
        dependencyStack.removeAll()
    }
}

// MARK: - Dependency Container Extensions
extension DependencyContainer {
    
    // MARK: - Auto Registration
    func autoRegister() {
        registerCommonDependencies()
        registerUseCases()
        registerRepositories()
        registerServices()
        registerViewModels()
    }
    
    private func registerCommonDependencies() {
        // Network Services
        registerSingleton(APIServiceProtocol.self) { container in
            APIService(baseURL: "https://api.example.com")
        }
        
        registerSingleton(NetworkMonitorProtocol.self) { _ in
            NetworkMonitor()
        }
        
        // Storage Services
        registerSingleton(StorageProtocol.self) { _ in
            KeychainStorage()
        }
        
        registerSingleton(CacheManagerProtocol.self) { _ in
            CacheManager()
        }
        
        // Analytics Services
        registerSingleton(AnalyticsServiceProtocol.self) { _ in
            AnalyticsService()
        }
        
        registerSingleton(PerformanceMonitorProtocol.self) { _ in
            PerformanceMonitor()
        }
        
        // Security Services
        registerSingleton(SecureStorageProtocol.self) { _ in
            SecureStorage()
        }
        
        // Design System
        registerSingleton(DesignSystemProtocol.self) { _ in
            DesignSystem()
        }
        
        // Localization
        registerSingleton(LocalizationManagerProtocol.self) { _ in
            LocalizationManager()
        }
        
        // Accessibility
        registerSingleton(AccessibilityManagerProtocol.self) { _ in
            AccessibilityManager()
        }
    }
    
    private func registerUseCases() {
        // User Use Cases
        register(GetUserUseCaseProtocol.self) { container in
            GetUserUseCase(
                repository: container.resolve(UserRepositoryProtocol.self)!,
                validator: UserValidator()
            )
        }
        
        register(GetUsersUseCaseProtocol.self) { container in
            GetUsersUseCase(
                repository: container.resolve(UserRepositoryProtocol.self)!
            )
        }
        
        register(CreateUserUseCaseProtocol.self) { container in
            CreateUserUseCase(
                repository: container.resolve(UserRepositoryProtocol.self)!,
                validator: UserValidator()
            )
        }
        
        register(UpdateUserUseCaseProtocol.self) { container in
            UpdateUserUseCase(
                repository: container.resolve(UserRepositoryProtocol.self)!,
                validator: UserValidator()
            )
        }
        
        register(DeleteUserUseCaseProtocol.self) { container in
            DeleteUserUseCase(
                repository: container.resolve(UserRepositoryProtocol.self)!
            )
        }
        
        register(SearchUsersUseCaseProtocol.self) { container in
            SearchUsersUseCase(
                repository: container.resolve(UserRepositoryProtocol.self)!
            )
        }
    }
    
    private func registerRepositories() {
        // User Repository
        register(UserRepositoryProtocol.self) { container in
            UserRepository(
                remoteDataSource: UserRemoteDataSource(
                    apiService: container.resolve(APIServiceProtocol.self)!,
                    apiConfig: APIConfig()
                ),
                localDataSource: UserLocalDataSource(
                    storage: container.resolve(StorageProtocol.self)!
                ),
                cacheManager: container.resolve(CacheManagerProtocol.self)!,
                networkMonitor: container.resolve(NetworkMonitorProtocol.self)!
            )
        }
    }
    
    private func registerServices() {
        // API Services
        register(APIConfigProtocol.self) { _ in
            APIConfig()
        }
        
        // Validation Services
        register(UserValidatorProtocol.self) { _ in
            UserValidator()
        }
    }
    
    private func registerViewModels() {
        // User View Models
        register(UserListViewModel.self) { container in
            UserListViewModel(
                getUserUseCase: container.resolve(GetUserUseCaseProtocol.self)!,
                getUsersUseCase: container.resolve(GetUsersUseCaseProtocol.self)!,
                createUserUseCase: container.resolve(CreateUserUseCaseProtocol.self)!,
                updateUserUseCase: container.resolve(UpdateUserUseCaseProtocol.self)!,
                deleteUserUseCase: container.resolve(DeleteUserUseCaseProtocol.self)!,
                searchUsersUseCase: container.resolve(SearchUsersUseCaseProtocol.self)!
            )
        }
        
        register(UserViewModel.self) { container in
            UserViewModel(
                getUserUseCase: container.resolve(GetUserUseCaseProtocol.self)!,
                updateUserUseCase: container.resolve(UpdateUserUseCaseProtocol.self)!,
                deleteUserUseCase: container.resolve(DeleteUserUseCaseProtocol.self)!
            )
        }
    }
}

// MARK: - Additional Protocols
protocol DesignSystemProtocol {
    func getColorPalette() -> ColorPalette
    func getTypography() -> Typography
    func getSpacing() -> Spacing
    func getAnimations() -> Animations
}

protocol LocalizationManagerProtocol {
    func localizedString(for key: String) -> String
    func localizedString(for key: String, arguments: CVarArg...) -> String
    func setLanguage(_ language: String)
    func getCurrentLanguage() -> String
}

protocol AccessibilityManagerProtocol {
    func isVoiceOverRunning() -> Bool
    func isReduceMotionEnabled() -> Bool
    func isReduceTransparencyEnabled() -> Bool
    func isBoldTextEnabled() -> Bool
    func isLargerTextEnabled() -> Bool
    func getPreferredContentSizeCategory() -> String
}

protocol SecureStorageProtocol {
    static func save(_ data: Data, forKey key: String) throws
    static func getData(forKey key: String) throws -> Data?
    static func delete(forKey key: String) throws
    static func clear() throws
}

// MARK: - Implementation Classes
class DesignSystem: DesignSystemProtocol {
    func getColorPalette() -> ColorPalette {
        return ColorPalette()
    }
    
    func getTypography() -> Typography {
        return Typography()
    }
    
    func getSpacing() -> Spacing {
        return Spacing()
    }
    
    func getAnimations() -> Animations {
        return Animations()
    }
}

class LocalizationManager: LocalizationManagerProtocol {
    private var currentLanguage = "en"
    
    func localizedString(for key: String) -> String {
        return NSLocalizedString(key, comment: "")
    }
    
    func localizedString(for key: String, arguments: CVarArg...) -> String {
        let format = localizedString(for: key)
        return String(format: format, arguments: arguments)
    }
    
    func setLanguage(_ language: String) {
        currentLanguage = language
    }
    
    func getCurrentLanguage() -> String {
        return currentLanguage
    }
}

class AccessibilityManager: AccessibilityManagerProtocol {
    func isVoiceOverRunning() -> Bool {
        return UIAccessibility.isVoiceOverRunning
    }
    
    func isReduceMotionEnabled() -> Bool {
        return UIAccessibility.isReduceMotionEnabled
    }
    
    func isReduceTransparencyEnabled() -> Bool {
        return UIAccessibility.isReduceTransparencyEnabled
    }
    
    func isBoldTextEnabled() -> Bool {
        return UIAccessibility.isBoldTextEnabled
    }
    
    func isLargerTextEnabled() -> Bool {
        return UIAccessibility.isLargerTextEnabled
    }
    
    func getPreferredContentSizeCategory() -> String {
        return UIAccessibility.preferredContentSizeCategory.rawValue
    }
}

class SecureStorage: SecureStorageProtocol {
    static func save(_ data: Data, forKey key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        if status == errSecDuplicateItem {
            let updateQuery: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrAccount as String: key
            ]
            
            let attributes: [String: Any] = [
                kSecValueData as String: data
            ]
            
            let updateStatus = SecItemUpdate(updateQuery as CFDictionary, attributes as CFDictionary)
            
            if updateStatus != errSecSuccess {
                throw SecureStorageError.saveFailed
            }
        } else if status != errSecSuccess {
            throw SecureStorageError.saveFailed
        }
    }
    
    static func getData(forKey key: String) throws -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        if status == errSecItemNotFound {
            return nil
        } else if status != errSecSuccess {
            throw SecureStorageError.retrieveFailed
        }
        
        return result as? Data
    }
    
    static func delete(forKey key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        
        if status != errSecSuccess && status != errSecItemNotFound {
            throw SecureStorageError.deleteFailed
        }
    }
    
    static func clear() throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        
        if status != errSecSuccess && status != errSecItemNotFound {
            throw SecureStorageError.deleteFailed
        }
    }
}

// MARK: - Error Types
enum SecureStorageError: LocalizedError {
    case saveFailed
    case retrieveFailed
    case deleteFailed
    
    var errorDescription: String? {
        switch self {
        case .saveFailed:
            return "Failed to save data to secure storage"
        case .retrieveFailed:
            return "Failed to retrieve data from secure storage"
        case .deleteFailed:
            return "Failed to delete data from secure storage"
        }
    }
}

// MARK: - Design System Classes
class ColorPalette {
    let primary = Color.blue
    let secondary = Color.gray
    let success = Color.green
    let warning = Color.orange
    let error = Color.red
}

class Typography {
    let title = Font.largeTitle
    let headline = Font.headline
    let body = Font.body
    let caption = Font.caption
}

class Spacing {
    let small: CGFloat = 8
    let medium: CGFloat = 16
    let large: CGFloat = 24
    let extraLarge: CGFloat = 32
}

class Animations {
    let spring = Animation.spring(response: 0.6, dampingFraction: 0.8)
    let easeInOut = Animation.easeInOut(duration: 0.3)
    let bounce = Animation.interpolatingSpring(stiffness: 100, damping: 10)
}
