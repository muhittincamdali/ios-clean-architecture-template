import SwiftUI
import Combine

/**
 * Basic Example - iOS Clean Architecture Template
 * 
 * Complete example application demonstrating:
 * - Clean Architecture implementation
 * - Dependency Injection
 * - MVVM pattern
 * - SwiftUI integration
 * - Error handling
 * - Loading states
 * - Animations
 * 
 * - Author: iOS Clean Architecture Team
 * - Version: 2.0.0
 * - Date: 2024-01-15
 */

// MARK: - Basic Example App
@main
struct BasicExampleApp: App {
    
    // MARK: - Dependency Container
    private let dependencyContainer: DependencyContainer
    
    // MARK: - Initialization
    init() {
        self.dependencyContainer = DependencyContainer()
        setupDependencies()
    }
    
    // MARK: - Body
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(dependencyContainer)
        }
    }
    
    // MARK: - Setup Dependencies
    private func setupDependencies() {
        // Register repositories
        dependencyContainer.register(UserRepositoryProtocol.self) { container in
            UserRepository(
                remoteDataSource: UserRemoteDataSource(
                    apiService: APIService(baseURL: "https://api.example.com"),
                    apiConfig: APIConfig()
                ),
                localDataSource: UserLocalDataSource(
                    storage: KeychainStorage()
                ),
                cacheManager: CacheManager(),
                networkMonitor: NetworkMonitor()
            )
        }
        
        // Register use cases
        dependencyContainer.register(GetUserUseCaseProtocol.self) { container in
            GetUserUseCase(
                repository: container.resolve(UserRepositoryProtocol.self),
                validator: UserValidator()
            )
        }
        
        dependencyContainer.register(GetUsersUseCaseProtocol.self) { container in
            GetUsersUseCase(
                repository: container.resolve(UserRepositoryProtocol.self)
            )
        }
        
        dependencyContainer.register(CreateUserUseCaseProtocol.self) { container in
            CreateUserUseCase(
                repository: container.resolve(UserRepositoryProtocol.self),
                validator: UserValidator()
            )
        }
        
        dependencyContainer.register(UpdateUserUseCaseProtocol.self) { container in
            UpdateUserUseCase(
                repository: container.resolve(UserRepositoryProtocol.self),
                validator: UserValidator()
            )
        }
        
        dependencyContainer.register(DeleteUserUseCaseProtocol.self) { container in
            DeleteUserUseCase(
                repository: container.resolve(UserRepositoryProtocol.self)
            )
        }
        
        dependencyContainer.register(SearchUsersUseCaseProtocol.self) { container in
            SearchUsersUseCase(
                repository: container.resolve(UserRepositoryProtocol.self)
            )
        }
        
        // Register view models
        dependencyContainer.register(UserListViewModel.self) { container in
            UserListViewModel(
                getUserUseCase: container.resolve(GetUserUseCaseProtocol.self),
                getUsersUseCase: container.resolve(GetUsersUseCaseProtocol.self),
                createUserUseCase: container.resolve(CreateUserUseCaseProtocol.self),
                updateUserUseCase: container.resolve(UpdateUserUseCaseProtocol.self),
                deleteUserUseCase: container.resolve(DeleteUserUseCaseProtocol.self),
                searchUsersUseCase: container.resolve(SearchUsersUseCaseProtocol.self)
            )
        }
        
        // Register services
        dependencyContainer.register(AnalyticsServiceProtocol.self) { _ in
            AnalyticsService()
        }
        
        dependencyContainer.register(PerformanceMonitorProtocol.self) { _ in
            PerformanceMonitor()
        }
        
        dependencyContainer.register(CacheManagerProtocol.self) { _ in
            CacheManager()
        }
    }
}

// MARK: - Content View
struct ContentView: View {
    @EnvironmentObject private var dependencyContainer: DependencyContainer
    @StateObject private var userListViewModel: UserListViewModel
    
    // MARK: - Initialization
    init() {
        // This will be properly initialized in onAppear
        self._userListViewModel = StateObject(wrappedValue: UserListViewModel(
            getUserUseCase: MockGetUserUseCase(),
            getUsersUseCase: MockGetUsersUseCase(),
            createUserUseCase: MockCreateUserUseCase(),
            updateUserUseCase: MockUpdateUserUseCase(),
            deleteUserUseCase: MockDeleteUserUseCase(),
            searchUsersUseCase: MockSearchUsersUseCase()
        ))
    }
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // MARK: - Header
                headerSection
                
                // MARK: - Main Content
                mainContentSection
            }
            .navigationBarHidden(true)
        }
        .onAppear {
            setupViewModel()
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 16) {
            // App Title
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("iOS Clean Architecture")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Template Example")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Settings Button
                Button(action: {
                    // Settings action
                }) {
                    Image(systemName: "gearshape.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal)
            
            // Feature Cards
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    FeatureCard(
                        icon: "building.2",
                        title: "Clean Architecture",
                        description: "Domain, Data, Presentation layers"
                    )
                    
                    FeatureCard(
                        icon: "shield.checkered",
                        title: "SOLID Principles",
                        description: "Single responsibility, dependency inversion"
                    )
                    
                    FeatureCard(
                        icon: "bolt.fill",
                        title: "Performance",
                        description: "Optimized for speed and efficiency"
                    )
                    
                    FeatureCard(
                        icon: "paintbrush.fill",
                        title: "Premium UI/UX",
                        description: "Beautiful and intuitive design"
                    )
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical)
        .background(Color(.systemBackground))
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    // MARK: - Main Content Section
    private var mainContentSection: some View {
        VStack(spacing: 0) {
            // Tab Bar
            CustomTabBar(selectedTab: $selectedTab)
            
            // Tab Content
            TabView(selection: $selectedTab) {
                // Users Tab
                UserListView(viewModel: userListViewModel)
                    .tag(Tab.users)
                
                // Analytics Tab
                AnalyticsView()
                    .tag(Tab.analytics)
                
                // Settings Tab
                SettingsView()
                    .tag(Tab.settings)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        }
    }
    
    // MARK: - Properties
    @State private var selectedTab: Tab = .users
    
    // MARK: - Private Methods
    private func setupViewModel() {
        // Get the properly configured view model from dependency container
        if let configuredViewModel = dependencyContainer.resolve(UserListViewModel.self) {
            // Update the StateObject with the configured view model
            // Note: In a real app, you'd handle this differently
            // This is a simplified example
        }
    }
}

// MARK: - Feature Card
struct FeatureCard: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Icon
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(.blue)
                .frame(width: 40, height: 40)
                .background(Color.blue.opacity(0.1))
                .clipShape(Circle())
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(16)
        .frame(width: 160, height: 120)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Custom Tab Bar
struct CustomTabBar: View {
    @Binding var selectedTab: Tab
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(Tab.allCases, id: \.self) { tab in
                TabButton(
                    tab: tab,
                    isSelected: selectedTab == tab
                ) {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        selectedTab = tab
                    }
                }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: -1)
    }
}

// MARK: - Tab Button
struct TabButton: View {
    let tab: Tab
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: isSelected ? tab.selectedIcon : tab.icon)
                    .font(.system(size: 20))
                    .foregroundColor(isSelected ? .blue : .secondary)
                
                Text(tab.title)
                    .font(.caption)
                    .fontWeight(isSelected ? .semibold : .medium)
                    .foregroundColor(isSelected ? .blue : .secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.blue.opacity(0.1) : Color.clear)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Tab Enum
enum Tab: CaseIterable {
    case users
    case analytics
    case settings
    
    var title: String {
        switch self {
        case .users:
            return "Users"
        case .analytics:
            return "Analytics"
        case .settings:
            return "Settings"
        }
    }
    
    var icon: String {
        switch self {
        case .users:
            return "person.3"
        case .analytics:
            return "chart.bar"
        case .settings:
            return "gearshape"
        }
    }
    
    var selectedIcon: String {
        switch self {
        case .users:
            return "person.3.fill"
        case .analytics:
            return "chart.bar.fill"
        case .settings:
            return "gearshape.fill"
        }
    }
}

// MARK: - Analytics View
struct AnalyticsView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Analytics Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Analytics Dashboard")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Track your app performance and user behavior")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                
                // Metrics Cards
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
                    MetricCard(
                        title: "Total Users",
                        value: "1,234",
                        change: "+12%",
                        isPositive: true
                    )
                    
                    MetricCard(
                        title: "Active Users",
                        value: "892",
                        change: "+8%",
                        isPositive: true
                    )
                    
                    MetricCard(
                        title: "Revenue",
                        value: "$12,345",
                        change: "+15%",
                        isPositive: true
                    )
                    
                    MetricCard(
                        title: "Churn Rate",
                        value: "2.3%",
                        change: "-0.5%",
                        isPositive: true
                    )
                }
                .padding(.horizontal)
                
                // Chart Placeholder
                ChartPlaceholder()
                    .padding(.horizontal)
            }
            .padding(.vertical)
        }
    }
}

// MARK: - Metric Card
struct MetricCard: View {
    let title: String
    let value: String
    let change: String
    let isPositive: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Title
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            
            // Value
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            // Change
            HStack(spacing: 4) {
                Image(systemName: isPositive ? "arrow.up" : "arrow.down")
                    .font(.caption)
                    .foregroundColor(isPositive ? .green : .red)
                
                Text(change)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(isPositive ? .green : .red)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Chart Placeholder
struct ChartPlaceholder: View {
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("User Growth")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button("View Details") {
                    // Action
                }
                .font(.caption)
                .foregroundColor(.blue)
            }
            
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.systemGray6))
                .frame(height: 200)
                .overlay(
                    VStack {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .font(.system(size: 40))
                            .foregroundColor(.secondary)
                        
                        Text("Chart data will appear here")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                )
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Settings View
struct SettingsView: View {
    @State private var isDarkMode = false
    @State private var notificationsEnabled = true
    @State private var analyticsEnabled = true
    @State private var selectedLanguage = "English"
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Settings Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Settings")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Customize your app experience")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                
                // Settings Sections
                VStack(spacing: 16) {
                    // Appearance
                    SettingsSection(title: "Appearance") {
                        SettingsRow(
                            icon: "moon.fill",
                            title: "Dark Mode",
                            subtitle: "Switch between light and dark themes"
                        ) {
                            Toggle("", isOn: $isDarkMode)
                                .labelsHidden()
                        }
                    }
                    
                    // Notifications
                    SettingsSection(title: "Notifications") {
                        SettingsRow(
                            icon: "bell.fill",
                            title: "Push Notifications",
                            subtitle: "Receive updates and alerts"
                        ) {
                            Toggle("", isOn: $notificationsEnabled)
                                .labelsHidden()
                        }
                    }
                    
                    // Privacy
                    SettingsSection(title: "Privacy & Analytics") {
                        SettingsRow(
                            icon: "chart.bar.fill",
                            title: "Analytics",
                            subtitle: "Help improve the app with usage data"
                        ) {
                            Toggle("", isOn: $analyticsEnabled)
                                .labelsHidden()
                        }
                    }
                    
                    // Language
                    SettingsSection(title: "Language") {
                        SettingsRow(
                            icon: "globe",
                            title: "Language",
                            subtitle: "Choose your preferred language"
                        ) {
                            Menu(selectedLanguage) {
                                Button("English") { selectedLanguage = "English" }
                                Button("Spanish") { selectedLanguage = "Spanish" }
                                Button("French") { selectedLanguage = "French" }
                                Button("German") { selectedLanguage = "German" }
                            }
                            .foregroundColor(.blue)
                        }
                    }
                    
                    // About
                    SettingsSection(title: "About") {
                        SettingsRow(
                            icon: "info.circle.fill",
                            title: "Version",
                            subtitle: "iOS Clean Architecture Template v2.0.0"
                        )
                        
                        SettingsRow(
                            icon: "doc.text.fill",
                            title: "Terms of Service",
                            subtitle: "Read our terms and conditions"
                        )
                        
                        SettingsRow(
                            icon: "hand.raised.fill",
                            title: "Privacy Policy",
                            subtitle: "Learn about data collection"
                        )
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
    }
}

// MARK: - Settings Section
struct SettingsSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            VStack(spacing: 0) {
                content
            }
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
    }
}

// MARK: - Settings Row
struct SettingsRow<Content: View>: View {
    let icon: String
    let title: String
    let subtitle: String
    let content: Content
    
    init(icon: String, title: String, subtitle: String, @ViewBuilder content: () -> Content) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.content = content()
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Icon
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.blue)
                .frame(width: 24, height: 24)
            
            // Text
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Content
            content
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

// MARK: - Dependency Container
class DependencyContainer: ObservableObject {
    private var dependencies: [String: Any] = [:]
    
    func register<T>(_ type: T.Type, factory: @escaping (DependencyContainer) -> T) {
        let key = String(describing: type)
        dependencies[key] = factory(self)
    }
    
    func resolve<T>(_ type: T.Type) -> T? {
        let key = String(describing: type)
        return dependencies[key] as? T
    }
}

// MARK: - Additional Protocols and Classes
protocol APIConfigProtocol {
    var baseURL: String { get }
    var timeout: TimeInterval { get }
}

class APIConfig: APIConfigProtocol {
    let baseURL = "https://api.example.com"
    let timeout: TimeInterval = 30.0
}

class NetworkMonitor: NetworkMonitorProtocol {
    var isConnected: Bool = true
    
    func startMonitoring() {
        // Implementation
    }
    
    func stopMonitoring() {
        // Implementation
    }
}

protocol NetworkMonitorProtocol {
    var isConnected: Bool { get }
    func startMonitoring()
    func stopMonitoring()
}

class CacheManager: CacheManagerProtocol {
    private var cache: [String: (data: Data, expiration: Date)] = [:]
    
    func get<T: Codable>(forKey key: String) async throws -> T? {
        guard let cached = cache[key], cached.expiration > Date() else {
            return nil
        }
        
        return try JSONDecoder().decode(T.self, from: cached.data)
    }
    
    func set<T: Codable>(_ value: T, forKey key: String, expiration: TimeInterval) async throws {
        let data = try JSONEncoder().encode(value)
        let expirationDate = Date().addingTimeInterval(expiration)
        cache[key] = (data: data, expiration: expirationDate)
    }
    
    func remove(forKey key: String) async throws {
        cache.removeValue(forKey: key)
    }
    
    func clear() async throws {
        cache.removeAll()
    }
}

class AnalyticsService: AnalyticsServiceProtocol {
    func trackEvent(_ event: String, parameters: [String: Any]?) {
        // Implementation
    }
    
    func trackScreen(_ screen: String) {
        // Implementation
    }
    
    func trackError(_ error: Error) {
        // Implementation
    }
}

class PerformanceMonitor: PerformanceMonitorProtocol {
    func recordAPICall(endpoint: String, duration: TimeInterval, success: Bool) {
        // Implementation
    }
    
    func recordMemoryUsage(_ usage: Int64) {
        // Implementation
    }
    
    func recordBatteryUsage(_ usage: Double) {
        // Implementation
    }
}

class KeychainStorage: StorageProtocol {
    func save(_ data: Data, forKey key: String) throws {
        // Implementation
    }
    
    func getData(forKey key: String) throws -> Data? {
        // Implementation
        return nil
    }
    
    func delete(forKey key: String) throws {
        // Implementation
    }
    
    func getKeys(matching pattern: String) throws -> [String] {
        // Implementation
        return []
    }
}

protocol StorageProtocol {
    func save(_ data: Data, forKey key: String) throws
    func getData(forKey key: String) throws -> Data?
    func delete(forKey key: String) throws
    func getKeys(matching pattern: String) throws -> [String]
}

// MARK: - Preview
struct BasicExampleApp_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(DependencyContainer())
    }
}
