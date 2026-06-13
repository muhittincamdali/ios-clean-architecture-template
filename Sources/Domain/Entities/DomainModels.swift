import Foundation

public struct User: Codable, Identifiable, Equatable, Sendable {
    public let id: UUID
    public let name: String
    public let email: String
    
    public init(id: UUID = UUID(), name: String, email: String) {
        self.id = id
        self.name = name
        self.email = email
    }
}

public enum DomainError: LocalizedError, Sendable {
    case notFound
    case networkError(Error)
    case validationError(String)
    
    public var errorDescription: String? {
        switch self {
        case .notFound: return "Requested resource not found"
        case .networkError(let error): return "Network error: \(error.localizedDescription)"
        case .validationError(let msg): return msg
        }
    }
}
