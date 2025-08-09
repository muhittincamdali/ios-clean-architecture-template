// MARK: - Enterprise Example
// This example demonstrates enterprise-grade Clean Architecture implementation
// with microservices, complex business rules, and enterprise features

import Foundation
import SwiftUI
import Combine

// MARK: - Domain Layer

// MARK: - Enterprise Entities
struct EnterpriseUser: Identifiable, Codable {
    let id: String
    let employeeId: String
    let name: String
    let email: String
    let department: Department
    let role: UserRole
    let permissions: [Permission]
    let profile: EnterpriseUserProfile
    let settings: EnterpriseSettings
    let analytics: EnterpriseAnalytics
    let audit: AuditTrail
}

struct Department: Codable {
    let id: String
    let name: String
    let code: String
    let manager: String
    let location: OfficeLocation
    let budget: Budget
}

struct UserRole: Codable {
    let id: String
    let name: String
    let level: RoleLevel
    let permissions: [Permission]
    let responsibilities: [Responsibility]
}

struct Permission: Codable {
    let id: String
    let name: String
    let resource: String
    let action: PermissionAction
    let scope: PermissionScope
}

struct EnterpriseUserProfile: Codable {
    let avatar: String
    let bio: String
    let skills: [Skill]
    let certifications: [Certification]
    let projects: [Project]
    let performance: PerformanceMetrics
}

struct EnterpriseSettings: Codable {
    let security: SecuritySettings
    let notifications: EnterpriseNotificationSettings
    let integrations: IntegrationSettings
    let compliance: ComplianceSettings
}

struct EnterpriseAnalytics: Codable {
    let productivity: ProductivityMetrics
    let collaboration: CollaborationMetrics
    let security: SecurityMetrics
    let compliance: ComplianceMetrics
}

struct AuditTrail: Codable {
    let lastLogin: Date
    let loginHistory: [LoginEvent]
    let actionHistory: [AuditEvent]
    let securityEvents: [SecurityEvent]
}

// MARK: - Value Objects
enum RoleLevel: String, Codable {
    case intern, associate, senior, lead, manager, director, executive
}

enum PermissionAction: String, Codable {
    case read, write, delete, execute, approve, delegate
}

enum PermissionScope: String, Codable {
    case personal, team, department, organization, global
}

struct OfficeLocation: Codable {
    let building: String
    let floor: Int
    let room: String
    let city: String
    let country: String
}

struct Budget: Codable {
    let amount: Decimal
    let currency: String
    let period: BudgetPeriod
    let spent: Decimal
    let remaining: Decimal
}

struct Skill: Codable {
    let name: String
    let level: SkillLevel
    let certified: Bool
    let experience: Int // years
}

struct Certification: Codable {
    let name: String
    let issuer: String
    let issueDate: Date
    let expiryDate: Date?
    let status: CertificationStatus
}

struct Project: Codable {
    let id: String
    let name: String
    let role: String
    let startDate: Date
    let endDate: Date?
    let status: ProjectStatus
    let contribution: String
}

struct PerformanceMetrics: Codable {
    let rating: PerformanceRating
    let goals: [Goal]
    let achievements: [Achievement]
    let feedback: [Feedback]
}

struct SecuritySettings: Codable {
    let mfaEnabled: Bool
    let passwordPolicy: PasswordPolicy
    let sessionTimeout: TimeInterval
    let deviceRestrictions: DeviceRestrictions
}

struct EnterpriseNotificationSettings: Codable {
    let channels: [NotificationChannel]
    let schedules: [NotificationSchedule]
    let priorities: [NotificationPriority]
}

struct IntegrationSettings: Codable {
    let ssoEnabled: Bool
    let apiAccess: APIAccess
    let thirdPartyIntegrations: [ThirdPartyIntegration]
}

struct ComplianceSettings: Codable {
    let dataRetention: DataRetentionPolicy
    let privacySettings: PrivacySettings
    let regulatoryCompliance: [RegulatoryCompliance]
}

// MARK: - Additional Value Objects
enum SkillLevel: String, Codable {
    case beginner, intermediate, advanced, expert
}

enum CertificationStatus: String, Codable {
    case active, expired, pending, revoked
}

enum ProjectStatus: String, Codable {
    case planning, active, completed, onHold, cancelled
}

enum PerformanceRating: String, Codable {
    case outstanding, exceeds, meets, needsImprovement, unsatisfactory
}

enum BudgetPeriod: String, Codable {
    case monthly, quarterly, yearly
}

enum NotificationChannel: String, Codable {
    case email, push, sms, slack, teams
}

enum NotificationPriority: String, Codable {
    case low, normal, high, critical
}

enum NotificationSchedule: String, Codable {
    case immediate, daily, weekly, monthly
}

// MARK: - Enterprise Use Cases
protocol EnterpriseUserUseCase {
    func getUser(id: String) async throws -> EnterpriseUser
    func updateUser(_ user: EnterpriseUser) async throws
    func deleteUser(id: String) async throws
    func getUserAnalytics(id: String) async throws -> EnterpriseAnalytics
    func updateSettings(_ settings: EnterpriseSettings, for userId: String) async throws
    func updatePermissions(_ permissions: [Permission], for userId: String) async throws
    func trackAuditEvent(_ event: AuditEvent, for userId: String) async throws
    func validateCompliance(for userId: String) async throws -> ComplianceReport
    func generateSecurityReport(for userId: String) async throws -> SecurityReport
}

class GetEnterpriseUserUseCase: EnterpriseUserUseCase {
    private let repository: EnterpriseUserRepository
    private let securityService: SecurityService
    private let complianceService: ComplianceService
    private let auditService: AuditService
    private let cacheService: EnterpriseCacheService
    
    init(repository: EnterpriseUserRepository,
         securityService: SecurityService,
         complianceService: ComplianceService,
         auditService: AuditService,
         cacheService: EnterpriseCacheService) {
        self.repository = repository
        self.securityService = securityService
        self.complianceService = complianceService
        self.auditService = auditService
        self.cacheService = cacheService
    }
    
    func getUser(id: String) async throws -> EnterpriseUser {
        // Check security permissions
        try await securityService.validateAccess(for: id)
        
        // Check cache first
        if let cachedUser = try await cacheService.getUser(id: id) {
            // Track audit event
            await auditService.trackAccess(userId: id, action: "cache_hit")
            return cachedUser
        }
        
        // Fetch from repository
        let user = try await repository.getUser(id: id)
        
        // Validate compliance
        try await complianceService.validateUserCompliance(user)
        
        // Cache the result
        try await cacheService.cacheUser(user)
        
        // Track audit event
        await auditService.trackAccess(userId: id, action: "repository_fetch")
        
        return user
    }
    
    func updateUser(_ user: EnterpriseUser) async throws {
        // Validate security permissions
        try await securityService.validateWriteAccess(for: user.id)
        
        // Validate business rules
        try validateUserUpdate(user)
        
        // Check compliance
        try await complianceService.validateUserUpdate(user)
        
        // Update in repository
        try await repository.updateUser(user)
        
        // Invalidate cache
        try await cacheService.invalidateUser(id: user.id)
        
        // Track audit event
        await auditService.trackUpdate(userId: user.id, changes: ["user_updated"])
        
        // Notify relevant systems
        await notifyUserUpdate(user)
    }
    
    func deleteUser(id: String) async throws {
        // Validate security permissions
        try await securityService.validateDeleteAccess(for: id)
        
        // Check business rules
        try await validateUserDeletion(id)
        
        // Archive user data (compliance requirement)
        try await archiveUserData(id)
        
        // Delete from repository
        try await repository.deleteUser(id: id)
        
        // Clear cache
        try await cacheService.invalidateUser(id: id)
        
        // Track audit event
        await auditService.trackDeletion(userId: id)
        
        // Notify relevant systems
        await notifyUserDeletion(id)
    }
    
    func getUserAnalytics(id: String) async throws -> EnterpriseAnalytics {
        // Validate access permissions
        try await securityService.validateAnalyticsAccess(for: id)
        
        return try await repository.getUserAnalytics(id: id)
    }
    
    func updateSettings(_ settings: EnterpriseSettings, for userId: String) async throws {
        var user = try await getUser(id: userId)
        user.settings = settings
        try await updateUser(user)
    }
    
    func updatePermissions(_ permissions: [Permission], for userId: String) async throws {
        // Validate permission changes
        try await securityService.validatePermissionChanges(permissions, for: userId)
        
        var user = try await getUser(id: userId)
        user.permissions = permissions
        try await updateUser(user)
    }
    
    func trackAuditEvent(_ event: AuditEvent, for userId: String) async throws {
        try await repository.trackAuditEvent(event, for: userId)
        await auditService.trackEvent(event, userId: userId)
    }
    
    func validateCompliance(for userId: String) async throws -> ComplianceReport {
        let user = try await getUser(id: userId)
        return try await complianceService.generateComplianceReport(for: user)
    }
    
    func generateSecurityReport(for userId: String) async throws -> SecurityReport {
        let user = try await getUser(id: userId)
        return try await securityService.generateSecurityReport(for: user)
    }
    
    // MARK: - Private Methods
    private func validateUserUpdate(_ user: EnterpriseUser) throws {
        guard !user.name.isEmpty else {
            throw EnterpriseValidationError.invalidName
        }
        
        guard user.email.contains("@") else {
            throw EnterpriseValidationError.invalidEmail
        }
        
        guard !user.employeeId.isEmpty else {
            throw EnterpriseValidationError.invalidEmployeeId
        }
    }
    
    private func validateUserDeletion(_ userId: String) async throws {
        // Check if user has active projects
        let user = try await getUser(id: userId)
        let activeProjects = user.profile.projects.filter { $0.status == .active }
        
        guard activeProjects.isEmpty else {
            throw EnterpriseValidationError.userHasActiveProjects
        }
    }
    
    private func archiveUserData(_ userId: String) async throws {
        // Implement data archiving for compliance
    }
    
    private func notifyUserUpdate(_ user: EnterpriseUser) async {
        // Notify HR system
        // Notify payroll system
        // Notify security system
    }
    
    private func notifyUserDeletion(_ userId: String) async {
        // Notify HR system
        // Notify IT system
        // Notify security system
    }
}

// MARK: - Enterprise Errors
enum EnterpriseValidationError: Error, LocalizedError {
    case invalidName
    case invalidEmail
    case invalidEmployeeId
    case userHasActiveProjects
    case insufficientPermissions
    case complianceViolation
    
    var errorDescription: String? {
        switch self {
        case .invalidName:
            return "Name cannot be empty"
        case .invalidEmail:
            return "Invalid email format"
        case .invalidEmployeeId:
            return "Employee ID cannot be empty"
        case .userHasActiveProjects:
            return "Cannot delete user with active projects"
        case .insufficientPermissions:
            return "Insufficient permissions for this action"
        case .complianceViolation:
            return "Action violates compliance requirements"
        }
    }
}

// MARK: - Additional Types
struct AuditEvent: Codable {
    let id: String
    let userId: String
    let action: String
    let timestamp: Date
    let details: [String: String]
    let severity: AuditSeverity
}

struct SecurityReport: Codable {
    let userId: String
    let generatedAt: Date
    let riskLevel: SecurityRiskLevel
    let vulnerabilities: [Vulnerability]
    let recommendations: [SecurityRecommendation]
}

struct ComplianceReport: Codable {
    let userId: String
    let generatedAt: Date
    let status: ComplianceStatus
    let violations: [ComplianceViolation]
    let recommendations: [ComplianceRecommendation]
}

enum AuditSeverity: String, Codable {
    case low, medium, high, critical
}

enum SecurityRiskLevel: String, Codable {
    case low, medium, high, critical
}

enum ComplianceStatus: String, Codable {
    case compliant, nonCompliant, pendingReview
}

struct Vulnerability: Codable {
    let id: String
    let title: String
    let description: String
    let severity: SecurityRiskLevel
    let remediation: String
}

struct SecurityRecommendation: Codable {
    let id: String
    let title: String
    let description: String
    let priority: Int
    let implementation: String
}

struct ComplianceViolation: Codable {
    let id: String
    let regulation: String
    let description: String
    let severity: AuditSeverity
    let remediation: String
}

struct ComplianceRecommendation: Codable {
    let id: String
    let title: String
    let description: String
    let priority: Int
    let deadline: Date
}

// MARK: - Additional Supporting Types
struct PasswordPolicy: Codable {
    let minLength: Int
    let requireUppercase: Bool
    let requireLowercase: Bool
    let requireNumbers: Bool
    let requireSpecialChars: Bool
    let expiryDays: Int
}

struct DeviceRestrictions: Codable {
    let allowJailbroken: Bool
    let allowEmulator: Bool
    let requireEncryption: Bool
    let allowedDevices: [String]
}

struct APIAccess: Codable {
    let enabled: Bool
    let rateLimit: Int
    let allowedEndpoints: [String]
    let apiKey: String?
}

struct DataRetentionPolicy: Codable {
    let retentionPeriod: TimeInterval
    let autoDelete: Bool
    let archiveEnabled: Bool
}

struct Goal: Codable {
    let id: String
    let title: String
    let description: String
    let targetDate: Date
    let status: GoalStatus
}

struct Achievement: Codable {
    let id: String
    let title: String
    let description: String
    let date: Date
    let category: AchievementCategory
}

struct Feedback: Codable {
    let id: String
    let from: String
    let message: String
    let date: Date
    let rating: Int
}

enum GoalStatus: String, Codable {
    case notStarted, inProgress, completed, overdue
}

enum AchievementCategory: String, Codable {
    case performance, collaboration, innovation, leadership
}

// MARK: - Additional Types for Analytics
struct ProductivityMetrics: Codable {
    let score: Int
    let tasksCompleted: Int
    let timeSpent: TimeInterval
    let efficiency: Double
}

struct CollaborationMetrics: Codable {
    let score: Int
    let teamProjects: Int
    let meetingsAttended: Int
    let documentsShared: Int
}

struct SecurityMetrics: Codable {
    let score: Int
    let loginAttempts: Int
    let securityIncidents: Int
    let lastSecurityReview: Date
}

struct ComplianceMetrics: Codable {
    let score: Int
    let policiesAcknowledged: Int
    let trainingCompleted: Int
    let lastComplianceCheck: Date
}

// MARK: - Additional Supporting Types
struct Responsibility: Codable {
    let id: String
    let title: String
    let description: String
    let priority: Int
}

struct ThirdPartyIntegration: Codable {
    let name: String
    let enabled: Bool
    let apiKey: String?
    let configuration: [String: String]
}

struct RegulatoryCompliance: Codable {
    let regulation: String
    let status: ComplianceStatus
    let lastReview: Date
    let nextReview: Date
}

struct LoginEvent: Codable {
    let timestamp: Date
    let ipAddress: String
    let device: String
    let success: Bool
}

struct SecurityEvent: Codable {
    let id: String
    let type: SecurityEventType
    let timestamp: Date
    let severity: AuditSeverity
    let description: String
}

enum SecurityEventType: String, Codable {
    case login, logout, permissionChange, dataAccess, securityViolation
} 