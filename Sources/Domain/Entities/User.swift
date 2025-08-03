import Foundation

/**
 * User Entity - Domain Layer
 * 
 * Core business entity representing a user in the system.
 * Contains user information and business logic.
 * 
 * - Author: iOS Clean Architecture Team
 * - Version: 2.0.0
 * - Date: 2024-01-15
 */

// MARK: - User Entity
struct User: Codable, Identifiable, Equatable {
    
    // MARK: - Properties
    let id: String
    let name: String
    let email: String
    let role: UserRole
    let isActive: Bool
    let avatarURL: String?
    let createdAt: Date
    let updatedAt: Date
    
    // MARK: - Computed Properties
    var displayName: String {
        return name.isEmpty ? email : name
    }
    
    var isAdmin: Bool {
        return role == .admin
    }
    
    var isModerator: Bool {
        return role == .moderator || role == .admin
    }
    
    var canManageUsers: Bool {
        return role == .admin
    }
    
    var canDeleteContent: Bool {
        return role == .moderator || role == .admin
    }
    
    // MARK: - Initialization
    init(
        id: String,
        name: String,
        email: String,
        role: UserRole = .user,
        isActive: Bool = true,
        avatarURL: String? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.email = email
        self.role = role
        self.isActive = isActive
        self.avatarURL = avatarURL
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    // MARK: - Business Logic
    func canAccess(_ resource: String) -> Bool {
        switch resource {
        case "admin_panel":
            return role == .admin
        case "moderation_tools":
            return role == .moderator || role == .admin
        case "user_management":
            return role == .admin
        case "content_creation":
            return isActive
        default:
            return isActive
        }
    }
    
    func hasPermission(_ permission: UserPermission) -> Bool {
        switch permission {
        case .createContent:
            return isActive
        case .editOwnContent:
            return isActive
        case .deleteOwnContent:
            return isActive
        case .moderateContent:
            return role == .moderator || role == .admin
        case .manageUsers:
            return role == .admin
        case .accessAnalytics:
            return role == .admin
        case .systemSettings:
            return role == .admin
        }
    }
    
    func updateProfile(name: String, email: String) -> User {
        return User(
            id: self.id,
            name: name,
            email: email,
            role: self.role,
            isActive: self.isActive,
            avatarURL: self.avatarURL,
            createdAt: self.createdAt,
            updatedAt: Date()
        )
    }
    
    func deactivate() -> User {
        return User(
            id: self.id,
            name: self.name,
            email: self.email,
            role: self.role,
            isActive: false,
            avatarURL: self.avatarURL,
            createdAt: self.createdAt,
            updatedAt: Date()
        )
    }
    
    func activate() -> User {
        return User(
            id: self.id,
            name: self.name,
            email: self.email,
            role: self.role,
            isActive: true,
            avatarURL: self.avatarURL,
            createdAt: self.createdAt,
            updatedAt: Date()
        )
    }
    
    func changeRole(_ newRole: UserRole) -> User {
        return User(
            id: self.id,
            name: self.name,
            email: self.email,
            role: newRole,
            isActive: self.isActive,
            avatarURL: self.avatarURL,
            createdAt: self.createdAt,
            updatedAt: Date()
        )
    }
}

// MARK: - User Role
enum UserRole: String, Codable, CaseIterable {
    case user = "user"
    case moderator = "moderator"
    case admin = "admin"
    
    var displayName: String {
        switch self {
        case .user:
            return "User"
        case .moderator:
            return "Moderator"
        case .admin:
            return "Administrator"
        }
    }
    
    var priority: Int {
        switch self {
        case .user:
            return 1
        case .moderator:
            return 2
        case .admin:
            return 3
        }
    }
    
    var canManageRole: Bool {
        switch self {
        case .user:
            return false
        case .moderator:
            return false
        case .admin:
            return true
        }
    }
}

// MARK: - User Permission
enum UserPermission: String, Codable, CaseIterable {
    case createContent = "create_content"
    case editOwnContent = "edit_own_content"
    case deleteOwnContent = "delete_own_content"
    case moderateContent = "moderate_content"
    case manageUsers = "manage_users"
    case accessAnalytics = "access_analytics"
    case systemSettings = "system_settings"
    
    var displayName: String {
        switch self {
        case .createContent:
            return "Create Content"
        case .editOwnContent:
            return "Edit Own Content"
        case .deleteOwnContent:
            return "Delete Own Content"
        case .moderateContent:
            return "Moderate Content"
        case .manageUsers:
            return "Manage Users"
        case .accessAnalytics:
            return "Access Analytics"
        case .systemSettings:
            return "System Settings"
        }
    }
    
    var description: String {
        switch self {
        case .createContent:
            return "Allows user to create new content"
        case .editOwnContent:
            return "Allows user to edit their own content"
        case .deleteOwnContent:
            return "Allows user to delete their own content"
        case .moderateContent:
            return "Allows user to moderate all content"
        case .manageUsers:
            return "Allows user to manage other users"
        case .accessAnalytics:
            return "Allows user to access analytics data"
        case .systemSettings:
            return "Allows user to modify system settings"
        }
    }
}

// MARK: - User Validation
extension User {
    var isValid: Bool {
        return !id.isEmpty && 
               !name.isEmpty && 
               !email.isEmpty && 
               email.contains("@") &&
               email.contains(".")
    }
    
    var validationErrors: [String] {
        var errors: [String] = []
        
        if id.isEmpty {
            errors.append("User ID cannot be empty")
        }
        
        if name.isEmpty {
            errors.append("Name cannot be empty")
        }
        
        if email.isEmpty {
            errors.append("Email cannot be empty")
        } else if !email.contains("@") {
            errors.append("Email must contain @ symbol")
        } else if !email.contains(".") {
            errors.append("Email must contain domain")
        }
        
        return errors
    }
}

// MARK: - User Comparison
extension User {
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.id == rhs.id
    }
    
    static func < (lhs: User, rhs: User) -> Bool {
        return lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedAscending
    }
}

// MARK: - User Factory
struct UserFactory {
    static func createUser(
        name: String,
        email: String,
        role: UserRole = .user
    ) -> User {
        return User(
            id: UUID().uuidString,
            name: name,
            email: email,
            role: role
        )
    }
    
    static func createAdmin(
        name: String,
        email: String
    ) -> User {
        return User(
            id: UUID().uuidString,
            name: name,
            email: email,
            role: .admin
        )
    }
    
    static func createModerator(
        name: String,
        email: String
    ) -> User {
        return User(
            id: UUID().uuidString,
            name: name,
            email: email,
            role: .moderator
        )
    }
}
