import Foundation
import ios-clean-architecture-template

/// Basic example demonstrating the core functionality of ios-clean-architecture-template
@main
struct BasicExample {
    static func main() {
        print("🚀 ios-clean-architecture-template Basic Example")
        
        // Initialize the framework
        let framework = ios-clean-architecture-template()
        
        // Configure with default settings
        framework.configure()
        
        print("✅ Framework configured successfully")
        
        // Demonstrate basic functionality
        demonstrateBasicFeatures(framework)
    }
    
    static func demonstrateBasicFeatures(_ framework: ios-clean-architecture-template) {
        print("\n📱 Demonstrating basic features...")
        
        // Add your example code here
        print("🎯 Feature 1: Core functionality")
        print("🎯 Feature 2: Configuration")
        print("🎯 Feature 3: Error handling")
        
        print("\n✨ Basic example completed successfully!")
    }
}
