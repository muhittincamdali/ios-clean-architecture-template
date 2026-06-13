import os
import re

dir_path = "/Users/muhittincamdali/Desktop/Claude Projects/GitHub/ios-clean-architecture-template/Sources/Domain"

def clean_file(rel_path):
    path = os.path.join(dir_path, rel_path)
    if not os.path.exists(path): return
    with open(path, 'r') as f: content = f.read()
    
    # List of enums/structs to remove
    to_remove = [
        "enum ValidationError", "enum UseCaseError", "struct ValidationResult",
        "struct UserResult", "struct UserMetadata", "struct GetUserOptions",
        "struct UserFilter", "enum GetUserUseCaseError", "enum GetUsersUseCaseError"
    ]
    
    for item in to_remove:
        # Regex to find the whole block starting with the item and ending with }
        # This is safe for simple structs/enums
        pattern = rf'(// MARK: - .*?\n)?{item}: .*?\{{[^}}]*\n\}}'
        content = re.sub(pattern, '', content, flags=re.DOTALL)
        # Try without MARK
        pattern = rf'{item}: .*?\{{[^}}]*\n\}}'
        content = re.sub(pattern, '', content, flags=re.DOTALL)
        # Try simple declaration
        pattern = rf'{item} \{{[^}}]*\n\}}'
        content = re.sub(pattern, '', content, flags=re.DOTALL)
        
    with open(path, 'w') as f: f.write(content)
    print(f"Cleaned: {rel_path}")

files = [
    "Validators/UserValidator.swift",
    "Protocols/UserValidatorProtocol.swift",
    "UseCases/GetUserUseCase.swift",
    "Protocols/GetUserUseCaseProtocol.swift",
    "Protocols/GetUsersUseCaseProtocol.swift",
    "UseCases/GetUsersUseCase.swift"
]

for f in files:
    clean_file(f)
