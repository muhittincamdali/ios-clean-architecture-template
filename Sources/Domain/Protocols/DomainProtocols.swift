import Foundation

public protocol UserRepositoryProtocol: Sendable {
    func fetchUsers() async throws -> [User]
    func getUser(id: UUID) async throws -> User
}

public protocol GetUsersUseCaseProtocol: Sendable {
    func execute() async throws -> [User]
}
