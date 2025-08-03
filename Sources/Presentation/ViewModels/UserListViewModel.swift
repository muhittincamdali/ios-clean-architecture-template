import SwiftUI
import Combine

/**
 * User List View Model - Presentation Layer
 * 
 * Professional MVVM view model implementation with advanced features:
 * - Reactive programming with Combine
 * - State management
 * - Error handling
 * - Loading states
 * - Search and filtering
 * - Pagination
 * - Analytics tracking
 * 
 * - Author: iOS Clean Architecture Team
 * - Version: 2.0.0
 * - Date: 2024-01-15
 */

// MARK: - User List View Model
@MainActor
class UserListViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var users: [User] = []
    @Published var isLoading = false
    @Published var error: Error?
    @Published var searchQuery = ""
    @Published var selectedFilter: UserFilter = .all
    @Published var isRefreshing = false
    @Published var hasMoreData = true
    @Published var currentPage = 0
    
    // MARK: - Private Properties
    private let getUserUseCase: GetUserUseCaseProtocol
    private let getUsersUseCase: GetUsersUseCaseProtocol
    private let createUserUseCase: CreateUserUseCaseProtocol
    private let updateUserUseCase: UpdateUserUseCaseProtocol
    private let deleteUserUseCase: DeleteUserUseCaseProtocol
    private let searchUsersUseCase: SearchUsersUseCaseProtocol
    private let analyticsService: AnalyticsServiceProtocol
    private let performanceMonitor: PerformanceMonitorProtocol
    
    // MARK: - Combine Properties
    private var cancellables = Set<AnyCancellable>()
    private let searchSubject = PassthroughSubject<String, Never>()
    private let filterSubject = PassthroughSubject<UserFilter, Never>()
    
    // MARK: - Constants
    private let pageSize = 20
    private let searchDebounceTime: TimeInterval = 0.5
    
    // MARK: - Initialization
    init(
        getUserUseCase: GetUserUseCaseProtocol,
        getUsersUseCase: GetUsersUseCaseProtocol,
        createUserUseCase: CreateUserUseCaseProtocol,
        updateUserUseCase: UpdateUserUseCaseProtocol,
        deleteUserUseCase: DeleteUserUseCaseProtocol,
        searchUsersUseCase: SearchUsersUseCaseProtocol,
        analyticsService: AnalyticsServiceProtocol = AnalyticsService(),
        performanceMonitor: PerformanceMonitorProtocol = PerformanceMonitor()
    ) {
        self.getUserUseCase = getUserUseCase
        self.getUsersUseCase = getUsersUseCase
        self.createUserUseCase = createUserUseCase
        self.updateUserUseCase = updateUserUseCase
        self.deleteUserUseCase = deleteUserUseCase
        self.searchUsersUseCase = searchUsersUseCase
        self.analyticsService = analyticsService
        self.performanceMonitor = performanceMonitor
        
        setupBindings()
        setupAnalytics()
    }
    
    // MARK: - Public Methods
    func loadUsers() async {
        await loadUsers(reset: true)
    }
    
    func loadMoreUsers() async {
        guard hasMoreData && !isLoading else { return }
        await loadUsers(reset: false)
    }
    
    func searchUsers(query: String) async {
        searchQuery = query
        
        if query.isEmpty {
            await loadUsers(reset: true)
        } else {
            await performSearch(query: query)
        }
    }
    
    func filterUsers(by filter: UserFilter) async {
        selectedFilter = filter
        await applyFilter(filter)
    }
    
    func createUser(_ user: User) async {
        isLoading = true
        error = nil
        
        do {
            let createdUser = try await createUserUseCase.execute(user: user)
            users.insert(createdUser, at: 0)
            
            analyticsService.trackEvent("user_created", parameters: [
                "user_id": createdUser.id,
                "user_role": createdUser.role.rawValue
            ])
            
        } catch {
            self.error = error
            analyticsService.trackError(error)
        }
        
        isLoading = false
    }
    
    func updateUser(_ user: User) async {
        isLoading = true
        error = nil
        
        do {
            let updatedUser = try await updateUserUseCase.execute(user: user)
            
            if let index = users.firstIndex(where: { $0.id == updatedUser.id }) {
                users[index] = updatedUser
            }
            
            analyticsService.trackEvent("user_updated", parameters: [
                "user_id": updatedUser.id,
                "user_role": updatedUser.role.rawValue
            ])
            
        } catch {
            self.error = error
            analyticsService.trackError(error)
        }
        
        isLoading = false
    }
    
    func deleteUser(id: String) async {
        isLoading = true
        error = nil
        
        do {
            try await deleteUserUseCase.execute(id: id)
            users.removeAll { $0.id == id }
            
            analyticsService.trackEvent("user_deleted", parameters: [
                "user_id": id
            ])
            
        } catch {
            self.error = error
            analyticsService.trackError(error)
        }
        
        isLoading = false
    }
    
    func refreshUsers() async {
        isRefreshing = true
        currentPage = 0
        hasMoreData = true
        await loadUsers(reset: true)
        isRefreshing = false
    }
    
    func exportUsers() async {
        analyticsService.trackEvent("users_exported", parameters: [
            "total_users": users.count,
            "filter": selectedFilter.rawValue
        ])
        
        // Export implementation
    }
    
    func retry() async {
        error = nil
        await loadUsers()
    }
    
    // MARK: - Private Methods
    private func setupBindings() {
        // Search debouncing
        searchSubject
            .debounce(for: .seconds(searchDebounceTime), scheduler: DispatchQueue.main)
            .sink { [weak self] query in
                Task {
                    await self?.performSearch(query: query)
                }
            }
            .store(in: &cancellables)
        
        // Filter changes
        filterSubject
            .sink { [weak self] filter in
                Task {
                    await self?.applyFilter(filter)
                }
            }
            .store(in: &cancellables)
    }
    
    private func setupAnalytics() {
        analyticsService.trackScreen("user_list")
    }
    
    private func loadUsers(reset: Bool) async {
        if reset {
            currentPage = 0
            hasMoreData = true
            users.removeAll()
        }
        
        isLoading = true
        error = nil
        
        do {
            let startTime = Date()
            
            let newUsers = try await getUsersUseCase.execute()
            
            let duration = Date().timeIntervalSince(startTime)
            performanceMonitor.recordAPICall(endpoint: "get_users", duration: duration, success: true)
            
            if reset {
                users = newUsers
            } else {
                users.append(contentsOf: newUsers)
            }
            
            hasMoreData = newUsers.count >= pageSize
            currentPage += 1
            
            analyticsService.trackEvent("users_loaded", parameters: [
                "count": newUsers.count,
                "page": currentPage,
                "filter": selectedFilter.rawValue
            ])
            
        } catch {
            self.error = error
            analyticsService.trackError(error)
            
            let duration = Date().timeIntervalSince(Date())
            performanceMonitor.recordAPICall(endpoint: "get_users", duration: duration, success: false)
        }
        
        isLoading = false
    }
    
    private func performSearch(query: String) async {
        guard !query.isEmpty else {
            await loadUsers(reset: true)
            return
        }
        
        isLoading = true
        error = nil
        
        do {
            let startTime = Date()
            
            let searchResults = try await searchUsersUseCase.execute(query: query)
            
            let duration = Date().timeIntervalSince(startTime)
            performanceMonitor.recordAPICall(endpoint: "search_users", duration: duration, success: true)
            
            users = searchResults
            
            analyticsService.trackEvent("users_searched", parameters: [
                "query": query,
                "results_count": searchResults.count
            ])
            
        } catch {
            self.error = error
            analyticsService.trackError(error)
            
            let duration = Date().timeIntervalSince(Date())
            performanceMonitor.recordAPICall(endpoint: "search_users", duration: duration, success: false)
        }
        
        isLoading = false
    }
    
    private func applyFilter(_ filter: UserFilter) async {
        guard filter != .all else {
            await loadUsers(reset: true)
            return
        }
        
        isLoading = true
        error = nil
        
        do {
            let startTime = Date()
            
            let filteredUsers = try await getUsersUseCase.execute()
            let filteredResults = filterUsers(users: filteredUsers, by: filter)
            
            let duration = Date().timeIntervalSince(startTime)
            performanceMonitor.recordAPICall(endpoint: "filter_users", duration: duration, success: true)
            
            users = filteredResults
            
            analyticsService.trackEvent("users_filtered", parameters: [
                "filter": filter.rawValue,
                "results_count": filteredResults.count
            ])
            
        } catch {
            self.error = error
            analyticsService.trackError(error)
            
            let duration = Date().timeIntervalSince(Date())
            performanceMonitor.recordAPICall(endpoint: "filter_users", duration: duration, success: false)
        }
        
        isLoading = false
    }
    
    private func filterUsers(users: [User], by filter: UserFilter) -> [User] {
        switch filter {
        case .all:
            return users
        case .active:
            return users.filter { $0.isActive }
        case .inactive:
            return users.filter { !$0.isActive }
        case .admin:
            return users.filter { $0.role == .admin }
        case .moderator:
            return users.filter { $0.role == .moderator }
        case .user:
            return users.filter { $0.role == .user }
        }
    }
}

// MARK: - User Filter
enum UserFilter: String, CaseIterable {
    case all = "all"
    case active = "active"
    case inactive = "inactive"
    case admin = "admin"
    case moderator = "moderator"
    case user = "user"
    
    var displayName: String {
        switch self {
        case .all:
            return "All"
        case .active:
            return "Active"
        case .inactive:
            return "Inactive"
        case .admin:
            return "Admin"
        case .moderator:
            return "Moderator"
        case .user:
            return "User"
        }
    }
    
    var icon: String {
        switch self {
        case .all:
            return "person.3"
        case .active:
            return "checkmark.circle"
        case .inactive:
            return "xmark.circle"
        case .admin:
            return "crown"
        case .moderator:
            return "shield"
        case .user:
            return "person"
        }
    }
}

// MARK: - View Model Extensions
extension UserListViewModel {
    
    // MARK: - Computed Properties
    var filteredUsers: [User] {
        guard selectedFilter != .all else { return users }
        return filterUsers(users: users, by: selectedFilter)
    }
    
    var isEmpty: Bool {
        return users.isEmpty && !isLoading
    }
    
    var canLoadMore: Bool {
        return hasMoreData && !isLoading && selectedFilter == .all
    }
    
    var userCount: Int {
        return users.count
    }
    
    var activeUserCount: Int {
        return users.filter { $0.isActive }.count
    }
    
    var adminCount: Int {
        return users.filter { $0.role == .admin }.count
    }
    
    var moderatorCount: Int {
        return users.filter { $0.role == .moderator }.count
    }
    
    var regularUserCount: Int {
        return users.filter { $0.role == .user }.count
    }
    
    // MARK: - Search Methods
    func searchUsers(query: String) {
        searchSubject.send(query)
    }
    
    func clearSearch() {
        searchQuery = ""
        searchSubject.send("")
    }
    
    // MARK: - Filter Methods
    func applyFilter(_ filter: UserFilter) {
        filterSubject.send(filter)
    }
    
    // MARK: - User Management
    func getUser(by id: String) -> User? {
        return users.first { $0.id == id }
    }
    
    func updateUserInList(_ user: User) {
        if let index = users.firstIndex(where: { $0.id == user.id }) {
            users[index] = user
        }
    }
    
    func removeUserFromList(id: String) {
        users.removeAll { $0.id == id }
    }
    
    // MARK: - Analytics Methods
    func trackUserInteraction(action: String, userId: String) {
        analyticsService.trackEvent("user_interaction", parameters: [
            "action": action,
            "user_id": userId
        ])
    }
    
    func trackFilterUsage(filter: UserFilter) {
        analyticsService.trackEvent("filter_used", parameters: [
            "filter": filter.rawValue
        ])
    }
    
    func trackSearchUsage(query: String) {
        analyticsService.trackEvent("search_used", parameters: [
            "query": query
        ])
    }
}

// MARK: - Error Handling
extension UserListViewModel {
    
    func handleError(_ error: Error) {
        self.error = error
        analyticsService.trackError(error)
    }
    
    func clearError() {
        error = nil
    }
    
    var errorMessage: String? {
        return error?.localizedDescription
    }
    
    var hasError: Bool {
        return error != nil
    }
}

// MARK: - Loading States
extension UserListViewModel {
    
    var isInitialLoading: Bool {
        return isLoading && users.isEmpty
    }
    
    var isPaginating: Bool {
        return isLoading && !users.isEmpty
    }
    
    var shouldShowLoadingIndicator: Bool {
        return isLoading || isRefreshing
    }
    
    var shouldShowEmptyState: Bool {
        return users.isEmpty && !isLoading && !hasError
    }
    
    var shouldShowErrorState: Bool {
        return hasError && users.isEmpty
    }
}

// MARK: - Performance Monitoring
extension UserListViewModel {
    
    func startPerformanceMonitoring() {
        performanceMonitor.recordMemoryUsage(Int64(ProcessInfo.processInfo.physicalMemory))
    }
    
    func endPerformanceMonitoring() {
        // End performance monitoring
    }
}

// MARK: - Preview Support
extension UserListViewModel {
    
    static func preview() -> UserListViewModel {
        let viewModel = UserListViewModel(
            getUserUseCase: MockGetUserUseCase(),
            getUsersUseCase: MockGetUsersUseCase(),
            createUserUseCase: MockCreateUserUseCase(),
            updateUserUseCase: MockUpdateUserUseCase(),
            deleteUserUseCase: MockDeleteUserUseCase(),
            searchUsersUseCase: MockSearchUsersUseCase()
        )
        
        // Add preview data
        viewModel.users = [
            User(id: "1", name: "John Doe", email: "john@example.com", role: .user),
            User(id: "2", name: "Jane Smith", email: "jane@example.com", role: .admin),
            User(id: "3", name: "Bob Johnson", email: "bob@example.com", role: .moderator)
        ]
        
        return viewModel
    }
}
