// MARK: - Advanced Example
// This example demonstrates advanced Clean Architecture implementation
// with complex business logic, multiple data sources, and enterprise features

import Foundation
import SwiftUI
import Combine

// MARK: - Domain Layer

// MARK: - Entities
struct AdvancedUser: Identifiable, Codable {
    let id: String
    let name: String
    let email: String
    let profile: UserProfile
    let preferences: UserPreferences
    let subscription: Subscription
    let analytics: UserAnalytics
}

struct UserProfile: Codable {
    let avatar: String
    let bio: String
    let location: String
    let joinDate: Date
    let lastActive: Date
    let status: UserStatus
}

struct UserPreferences: Codable {
    let theme: AppTheme
    let language: Language
    let notifications: NotificationSettings
    let privacy: PrivacySettings
}

struct Subscription: Codable {
    let plan: SubscriptionPlan
    let startDate: Date
    let endDate: Date
    let autoRenew: Bool
    let features: [SubscriptionFeature]
}

struct UserAnalytics: Codable {
    let sessionCount: Int
    let totalTimeSpent: TimeInterval
    let featureUsage: [String: Int]
    let conversionEvents: [ConversionEvent]
}

// MARK: - Value Objects
enum UserStatus: String, Codable {
    case active, inactive, suspended, premium
}

enum AppTheme: String, Codable {
    case light, dark, system, custom
}

enum Language: String, Codable {
    case english, spanish, french, german, chinese
}

enum SubscriptionPlan: String, Codable {
    case free, basic, premium, enterprise
}

struct NotificationSettings: Codable {
    let pushEnabled: Bool
    let emailEnabled: Bool
    let smsEnabled: Bool
    let categories: [NotificationCategory]
}

struct PrivacySettings: Codable {
    let dataSharing: Bool
    let analyticsEnabled: Bool
    let locationSharing: Bool
    let profileVisibility: ProfileVisibility
}

struct SubscriptionFeature: Codable {
    let name: String
    let enabled: Bool
    let usage: FeatureUsage
}

struct ConversionEvent: Codable {
    let eventName: String
    let timestamp: Date
    let value: Double
    let metadata: [String: String]
}

enum ProfileVisibility: String, Codable {
    case public, friends, private
}

enum NotificationCategory: String, Codable {
    case general, marketing, updates, security
}

struct FeatureUsage: Codable {
    let current: Int
    let limit: Int
    let resetDate: Date
}

// MARK: - Use Cases
protocol AdvancedUserUseCase {
    func getUser(id: String) async throws -> AdvancedUser
    func updateUser(_ user: AdvancedUser) async throws
    func deleteUser(id: String) async throws
    func getUserAnalytics(id: String) async throws -> UserAnalytics
    func updatePreferences(_ preferences: UserPreferences, for userId: String) async throws
    func upgradeSubscription(to plan: SubscriptionPlan, for userId: String) async throws
    func trackEvent(_ event: ConversionEvent, for userId: String) async throws
}

class GetAdvancedUserUseCase: AdvancedUserUseCase {
    private let repository: AdvancedUserRepository
    private let analyticsService: AnalyticsService
    private let cacheService: CacheService
    
    init(repository: AdvancedUserRepository, 
         analyticsService: AnalyticsService,
         cacheService: CacheService) {
        self.repository = repository
        self.analyticsService = analyticsService
        self.cacheService = cacheService
    }
    
    func getUser(id: String) async throws -> AdvancedUser {
        // Check cache first
        if let cachedUser = try await cacheService.getUser(id: id) {
            return cachedUser
        }
        
        // Fetch from repository
        let user = try await repository.getUser(id: id)
        
        // Cache the result
        try await cacheService.cacheUser(user)
        
        // Track analytics
        await analyticsService.trackUserView(userId: id)
        
        return user
    }
    
    func updateUser(_ user: AdvancedUser) async throws {
        // Validate user data
        try validateUser(user)
        
        // Update in repository
        try await repository.updateUser(user)
        
        // Invalidate cache
        try await cacheService.invalidateUser(id: user.id)
        
        // Track analytics
        await analyticsService.trackUserUpdate(userId: user.id)
    }
    
    func deleteUser(id: String) async throws {
        // Check permissions
        try await checkDeletePermissions(for: id)
        
        // Delete from repository
        try await repository.deleteUser(id: id)
        
        // Clear cache
        try await cacheService.invalidateUser(id: id)
        
        // Track analytics
        await analyticsService.trackUserDeletion(userId: id)
    }
    
    func getUserAnalytics(id: String) async throws -> UserAnalytics {
        return try await repository.getUserAnalytics(id: id)
    }
    
    func updatePreferences(_ preferences: UserPreferences, for userId: String) async throws {
        var user = try await getUser(id: userId)
        user.preferences = preferences
        try await updateUser(user)
    }
    
    func upgradeSubscription(to plan: SubscriptionPlan, for userId: String) async throws {
        var user = try await getUser(id: userId)
        
        // Validate upgrade
        try validateSubscriptionUpgrade(from: user.subscription.plan, to: plan)
        
        // Process payment
        try await processPayment(for: plan, userId: userId)
        
        // Update subscription
        user.subscription = Subscription(
            plan: plan,
            startDate: Date(),
            endDate: Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date(),
            autoRenew: true,
            features: getFeatures(for: plan)
        )
        
        try await updateUser(user)
    }
    
    func trackEvent(_ event: ConversionEvent, for userId: String) async throws {
        try await repository.trackEvent(event, for: userId)
        await analyticsService.trackConversionEvent(event, userId: userId)
    }
    
    // MARK: - Private Methods
    private func validateUser(_ user: AdvancedUser) throws {
        guard !user.name.isEmpty else {
            throw ValidationError.invalidName
        }
        
        guard user.email.contains("@") else {
            throw ValidationError.invalidEmail
        }
    }
    
    private func checkDeletePermissions(for userId: String) async throws {
        // Implement permission checking logic
    }
    
    private func validateSubscriptionUpgrade(from current: SubscriptionPlan, to new: SubscriptionPlan) throws {
        // Implement upgrade validation logic
    }
    
    private func processPayment(for plan: SubscriptionPlan, userId: String) async throws {
        // Implement payment processing logic
    }
    
    private func getFeatures(for plan: SubscriptionPlan) -> [SubscriptionFeature] {
        // Return features based on plan
        return []
    }
}

// MARK: - Errors
enum ValidationError: Error, LocalizedError {
    case invalidName
    case invalidEmail
    case invalidSubscription
    
    var errorDescription: String? {
        switch self {
        case .invalidName:
            return "Name cannot be empty"
        case .invalidEmail:
            return "Invalid email format"
        case .invalidSubscription:
            return "Invalid subscription data"
        }
    }
} 