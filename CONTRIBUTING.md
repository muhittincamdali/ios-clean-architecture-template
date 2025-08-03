# Contributing to iOS Clean Architecture Template

Thank you for your interest in contributing to the iOS Clean Architecture Template! This document provides guidelines and information for contributors.

## 🎯 Our Mission

We strive to create the world's best, most professional, and most perfect iOS Clean Architecture template that serves the Swift, iOS, GitHub, and UI/UX communities with **500 million dollar quality standards**.

## 📋 Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [Architecture Guidelines](#architecture-guidelines)
- [Coding Standards](#coding-standards)
- [Testing Guidelines](#testing-guidelines)
- [Documentation Standards](#documentation-standards)
- [Pull Request Process](#pull-request-process)
- [Release Process](#release-process)
- [Community Guidelines](#community-guidelines)

## 🤝 Code of Conduct

### Our Standards

We are committed to providing a welcoming and inspiring community for all. We expect all contributors to:

- **Be respectful and inclusive** - Treat everyone with respect and dignity
- **Be professional** - Maintain high standards of professionalism
- **Be constructive** - Provide constructive feedback and suggestions
- **Be collaborative** - Work together to achieve our goals
- **Be quality-focused** - Strive for excellence in everything we do

### Unacceptable Behavior

The following behaviors are considered unacceptable:

- Harassment, discrimination, or bullying
- Trolling, insulting, or derogatory comments
- Publishing others' private information without permission
- Any conduct that could be considered inappropriate in a professional setting

## 🚀 Getting Started

### Prerequisites

- **Xcode 15.0+** with iOS 15.0+ SDK
- **Swift 5.7+** programming language
- **Git** version control system
- **Swift Package Manager** for dependency management
- **CocoaPods** (optional) for additional dependencies

### Required Knowledge

- **Clean Architecture** principles and patterns
- **SOLID** design principles
- **MVVM** architectural pattern
- **SwiftUI** and **UIKit** frameworks
- **Combine** reactive programming
- **Unit Testing** and **UI Testing**
- **Git** workflow and collaboration

## 🛠️ Development Setup

### 1. Fork and Clone

```bash
# Fork the repository on GitHub
# Clone your fork
git clone https://github.com/YOUR_USERNAME/ios-clean-architecture-template.git
cd ios-clean-architecture-template

# Add upstream remote
git remote add upstream https://github.com/muhittincamdali/ios-clean-architecture-template.git
```

### 2. Install Dependencies

```bash
# Install Swift Package Manager dependencies
swift package resolve

# Install CocoaPods dependencies (if using)
pod install
```

### 3. Build and Test

```bash
# Build the project
swift build

# Run tests
swift test

# Build for iOS
xcodebuild -scheme iOSCleanArchitectureTemplate -destination 'platform=iOS Simulator,name=iPhone 15' build
```

## 🏗️ Architecture Guidelines

### Clean Architecture Layers

Our project follows Clean Architecture principles with these layers:

#### 1. **Domain Layer** (`Sources/Domain/`)
- **Entities**: Core business objects
- **Use Cases**: Business logic implementation
- **Protocols**: Abstract interfaces
- **Exceptions**: Domain-specific errors

#### 2. **Data Layer** (`Sources/Data/`)
- **Repositories**: Data access implementation
- **Data Sources**: Remote and local data sources
- **Models**: Data transfer objects
- **Mappers**: Data transformation

#### 3. **Presentation Layer** (`Sources/Presentation/`)
- **ViewModels**: MVVM pattern implementation
- **Views**: SwiftUI and UIKit components
- **Coordinators**: Navigation management
- **Components**: Reusable UI components

#### 4. **Infrastructure Layer** (`Sources/Infrastructure/`)
- **Networking**: API communication
- **Storage**: Local data persistence
- **Analytics**: User behavior tracking
- **Security**: Data protection
- **Performance**: Monitoring and optimization

### Dependency Rules

- **Domain** has no dependencies on other layers
- **Data** depends only on **Domain**
- **Presentation** depends only on **Domain**
- **Infrastructure** depends only on **Domain**

## 📝 Coding Standards

### Swift Style Guide

We follow the [Swift API Design Guidelines](https://www.swift.org/documentation/api-design-guidelines/) and these additional standards:

#### Naming Conventions

```swift
// ✅ Correct
class UserRepository: UserRepositoryProtocol {
    func getUser(id: String) async throws -> User
}

// ❌ Incorrect
class userRepository: userRepositoryProtocol {
    func get_user(id: String) async throws -> User
}
```

#### File Organization

```swift
// MARK: - Imports
import Foundation
import Combine

// MARK: - Protocol
protocol ExampleProtocol {
    // Protocol methods
}

// MARK: - Implementation
class ExampleImplementation: ExampleProtocol {
    // MARK: - Properties
    private let dependency: DependencyProtocol
    
    // MARK: - Initialization
    init(dependency: DependencyProtocol) {
        self.dependency = dependency
    }
    
    // MARK: - Public Methods
    func publicMethod() {
        // Implementation
    }
    
    // MARK: - Private Methods
    private func privateMethod() {
        // Implementation
    }
}
```

#### Documentation Standards

```swift
/**
 * Example Class - Layer Name
 * 
 * Professional implementation with advanced features:
 * - Feature 1 description
 * - Feature 2 description
 * - Feature 3 description
 * 
 * - Author: iOS Clean Architecture Team
 * - Version: 2.0.0
 * - Date: 2024-01-15
 */
```

### Code Quality Standards

#### 1. **SOLID Principles**
- **Single Responsibility**: Each class has one reason to change
- **Open/Closed**: Open for extension, closed for modification
- **Liskov Substitution**: Subtypes are substitutable
- **Interface Segregation**: Many specific interfaces over one general
- **Dependency Inversion**: Depend on abstractions, not concretions

#### 2. **Clean Code Practices**
- Meaningful names for variables, functions, and classes
- Small, focused functions (max 20 lines)
- Clear and descriptive comments
- Consistent formatting and indentation
- Error handling for all operations

#### 3. **Performance Standards**
- App launch time < 1.3 seconds
- API response time < 200ms
- 60fps animations
- Memory usage < 200MB
- Battery optimization

## 🧪 Testing Guidelines

### Test Coverage Requirements

- **100% Unit Test Coverage** for all business logic
- **Integration Tests** for data layer
- **UI Tests** for critical user flows
- **Performance Tests** for key operations
- **Security Tests** for sensitive operations

### Testing Standards

#### Unit Tests

```swift
import XCTest
import Quick
import Nimble
@testable import Domain

class ExampleUseCaseTests: QuickSpec {
    override func spec() {
        describe("ExampleUseCase") {
            var useCase: ExampleUseCase!
            var mockRepository: MockExampleRepository!
            
            beforeEach {
                mockRepository = MockExampleRepository()
                useCase = ExampleUseCase(repository: mockRepository)
            }
            
            context("when operation succeeds") {
                it("should return expected result") {
                    // Given
                    let expectedResult = ExampleResult()
                    mockRepository.mockResult = expectedResult
                    
                    // When
                    let result = try await useCase.execute()
                    
                    // Then
                    expect(result).to(equal(expectedResult))
                }
            }
            
            context("when operation fails") {
                it("should throw appropriate error") {
                    // Given
                    mockRepository.shouldThrowError = true
                    
                    // When & Then
                    expect { try await useCase.execute() }.to(throwError())
                }
            }
        }
    }
}
```

#### UI Tests

```swift
import XCTest

class ExampleUITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }
    
    func testUserFlow() throws {
        // Given
        let loginButton = app.buttons["Login"]
        
        // When
        loginButton.tap()
        
        // Then
        XCTAssertTrue(app.textFields["Email"].exists)
        XCTAssertTrue(app.secureTextFields["Password"].exists)
    }
}
```

### Test Naming Conventions

- **Unit Tests**: `ClassNameTests.swift`
- **UI Tests**: `FeatureUITests.swift`
- **Integration Tests**: `FeatureIntegrationTests.swift`
- **Performance Tests**: `FeaturePerformanceTests.swift`

## 📚 Documentation Standards

### README.md Requirements

Every repository must include:

1. **Project Overview** with clear description
2. **Features List** with detailed explanations
3. **Installation Instructions** with step-by-step guide
4. **Usage Examples** with code samples
5. **Architecture Documentation** with diagrams
6. **API Documentation** with examples
7. **Contributing Guidelines** (this file)
8. **License Information**

### Code Documentation

```swift
/**
 * Calculates the total price including tax and discounts.
 *
 * - Parameters:
 *   - basePrice: The original price before any modifications
 *   - taxRate: The tax rate as a decimal (e.g., 0.08 for 8%)
 *   - discountPercentage: The discount percentage as a decimal
 *
 * - Returns: The final price after applying tax and discount
 *
 * - Throws: `PricingError.invalidTaxRate` if tax rate is negative
 *           `PricingError.invalidDiscount` if discount is greater than 100%
 *
 * - Note: This method applies the discount before calculating tax
 *
 * - Example:
 * ```swift
 * let finalPrice = try calculatePrice(basePrice: 100.0, taxRate: 0.08, discountPercentage: 0.10)
 * // Returns: 97.2 (100 - 10% discount = 90, + 8% tax = 97.2)
 * ```
 */
func calculatePrice(basePrice: Double, taxRate: Double, discountPercentage: Double) throws -> Double {
    // Implementation
}
```

## 🔄 Pull Request Process

### Before Submitting

1. **Ensure Quality Standards**
   - Code follows our style guide
   - All tests pass (100% coverage)
   - Documentation is complete
   - Performance benchmarks are met

2. **Update Documentation**
   - Update README.md if needed
   - Add/update code comments
   - Update CHANGELOG.md
   - Update API documentation

3. **Test Thoroughly**
   - Run all unit tests
   - Run UI tests
   - Test on different devices
   - Performance testing

### Pull Request Template

```markdown
## Description
Brief description of changes and why they're needed.

## Type of Change
- [ ] Bug fix (non-breaking change which fixes an issue)
- [ ] New feature (non-breaking change which adds functionality)
- [ ] Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] Documentation update

## Testing
- [ ] Unit tests pass
- [ ] UI tests pass
- [ ] Integration tests pass
- [ ] Performance tests pass
- [ ] Tested on multiple devices

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Documentation updated
- [ ] No breaking changes (or documented)
- [ ] Tests added/updated
- [ ] Performance impact assessed

## Screenshots (if applicable)
Add screenshots for UI changes.

## Additional Notes
Any additional information or context.
```

### Review Process

1. **Automated Checks**
   - CI/CD pipeline runs tests
   - Code coverage analysis
   - Performance benchmarks
   - Security scanning

2. **Manual Review**
   - Code quality review
   - Architecture review
   - Documentation review
   - Security review

3. **Approval Requirements**
   - At least 2 maintainer approvals
   - All automated checks pass
   - No breaking changes without discussion

## 🚀 Release Process

### Version Numbering

We follow [Semantic Versioning](https://semver.org/):

- **MAJOR.MINOR.PATCH**
- **MAJOR**: Breaking changes
- **MINOR**: New features (backward compatible)
- **PATCH**: Bug fixes (backward compatible)

### Release Checklist

1. **Pre-Release**
   - [ ] All tests pass
   - [ ] Documentation updated
   - [ ] CHANGELOG.md updated
   - [ ] Version number updated
   - [ ] Performance benchmarks met
   - [ ] Security audit completed

2. **Release**
   - [ ] Create release tag
   - [ ] Generate release notes
   - [ ] Update documentation
   - [ ] Notify community

3. **Post-Release**
   - [ ] Monitor for issues
   - [ ] Update examples
   - [ ] Community feedback

## 👥 Community Guidelines

### Communication

- **Be respectful** and professional
- **Ask questions** when unsure
- **Provide constructive feedback**
- **Share knowledge** with others
- **Help newcomers** get started

### Recognition

We recognize contributors through:

- **Contributor Hall of Fame** in README.md
- **GitHub Stars** and acknowledgments
- **Community spotlight** features
- **Professional references** and recommendations

### Getting Help

- **GitHub Issues**: For bugs and feature requests
- **GitHub Discussions**: For questions and discussions
- **Documentation**: For technical guidance
- **Examples**: For implementation help

## 🏆 Quality Standards

### 500 Million Dollar Quality

We maintain the highest standards:

- **Professional Code Quality**: Enterprise-grade code
- **Comprehensive Testing**: 100% test coverage
- **Excellent Documentation**: Clear and complete
- **Performance Optimization**: Fast and efficient
- **Security Best Practices**: Safe and secure
- **Accessibility Compliance**: Inclusive design
- **Internationalization**: Multi-language support

### Continuous Improvement

- **Regular Code Reviews**: Maintain quality
- **Performance Monitoring**: Track improvements
- **Security Audits**: Ensure safety
- **User Feedback**: Incorporate suggestions
- **Industry Standards**: Follow best practices

## 📞 Contact

- **GitHub Issues**: [Report bugs](https://github.com/muhittincamdali/ios-clean-architecture-template/issues)
- **GitHub Discussions**: [Ask questions](https://github.com/muhittincamdali/ios-clean-architecture-template/discussions)
- **Email**: [Contact maintainers](mailto:contact@ioscleanarchitecture.com)

---

**Thank you for contributing to the iOS Clean Architecture Template!** 🚀

Together, we're building the world's best iOS development template with 500 million dollar quality standards.
