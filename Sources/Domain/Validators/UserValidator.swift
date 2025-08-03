import Foundation

/**
 * User Validator - Domain Layer
 * 
 * Professional user validation system with comprehensive rules.
 * Provides validation for user data, business rules, and security checks.
 * 
 * - Author: iOS Clean Architecture Team
 * - Version: 2.0.0
 * - Date: 2024-01-15
 */

// MARK: - Validation Error
enum ValidationError: LocalizedError {
    case invalidEmail(String)
    case invalidPassword(String)
    case invalidName(String)
    case invalidAge(String)
    case invalidPhone(String)
    case invalidUsername(String)
    case duplicateEmail(String)
    case duplicateUsername(String)
    case weakPassword(String)
    case invalidRole(String)
    case invalidStatus(String)
    case missingRequiredField(String)
    case invalidFormat(String)
    case tooLong(String)
    case tooShort(String)
    case invalidCharacters(String)
    case invalidDomain(String)
    case invalidCountry(String)
    case invalidLanguage(String)
    case invalidTimezone(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidEmail(let email):
            return "Invalid email format: \(email)"
        case .invalidPassword(let reason):
            return "Invalid password: \(reason)"
        case .invalidName(let name):
            return "Invalid name: \(name)"
        case .invalidAge(let age):
            return "Invalid age: \(age)"
        case .invalidPhone(let phone):
            return "Invalid phone number: \(phone)"
        case .invalidUsername(let username):
            return "Invalid username: \(username)"
        case .duplicateEmail(let email):
            return "Email already exists: \(email)"
        case .duplicateUsername(let username):
            return "Username already exists: \(username)"
        case .weakPassword(let reason):
            return "Weak password: \(reason)"
        case .invalidRole(let role):
            return "Invalid role: \(role)"
        case .invalidStatus(let status):
            return "Invalid status: \(status)"
        case .missingRequiredField(let field):
            return "Missing required field: \(field)"
        case .invalidFormat(let format):
            return "Invalid format: \(format)"
        case .tooLong(let field):
            return "\(field) is too long"
        case .tooShort(let field):
            return "\(field) is too short"
        case .invalidCharacters(let field):
            return "\(field) contains invalid characters"
        case .invalidDomain(let domain):
            return "Invalid domain: \(domain)"
        case .invalidCountry(let country):
            return "Invalid country: \(country)"
        case .invalidLanguage(let language):
            return "Invalid language: \(language)"
        case .invalidTimezone(let timezone):
            return "Invalid timezone: \(timezone)"
        }
    }
    
    var errorCode: Int {
        switch self {
        case .invalidEmail:
            return 2001
        case .invalidPassword:
            return 2002
        case .invalidName:
            return 2003
        case .invalidAge:
            return 2004
        case .invalidPhone:
            return 2005
        case .invalidUsername:
            return 2006
        case .duplicateEmail:
            return 2007
        case .duplicateUsername:
            return 2008
        case .weakPassword:
            return 2009
        case .invalidRole:
            return 2010
        case .invalidStatus:
            return 2011
        case .missingRequiredField:
            return 2012
        case .invalidFormat:
            return 2013
        case .tooLong:
            return 2014
        case .tooShort:
            return 2015
        case .invalidCharacters:
            return 2016
        case .invalidDomain:
            return 2017
        case .invalidCountry:
            return 2018
        case .invalidLanguage:
            return 2019
        case .invalidTimezone:
            return 2020
        }
    }
}

// MARK: - Validation Result
struct ValidationResult {
    let isValid: Bool
    let errors: [ValidationError]
    let warnings: [String]
    
    init(isValid: Bool, errors: [ValidationError] = [], warnings: [String] = []) {
        self.isValid = isValid
        self.errors = errors
        self.warnings = warnings
    }
    
    var hasErrors: Bool {
        return !errors.isEmpty
    }
    
    var hasWarnings: Bool {
        return !warnings.isEmpty
    }
    
    var firstError: ValidationError? {
        return errors.first
    }
    
    var errorMessages: [String] {
        return errors.map { $0.localizedDescription }
    }
}

// MARK: - User Validator Protocol
protocol UserValidatorProtocol {
    func validateUser(_ user: User) async throws -> ValidationResult
    func validateEmail(_ email: String) -> ValidationResult
    func validatePassword(_ password: String) -> ValidationResult
    func validateName(_ name: String) -> ValidationResult
    func validateAge(_ age: Int) -> ValidationResult
    func validatePhone(_ phone: String) -> ValidationResult
    func validateUsername(_ username: String) -> ValidationResult
    func validateRole(_ role: UserRole) -> ValidationResult
    func validateStatus(_ isActive: Bool) -> ValidationResult
    func checkEmailAvailability(_ email: String) async throws -> Bool
    func checkUsernameAvailability(_ username: String) async throws -> Bool
    func validateUserRegistration(_ user: User, password: String) async throws -> ValidationResult
    func validateUserUpdate(_ user: User) async throws -> ValidationResult
    func validateUserLogin(_ email: String, password: String) async throws -> ValidationResult
}

// MARK: - User Validator Implementation
class UserValidator: UserValidatorProtocol {
    
    // MARK: - Properties
    private let userRepository: UserRepositoryProtocol?
    private let logger: LoggerProtocol?
    
    // MARK: - Validation Rules
    private let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    private let phoneRegex = "^[+]?[0-9]{10,15}$"
    private let usernameRegex = "^[a-zA-Z0-9_]{3,20}$"
    private let nameRegex = "^[a-zA-Z\\s]{2,50}$"
    
    private let minPasswordLength = 8
    private let maxPasswordLength = 128
    private let minNameLength = 2
    private let maxNameLength = 50
    private let minAge = 13
    private let maxAge = 120
    private let minUsernameLength = 3
    private let maxUsernameLength = 20
    
    // MARK: - Initialization
    init(
        userRepository: UserRepositoryProtocol? = nil,
        logger: LoggerProtocol? = nil
    ) {
        self.userRepository = userRepository
        self.logger = logger
    }
    
    // MARK: - Public Methods
    func validateUser(_ user: User) async throws -> ValidationResult {
        var errors: [ValidationError] = []
        var warnings: [String] = []
        
        // Validate email
        let emailResult = validateEmail(user.email)
        errors.append(contentsOf: emailResult.errors)
        warnings.append(contentsOf: emailResult.warnings)
        
        // Validate name
        let nameResult = validateName(user.name)
        errors.append(contentsOf: nameResult.errors)
        warnings.append(contentsOf: nameResult.warnings)
        
        // Validate role
        let roleResult = validateRole(user.role)
        errors.append(contentsOf: roleResult.errors)
        warnings.append(contentsOf: roleResult.warnings)
        
        // Validate status
        let statusResult = validateStatus(user.isActive)
        errors.append(contentsOf: statusResult.errors)
        warnings.append(contentsOf: statusResult.warnings)
        
        // Check for duplicate email
        if emailResult.isValid {
            do {
                let isAvailable = try await checkEmailAvailability(user.email)
                if !isAvailable {
                    errors.append(.duplicateEmail(user.email))
                }
            } catch {
                logger?.warning("Could not check email availability: \(error.localizedDescription)", category: "Validation", file: #file, function: #function, line: #line)
            }
        }
        
        let isValid = errors.isEmpty
        return ValidationResult(isValid: isValid, errors: errors, warnings: warnings)
    }
    
    func validateEmail(_ email: String) -> ValidationResult {
        var errors: [ValidationError] = []
        var warnings: [String] = []
        
        // Check if email is empty
        if email.isEmpty {
            errors.append(.missingRequiredField("Email"))
            return ValidationResult(isValid: false, errors: errors, warnings: warnings)
        }
        
        // Check email format
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        if !emailPredicate.evaluate(with: email) {
            errors.append(.invalidEmail(email))
        }
        
        // Check email length
        if email.count > 254 {
            errors.append(.tooLong("Email"))
        }
        
        // Check for common disposable email domains
        let disposableDomains = ["tempmail.com", "10minutemail.com", "guerrillamail.com"]
        let domain = email.components(separatedBy: "@").last?.lowercased() ?? ""
        if disposableDomains.contains(domain) {
            warnings.append("Disposable email detected")
        }
        
        let isValid = errors.isEmpty
        return ValidationResult(isValid: isValid, errors: errors, warnings: warnings)
    }
    
    func validatePassword(_ password: String) -> ValidationResult {
        var errors: [ValidationError] = []
        var warnings: [String] = []
        
        // Check if password is empty
        if password.isEmpty {
            errors.append(.missingRequiredField("Password"))
            return ValidationResult(isValid: false, errors: errors, warnings: warnings)
        }
        
        // Check password length
        if password.count < minPasswordLength {
            errors.append(.tooShort("Password"))
        }
        
        if password.count > maxPasswordLength {
            errors.append(.tooLong("Password"))
        }
        
        // Check password strength
        let hasUppercase = password.range(of: "[A-Z]", options: .regularExpression) != nil
        let hasLowercase = password.range(of: "[a-z]", options: .regularExpression) != nil
        let hasNumbers = password.range(of: "[0-9]", options: .regularExpression) != nil
        let hasSpecialChars = password.range(of: "[!@#$%^&*()_+\\-=\\[\\]{};':\"\\\\|,.<>/?]", options: .regularExpression) != nil
        
        if !hasUppercase {
            errors.append(.weakPassword("Must contain at least one uppercase letter"))
        }
        
        if !hasLowercase {
            errors.append(.weakPassword("Must contain at least one lowercase letter"))
        }
        
        if !hasNumbers {
            errors.append(.weakPassword("Must contain at least one number"))
        }
        
        if !hasSpecialChars {
            errors.append(.weakPassword("Must contain at least one special character"))
        }
        
        // Check for common weak passwords
        let weakPasswords = ["password", "123456", "qwerty", "admin", "letmein"]
        if weakPasswords.contains(password.lowercased()) {
            errors.append(.weakPassword("Common password detected"))
        }
        
        let isValid = errors.isEmpty
        return ValidationResult(isValid: isValid, errors: errors, warnings: warnings)
    }
    
    func validateName(_ name: String) -> ValidationResult {
        var errors: [ValidationError] = []
        var warnings: [String] = []
        
        // Check if name is empty
        if name.isEmpty {
            errors.append(.missingRequiredField("Name"))
            return ValidationResult(isValid: false, errors: errors, warnings: warnings)
        }
        
        // Check name length
        if name.count < minNameLength {
            errors.append(.tooShort("Name"))
        }
        
        if name.count > maxNameLength {
            errors.append(.tooLong("Name"))
        }
        
        // Check name format
        let namePredicate = NSPredicate(format: "SELF MATCHES %@", nameRegex)
        if !namePredicate.evaluate(with: name) {
            errors.append(.invalidName(name))
        }
        
        // Check for numbers in name
        if name.range(of: "[0-9]", options: .regularExpression) != nil {
            warnings.append("Name contains numbers")
        }
        
        let isValid = errors.isEmpty
        return ValidationResult(isValid: isValid, errors: errors, warnings: warnings)
    }
    
    func validateAge(_ age: Int) -> ValidationResult {
        var errors: [ValidationError] = []
        var warnings: [String] = []
        
        if age < minAge {
            errors.append(.invalidAge("Must be at least \(minAge) years old"))
        }
        
        if age > maxAge {
            errors.append(.invalidAge("Age cannot exceed \(maxAge) years"))
        }
        
        if age < 18 {
            warnings.append("User is under 18 years old")
        }
        
        let isValid = errors.isEmpty
        return ValidationResult(isValid: isValid, errors: errors, warnings: warnings)
    }
    
    func validatePhone(_ phone: String) -> ValidationResult {
        var errors: [ValidationError] = []
        var warnings: [String] = []
        
        if phone.isEmpty {
            return ValidationResult(isValid: true, errors: errors, warnings: warnings)
        }
        
        // Check phone format
        let phonePredicate = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        if !phonePredicate.evaluate(with: phone) {
            errors.append(.invalidPhone(phone))
        }
        
        // Check phone length
        if phone.count < 10 {
            errors.append(.tooShort("Phone number"))
        }
        
        if phone.count > 15 {
            errors.append(.tooLong("Phone number"))
        }
        
        let isValid = errors.isEmpty
        return ValidationResult(isValid: isValid, errors: errors, warnings: warnings)
    }
    
    func validateUsername(_ username: String) -> ValidationResult {
        var errors: [ValidationError] = []
        var warnings: [String] = []
        
        // Check if username is empty
        if username.isEmpty {
            errors.append(.missingRequiredField("Username"))
            return ValidationResult(isValid: false, errors: errors, warnings: warnings)
        }
        
        // Check username length
        if username.count < minUsernameLength {
            errors.append(.tooShort("Username"))
        }
        
        if username.count > maxUsernameLength {
            errors.append(.tooLong("Username"))
        }
        
        // Check username format
        let usernamePredicate = NSPredicate(format: "SELF MATCHES %@", usernameRegex)
        if !usernamePredicate.evaluate(with: username) {
            errors.append(.invalidUsername(username))
        }
        
        // Check for reserved usernames
        let reservedUsernames = ["admin", "root", "system", "support", "info", "test"]
        if reservedUsernames.contains(username.lowercased()) {
            errors.append(.invalidUsername("Reserved username"))
        }
        
        let isValid = errors.isEmpty
        return ValidationResult(isValid: isValid, errors: errors, warnings: warnings)
    }
    
    func validateRole(_ role: UserRole) -> ValidationResult {
        var errors: [ValidationError] = []
        var warnings: [String] = []
        
        // All roles are valid in this implementation
        // Additional role validation can be added here
        
        let isValid = errors.isEmpty
        return ValidationResult(isValid: isValid, errors: errors, warnings: warnings)
    }
    
    func validateStatus(_ isActive: Bool) -> ValidationResult {
        var errors: [ValidationError] = []
        var warnings: [String] = []
        
        // All status values are valid in this implementation
        // Additional status validation can be added here
        
        let isValid = errors.isEmpty
        return ValidationResult(isValid: isValid, errors: errors, warnings: warnings)
    }
    
    func checkEmailAvailability(_ email: String) async throws -> Bool {
        guard let userRepository = userRepository else {
            return true // Assume available if no repository
        }
        
        do {
            let user = try await userRepository.getUserByEmail(email)
            return user == nil
        } catch {
            logger?.warning("Error checking email availability: \(error.localizedDescription)", category: "Validation", file: #file, function: #function, line: #line)
            return true // Assume available on error
        }
    }
    
    func checkUsernameAvailability(_ username: String) async throws -> Bool {
        guard let userRepository = userRepository else {
            return true // Assume available if no repository
        }
        
        do {
            let users = try await userRepository.searchUsers(query: username)
            return users.isEmpty
        } catch {
            logger?.warning("Error checking username availability: \(error.localizedDescription)", category: "Validation", file: #file, function: #function, line: #line)
            return true // Assume available on error
        }
    }
    
    func validateUserRegistration(_ user: User, password: String) async throws -> ValidationResult {
        var errors: [ValidationError] = []
        var warnings: [String] = []
        
        // Validate user data
        let userResult = try await validateUser(user)
        errors.append(contentsOf: userResult.errors)
        warnings.append(contentsOf: userResult.warnings)
        
        // Validate password
        let passwordResult = validatePassword(password)
        errors.append(contentsOf: passwordResult.errors)
        warnings.append(contentsOf: passwordResult.warnings)
        
        // Check username availability
        let usernameResult = validateUsername(user.name)
        if usernameResult.isValid {
            do {
                let isAvailable = try await checkUsernameAvailability(user.name)
                if !isAvailable {
                    errors.append(.duplicateUsername(user.name))
                }
            } catch {
                logger?.warning("Could not check username availability: \(error.localizedDescription)", category: "Validation", file: #file, function: #function, line: #line)
            }
        }
        
        let isValid = errors.isEmpty
        return ValidationResult(isValid: isValid, errors: errors, warnings: warnings)
    }
    
    func validateUserUpdate(_ user: User) async throws -> ValidationResult {
        var errors: [ValidationError] = []
        var warnings: [String] = []
        
        // Validate user data
        let userResult = try await validateUser(user)
        errors.append(contentsOf: userResult.errors)
        warnings.append(contentsOf: userResult.warnings)
        
        // Additional update-specific validation can be added here
        
        let isValid = errors.isEmpty
        return ValidationResult(isValid: isValid, errors: errors, warnings: warnings)
    }
    
    func validateUserLogin(_ email: String, password: String) async throws -> ValidationResult {
        var errors: [ValidationError] = []
        var warnings: [String] = []
        
        // Validate email format
        let emailResult = validateEmail(email)
        errors.append(contentsOf: emailResult.errors)
        warnings.append(contentsOf: emailResult.warnings)
        
        // Validate password format (basic check for login)
        if password.isEmpty {
            errors.append(.missingRequiredField("Password"))
        }
        
        let isValid = errors.isEmpty
        return ValidationResult(isValid: isValid, errors: errors, warnings: warnings)
    }
}

// MARK: - User Validator Extensions
extension UserValidator {
    
    // MARK: - Convenience Methods
    func validateUserProfile(_ user: User) async throws -> ValidationResult {
        var errors: [ValidationError] = []
        var warnings: [String] = []
        
        // Basic user validation
        let userResult = try await validateUser(user)
        errors.append(contentsOf: userResult.errors)
        warnings.append(contentsOf: userResult.warnings)
        
        // Profile-specific validation
        if let avatarURL = user.avatarURL, !avatarURL.isEmpty {
            if !isValidURL(avatarURL) {
                warnings.append("Invalid avatar URL format")
            }
        }
        
        let isValid = errors.isEmpty
        return ValidationResult(isValid: isValid, errors: errors, warnings: warnings)
    }
    
    func validateUserSettings(_ settings: [String: Any]) -> ValidationResult {
        var errors: [ValidationError] = []
        var warnings: [String] = []
        
        // Validate language setting
        if let language = settings["language"] as? String {
            if !isValidLanguage(language) {
                errors.append(.invalidLanguage(language))
            }
        }
        
        // Validate timezone setting
        if let timezone = settings["timezone"] as? String {
            if !isValidTimezone(timezone) {
                errors.append(.invalidTimezone(timezone))
            }
        }
        
        // Validate country setting
        if let country = settings["country"] as? String {
            if !isValidCountry(country) {
                errors.append(.invalidCountry(country))
            }
        }
        
        let isValid = errors.isEmpty
        return ValidationResult(isValid: isValid, errors: errors, warnings: warnings)
    }
    
    // MARK: - Private Helper Methods
    private func isValidURL(_ urlString: String) -> Bool {
        guard let url = URL(string: urlString) else { return false }
        return UIApplication.shared.canOpenURL(url)
    }
    
    private func isValidLanguage(_ language: String) -> Bool {
        let validLanguages = ["en", "es", "fr", "de", "it", "pt", "ru", "zh", "ja", "ko"]
        return validLanguages.contains(language.lowercased())
    }
    
    private func isValidTimezone(_ timezone: String) -> Bool {
        return TimeZone.knownTimeZoneIdentifiers.contains(timezone)
    }
    
    private func isValidCountry(_ country: String) -> Bool {
        let validCountries = ["US", "CA", "GB", "DE", "FR", "IT", "ES", "JP", "CN", "KR"]
        return validCountries.contains(country.uppercased())
    }
}

// MARK: - Validation Categories
extension UserValidator {
    
    struct Category {
        static let validation = "Validation"
        static let user = "User"
        static let email = "Email"
        static let password = "Password"
        static let profile = "Profile"
        static let settings = "Settings"
    }
} 