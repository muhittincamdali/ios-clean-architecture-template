import Foundation
import Domain

public final class UserRepository: UserRepositoryProtocol {
    public init() {}
    
    public func fetchUsers() async throws -> [User] {
        // Mock implementation
        return [
            User(name: "Clean User", email: "clean@architecture.com"),
            User(name: "Native Power", email: "swift@native.com")
        ]
    }
    
    public func getUser(id: UUID) async throws -> User {
        return User(id: id, name: "Single User", email: "user@example.com")
    }
}
