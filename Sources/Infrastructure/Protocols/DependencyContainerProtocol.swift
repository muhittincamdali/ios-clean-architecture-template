import Foundation

/**
 * Dependency Container Protocol - Infrastructure Layer
 * 
 * Abstract interface for dependency injection operations.
 * Defines the contract for dependency container implementations.
 * 
 * - Author: iOS Clean Architecture Team
 * - Version: 2.0.0
 * - Date: 2024-01-15
 */

// MARK: - Dependency Container Protocol
protocol DependencyContainerProtocol {
    func register<T>(_ type: T.Type, factory: @escaping (DependencyContainerProtocol) -> T)
    func registerSingleton<T>(_ type: T.Type, factory: @escaping (DependencyContainerProtocol) -> T)
    func resolve<T>(_ type: T.Type) -> T?
    func resolve<T>(_ type: T.Type, name: String) -> T?
    func unregister<T>(_ type: T.Type)
    func unregister<T>(_ type: T.Type, name: String)
    func clear()
    func hasRegistration<T>(_ type: T.Type) -> Bool
    func hasRegistration<T>(_ type: T.Type, name: String) -> Bool
}

// MARK: - Dependency Container Error
enum DependencyContainerError: LocalizedError {
    case typeNotRegistered(String)
    case circularDependency(String)
    case factoryError(String)
    case resolutionError(String)
    case invalidType(String)
    case unknown(String)
    
    var errorDescription: String? {
        switch self {
        case .typeNotRegistered(let message):
            return "Type not registered: \(message)"
        case .circularDependency(let message):
            return "Circular dependency detected: \(message)"
        case .factoryError(let message):
            return "Factory error: \(message)"
        case .resolutionError(let message):
            return "Resolution error: \(message)"
        case .invalidType(let message):
            return "Invalid type: \(message)"
        case .unknown(let message):
            return "Unknown dependency container error: \(message)"
        }
    }
    
    var errorCode: Int {
        switch self {
        case .typeNotRegistered:
            return 12001
        case .circularDependency:
            return 12002
        case .factoryError:
            return 12003
        case .resolutionError:
            return 12004
        case .invalidType:
            return 12005
        case .unknown:
            return 12099
        }
    }
}

// MARK: - Dependency Container Configuration
struct DependencyContainerConfiguration {
    let enableCircularDependencyDetection: Bool
    let enableLazyResolution: Bool
    let enableThreadSafety: Bool
    let maxResolutionDepth: Int
    let enableLogging: Bool
    let enableValidation: Bool
    
    init(
        enableCircularDependencyDetection: Bool = true,
        enableLazyResolution: Bool = true,
        enableThreadSafety: Bool = true,
        maxResolutionDepth: Int = 10,
        enableLogging: Bool = true,
        enableValidation: Bool = true
    ) {
        self.enableCircularDependencyDetection = enableCircularDependencyDetection
        self.enableLazyResolution = enableLazyResolution
        self.enableThreadSafety = enableThreadSafety
        self.maxResolutionDepth = maxResolutionDepth
        self.enableLogging = enableLogging
        self.enableValidation = enableValidation
    }
}

// MARK: - Dependency Container Statistics
struct DependencyContainerStatistics {
    let totalRegistrations: Int
    let singletonRegistrations: Int
    let factoryRegistrations: Int
    let totalResolutions: Int
    let successfulResolutions: Int
    let failedResolutions: Int
    let circularDependencyDetections: Int
    let timestamp: Date
    
    init(
        totalRegistrations: Int = 0,
        singletonRegistrations: Int = 0,
        factoryRegistrations: Int = 0,
        totalResolutions: Int = 0,
        successfulResolutions: Int = 0,
        failedResolutions: Int = 0,
        circularDependencyDetections: Int = 0
    ) {
        self.totalRegistrations = totalRegistrations
        self.singletonRegistrations = singletonRegistrations
        self.factoryRegistrations = factoryRegistrations
        self.totalResolutions = totalResolutions
        self.successfulResolutions = successfulResolutions
        self.failedResolutions = failedResolutions
        self.circularDependencyDetections = circularDependencyDetections
        self.timestamp = Date()
    }
}

// MARK: - Dependency Container Extensions
extension DependencyContainerProtocol {
    
    // MARK: - Convenience Methods
    func register<T>(_ type: T.Type, instance: T) {
        register(type) { _ in instance }
    }
    
    func register<T>(_ type: T.Type, name: String, factory: @escaping (DependencyContainerProtocol) -> T) {
        // This would need to be implemented based on the specific dependency container implementation
    }
    
    func register<T>(_ type: T.Type, name: String, instance: T) {
        // This would need to be implemented based on the specific dependency container implementation
    }
    
    func resolve<T>(_ type: T.Type) throws -> T {
        guard let instance = resolve(type) else {
            throw DependencyContainerError.typeNotRegistered("\(type)")
        }
        return instance
    }
    
    func resolve<T>(_ type: T.Type, name: String) throws -> T {
        guard let instance = resolve(type, name: name) else {
            throw DependencyContainerError.typeNotRegistered("\(type) with name: \(name)")
        }
        return instance
    }
    
    func autoRegister() {
        // Auto-register common dependencies
        registerCommonDependencies()
        registerUseCases()
        registerRepositories()
        registerServices()
    }
    
    func registerCommonDependencies() {
        // Register common infrastructure dependencies
        register(LoggerProtocol.self) { container in
            Logger()
        }
        
        register(AnalyticsServiceProtocol.self) { container in
            AnalyticsService()
        }
        
        register(NetworkMonitorProtocol.self) { container in
            NetworkMonitor()
        }
        
        register(CacheManagerProtocol.self) { container in
            CacheManager()
        }
        
        register(SecureStorageProtocol.self) { container in
            SecureStorage()
        }
        
        register(PerformanceMonitorProtocol.self) { container in
            PerformanceMonitor()
        }
        
        register(APIServiceProtocol.self) { container in
            APIService()
        }
    }
    
    func registerUseCases() {
        // Register use cases
        register(GetUserUseCaseProtocol.self) { container in
            GetUserUseCase(
                repository: container.resolve(UserRepositoryProtocol.self)!,
                validator: container.resolve(UserValidatorProtocol.self)!,
                cacheManager: container.resolve(CacheManagerProtocol.self),
                analyticsService: container.resolve(AnalyticsServiceProtocol.self),
                logger: container.resolve(LoggerProtocol.self)
            )
        }
        
        register(GetUsersUseCaseProtocol.self) { container in
            GetUsersUseCase(
                repository: container.resolve(UserRepositoryProtocol.self)!,
                validator: container.resolve(UserValidatorProtocol.self)!,
                cacheManager: container.resolve(CacheManagerProtocol.self),
                analyticsService: container.resolve(AnalyticsServiceProtocol.self),
                logger: container.resolve(LoggerProtocol.self)
            )
        }
    }
    
    func registerRepositories() {
        // Register repositories
        register(UserRepositoryProtocol.self) { container in
            UserRepository(
                remoteDataSource: container.resolve(UserRemoteDataSourceProtocol.self)!,
                localDataSource: container.resolve(UserLocalDataSourceProtocol.self)!,
                cacheManager: container.resolve(CacheManagerProtocol.self),
                networkMonitor: container.resolve(NetworkMonitorProtocol.self),
                logger: container.resolve(LoggerProtocol.self)
            )
        }
    }
    
    func registerServices() {
        // Register services
        register(UserValidatorProtocol.self) { container in
            UserValidator(
                userRepository: container.resolve(UserRepositoryProtocol.self),
                logger: container.resolve(LoggerProtocol.self)
            )
        }
        
        register(UserRemoteDataSourceProtocol.self) { container in
            UserRemoteDataSource(
                apiService: container.resolve(APIServiceProtocol.self)!,
                logger: container.resolve(LoggerProtocol.self)
            )
        }
        
        register(UserLocalDataSourceProtocol.self) { container in
            UserLocalDataSource(
                secureStorage: container.resolve(SecureStorageProtocol.self)!,
                logger: container.resolve(LoggerProtocol.self)
            )
        }
    }
    
    func getStatistics() -> DependencyContainerStatistics {
        // This would typically return actual statistics
        return DependencyContainerStatistics()
    }
    
    func validateRegistrations() throws {
        // This would validate all registrations and check for circular dependencies
    }
    
    func getRegisteredTypes() -> [String] {
        // This would return a list of all registered types
        return []
    }
    
    func getRegistrationInfo<T>(_ type: T.Type) -> String? {
        // This would return information about a specific registration
        return nil
    }
}

// MARK: - Dependency Container Categories
extension DependencyContainerProtocol {
    
    struct Category {
        static let di = "DependencyInjection"
        static let container = "Container"
        static let registration = "Registration"
        static let resolution = "Resolution"
    }
} 