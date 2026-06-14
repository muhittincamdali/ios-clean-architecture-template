#!/usr/bin/env swift

import Foundation

let args = CommandLine.arguments
guard args.count > 1 else {
    print("Usage: ./generate_module.swift <ModuleName>")
    exit(1)
}

let moduleName = args[1]
print("🏛️ Generating Domain-Driven Design module: \(moduleName)")

let fileManager = FileManager.default
let basePath = URL(fileURLWithPath: fileManager.currentDirectoryPath)
    .appendingPathComponent("Sources")
    .appendingPathComponent("Domain")
    .appendingPathComponent(moduleName)

do {
    try fileManager.createDirectory(at: basePath, withIntermediateDirectories: true)
    
    // Entity
    let entityCode = """
    import Foundation
    
    public struct \(moduleName)Entity: Codable, Equatable, Sendable {
        public let id: UUID
        
        public init(id: UUID = UUID()) {
            self.id = id
        }
    }
    """
    try entityCode.write(to: basePath.appendingPathComponent("\(moduleName)Entity.swift"), atomically: true, encoding: .utf8)
    
    // Repository
    let repoCode = """
    import Foundation
    
    public protocol \(moduleName)Repository: Sendable {
        func fetch() async throws -> [\(moduleName)Entity]
        func save(_ entity: \(moduleName)Entity) async throws
    }
    """
    try repoCode.write(to: basePath.appendingPathComponent("\(moduleName)Repository.swift"), atomically: true, encoding: .utf8)
    
    // UseCase
    let useCaseCode = """
    import Foundation
    
    public struct Fetch\(moduleName)UseCase: Sendable {
        private let repository: any \(moduleName)Repository
        
        public init(repository: any \(moduleName)Repository) {
            self.repository = repository
        }
        
        public func execute() async throws -> [\(moduleName)Entity] {
            return try await repository.fetch()
        }
    }
    """
    try useCaseCode.write(to: basePath.appendingPathComponent("Fetch\(moduleName)UseCase.swift"), atomically: true, encoding: .utf8)
    
    print("✅ Successfully generated DDD layers for \(moduleName) in Sources/Domain/\(moduleName)")
} catch {
    print("❌ Error generating module: \(error.localizedDescription)")
    exit(1)
}
