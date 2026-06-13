import os
import re

dir_path = "/Users/muhittincamdali/Desktop/Claude Projects/GitHub/ios-clean-architecture-template/Sources/Domain"

def solve_ambiguity():
    files = [
        "Validators/UserValidator.swift",
        "Protocols/UserValidatorProtocol.swift",
        "UseCases/GetUserUseCase.swift",
        "Protocols/GetUserUseCaseProtocol.swift",
        "Protocols/GetUsersUseCaseProtocol.swift",
        "UseCases/GetUsersUseCase.swift",
        "Entities/User.swift"
    ]
    
    for rel_path in files:
        path = os.path.join(dir_path, rel_path)
        if not os.path.exists(path): continue
        with open(path, 'r') as f: content = f.read()
        
        # 1. Make internal types public so they can be used in DomainErrors.swift
        content = content.replace('struct User: Codable', 'public struct User: Codable')
        content = content.replace('enum UserRole: String', 'public enum UserRole: String')
        content = content.replace('struct UserMetadata: Codable', 'public struct UserMetadata: Codable')
        
        # 2. Remove entire duplicated blocks with a safer regex
        # This matches from 'enum/struct Name' until the matching brace.
        duplicated_types = [
            "enum ValidationError", "enum UseCaseError", "struct ValidationResult",
            "struct UserResult", "struct UserMetadata", "struct GetUserOptions",
            "struct UserFilter", "enum GetUserUseCaseError", "enum GetUsersUseCaseError",
            "enum UserSortBy"
        ]
        
        for dtype in duplicated_types:
            # Match start of line, optional MARK, then the type decl, then everything until a closing brace at the start of a line
            pattern = rf'(\n// MARK: - {dtype.split()[-1]}.*?\n)?{dtype}.*?\n\}}'
            content = re.sub(pattern, '', content, flags=re.DOTALL)
            
        with open(path, 'w') as f: f.write(content)
        print(f"Surgically cleaned: {rel_path}")

solve_ambiguity()
