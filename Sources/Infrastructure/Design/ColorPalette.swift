import SwiftUI

/**
 * Color Palette - Infrastructure Layer
 * 
 * This file defines the premium color palette for the iOS Clean Architecture Template.
 * It uses Apple Blue and follows Human Interface Guidelines for optimal user experience.
 * 
 * - Author: iOS Clean Architecture Team
 * - Version: 2.0.0
 * - Date: 2024-01-15
 */

// MARK: - Primary Colors
extension Color {
    /// Apple Blue - Primary brand color
    static let primaryBlue = Color(red: 0/255, green: 122/255, blue: 255/255)
    
    /// Apple Blue with 80% opacity
    static let primaryBlue80 = Color(red: 0/255, green: 122/255, blue: 255/255, opacity: 0.8)
    
    /// Apple Blue with 60% opacity
    static let primaryBlue60 = Color(red: 0/255, green: 122/255, blue: 255/255, opacity: 0.6)
    
    /// Apple Blue with 40% opacity
    static let primaryBlue40 = Color(red: 0/255, green: 122/255, blue: 255/255, opacity: 0.4)
    
    /// Apple Blue with 20% opacity
    static let primaryBlue20 = Color(red: 0/255, green: 122/255, blue: 255/255, opacity: 0.2)
}

// MARK: - Secondary Colors
extension Color {
    /// Secondary blue for accents
    static let secondaryBlue = Color(red: 64/255, green: 156/255, blue: 255/255)
    
    /// Accent blue for highlights
    static let accentBlue = Color(red: 128/255, green: 190/255, blue: 255/255)
    
    /// Light blue for backgrounds
    static let lightBlue = Color(red: 240/255, green: 248/255, blue: 255/255)
}

// MARK: - Semantic Colors
extension Color {
    /// Success green
    static let successGreen = Color(red: 52/255, green: 199/255, blue: 89/255)
    
    /// Warning orange
    static let warningOrange = Color(red: 255/255, green: 149/255, blue: 0/255)
    
    /// Error red
    static let errorRed = Color(red: 255/255, green: 59/255, blue: 48/255)
    
    /// Info blue
    static let infoBlue = Color(red: 0/255, green: 122/255, blue: 255/255)
}

// MARK: - Neutral Colors
extension Color {
    /// Primary text color
    static let primaryText = Color(.label)
    
    /// Secondary text color
    static let secondaryText = Color(.secondaryLabel)
    
    /// Tertiary text color
    static let tertiaryText = Color(.tertiaryLabel)
    
    /// Quaternary text color
    static let quaternaryText = Color(.quaternaryLabel)
    
    /// Primary background
    static let primaryBackground = Color(.systemBackground)
    
    /// Secondary background
    static let secondaryBackground = Color(.secondarySystemBackground)
    
    /// Tertiary background
    static let tertiaryBackground = Color(.tertiarySystemBackground)
}

// MARK: - Gradient Colors
extension LinearGradient {
    /// Primary blue gradient
    static let primaryBlueGradient = LinearGradient(
        colors: [.primaryBlue, .secondaryBlue],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    /// Premium blue gradient
    static let premiumBlueGradient = LinearGradient(
        colors: [.primaryBlue, .accentBlue, .secondaryBlue],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    /// Success gradient
    static let successGradient = LinearGradient(
        colors: [.successGreen, Color(red: 48/255, green: 209/255, blue: 88/255)],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    /// Warning gradient
    static let warningGradient = LinearGradient(
        colors: [.warningOrange, Color(red: 255/255, green: 159/255, blue: 10/255)],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    /// Error gradient
    static let errorGradient = LinearGradient(
        colors: [.errorRed, Color(red: 255/255, green: 69/255, blue: 58/255)],
        startPoint: .leading,
        endPoint: .trailing
    )
}

// MARK: - Role Colors
extension Color {
    /// User role color
    static let userRoleColor = Color.blue
    
    /// Moderator role color
    static let moderatorRoleColor = Color.orange
    
    /// Admin role color
    static let adminRoleColor = Color.red
}

// MARK: - Status Colors
extension Color {
    /// Active status color
    static let activeStatus = Color.successGreen
    
    /// Inactive status color
    static let inactiveStatus = Color.errorRed
    
    /// Pending status color
    static let pendingStatus = Color.warningOrange
}

// MARK: - Dark Mode Support
extension Color {
    /// Adaptive primary blue that works in both light and dark modes
    static let adaptivePrimaryBlue = Color {
        $0.userInterfaceStyle == .dark ? .primaryBlue : .primaryBlue
    }
    
    /// Adaptive background that works in both light and dark modes
    static let adaptiveBackground = Color {
        $0.userInterfaceStyle == .dark ? .primaryBackground : .secondaryBackground
    }
}

// MARK: - Color Utilities
extension Color {
    /// Create a color with opacity
    func withOpacity(_ opacity: Double) -> Color {
        return self.opacity(opacity)
    }
    
    /// Create a lighter version of the color
    func lighter(by percentage: CGFloat = 0.2) -> Color {
        return self.opacity(1 - percentage)
    }
    
    /// Create a darker version of the color
    func darker(by percentage: CGFloat = 0.2) -> Color {
        return self.opacity(1 + percentage)
    }
}

// MARK: - Color Schemes
struct ColorScheme {
    /// Light mode color scheme
    static let light = LightColorScheme()
    
    /// Dark mode color scheme
    static let dark = DarkColorScheme()
}

struct LightColorScheme {
    let primary = Color.primaryBlue
    let secondary = Color.secondaryBlue
    let background = Color.primaryBackground
    let surface = Color.secondaryBackground
    let text = Color.primaryText
    let textSecondary = Color.secondaryText
}

struct DarkColorScheme {
    let primary = Color.primaryBlue
    let secondary = Color.secondaryBlue
    let background = Color.primaryBackground
    let surface = Color.secondaryBackground
    let text = Color.primaryText
    let textSecondary = Color.secondaryText
}
