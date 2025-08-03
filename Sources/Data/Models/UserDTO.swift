import Foundation

/**
 * User DTO (Data Transfer Object) - Data Layer
 * 
 * This DTO represents the data structure for API communication.
 * It handles the transformation between Domain entities and API responses.
 * 
 * - Author: iOS Clean Architecture Team
 * - Version: 2.0.0
 * - Date: 2024-01-15
 */
struct UserDTO: Codable, Equatable {
    let id: String
    let name: String
    let email: String
    let avatarURL: String?
    let createdAt: String
    let updatedAt: String
    let isActive: Bool
    let role: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case email
        case avatarURL = "avatar_url"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case isActive = "is_active"
        case role
    }
    
    init(
        id: String,
        name: String,
        email: String,
        avatarURL: String? = nil,
        createdAt: String,
        updatedAt: String,
        isActive: Bool = true,
        role: String = "user"
    ) {
        self.id = id
        self.name = name
        self.email = email
        self.avatarURL = avatarURL
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.isActive = isActive
        self.role = role
    }
}

// MARK: - DTO Extensions
extension UserDTO {
    /// Convert DTO to Domain entity
    func toDomain() -> User {
        let dateFormatter = ISO8601DateFormatter()
        
        return User(
            id: id,
            name: name,
            email: email,
            avatarURL: avatarURL,
            createdAt: dateFormatter.date(from: createdAt) ?? Date(),
            updatedAt: dateFormatter.date(from: updatedAt) ?? Date(),
            isActive: isActive,
            role: UserRole(rawValue: role) ?? .user
        )
    }
}

extension User {
    /// Convert Domain entity to DTO
    func toDTO() -> UserDTO {
        let dateFormatter = ISO8601DateFormatter()
        
        return UserDTO(
            id: id,
            name: name,
            email: email,
            avatarURL: avatarURL,
            createdAt: dateFormatter.string(from: createdAt),
            updatedAt: dateFormatter.string(from: updatedAt),
            isActive: isActive,
            role: role.rawValue
        )
    }
}

// MARK: - API Response Models
struct UsersResponse: Codable {
    let users: [UserDTO]
    let total: Int
    let page: Int
    let limit: Int
    let hasMore: Bool
    
    enum CodingKeys: String, CodingKey {
        case users
        case total
        case page
        case limit
        case hasMore = "has_more"
    }
}

struct UserResponse: Codable {
    let user: UserDTO
    let success: Bool
    let message: String?
}

struct CreateUserRequest: Codable {
    let name: String
    let email: String
    let avatarURL: String?
    let role: String
    
    enum CodingKeys: String, CodingKey {
        case name
        case email
        case avatarURL = "avatar_url"
        case role
    }
}

struct UpdateUserRequest: Codable {
    let name: String?
    let email: String?
    let avatarURL: String?
    let isActive: Bool?
    let role: String?
    
    enum CodingKeys: String, CodingKey {
        case name
        case email
        case avatarURL = "avatar_url"
        case isActive = "is_active"
        case role
    }
} 