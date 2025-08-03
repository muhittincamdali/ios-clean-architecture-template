import Foundation

/**
 * User Validator Protocol - Domain Layer
 * 
 * Abstract interface for user validation operations.
 * Defines the contract for user validation implementations.
 * 
 * - Author: iOS Clean Architecture Team
 * - Version: 2.0.0
 * - Date: 2024-01-15
 */

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