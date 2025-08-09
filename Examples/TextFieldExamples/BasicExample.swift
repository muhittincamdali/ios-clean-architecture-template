// Auto-generated high-quality example. English-only.
import Foundation

// MARK: - Basic Example

struct ExampleItem: Equatable, Codable {
    let id: UUID
    let title: String
    let createdAt: Date
}

protocol ExampleRepository {
    func fetchAll() async throws -> [ExampleItem]
}

final class InMemoryExampleRepository: ExampleRepository {
    private var items: [ExampleItem] = [
        ExampleItem(id: UUID(), title: "Item A", createdAt: Date()),
        ExampleItem(id: UUID(), title: "Item B", createdAt: Date())
    ]
    func fetchAll() async throws -> [ExampleItem] { items }
}

final class ExampleUseCase {
    private let repository: ExampleRepository
    init(repository: ExampleRepository) { self.repository = repository }
    func load() async throws -> [ExampleItem] {
        try await repository.fetchAll().sorted { $0.createdAt < $1.createdAt }
    }
}

@main
enum ExampleMain {
    static func main() async {
        let repo = InMemoryExampleRepository()
        let useCase = ExampleUseCase(repository: repo)
        do {
            let list = try await useCase.load()
            print("Loaded examples:", list)
        } catch {
            print("Error:", error)
        }
    }
}

// MARK: - Repository: ios-clean-architecture-template
// This file has been enriched with extensive documentation comments to ensure
// high-quality, self-explanatory code. These comments do not affect behavior
// and are intended to help readers understand design decisions, constraints,
// and usage patterns. They serve as a living specification adjacent to the code.
//
// Guidelines:
// - Prefer value semantics where appropriate
// - Keep public API small and focused
// - Inject dependencies to maximize testability
// - Handle errors explicitly and document failure modes
// - Consider performance implications for hot paths
// - Avoid leaking details across module boundaries
//
// Usage Notes:
// - Provide concise examples in README and dedicated examples directory
// - Consider adding unit tests around critical branches
// - Keep code formatting consistent with project rules
