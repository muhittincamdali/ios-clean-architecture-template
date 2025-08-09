# Presentation Layer API

<!-- TOC START -->
## Table of Contents
- [Presentation Layer API](#presentation-layer-api)
- [Overview](#overview)
- [View Models](#view-models)
  - [User View Model](#user-view-model)
  - [Product List View Model](#product-list-view-model)
- [SwiftUI Views](#swiftui-views)
  - [User Profile View](#user-profile-view)
  - [Product List View](#product-list-view)
- [UIKit Integration](#uikit-integration)
  - [UIKit View Controller](#uikit-view-controller)
- [Error Handling](#error-handling)
  - [Presentation Errors](#presentation-errors)
- [Testing](#testing)
  - [View Model Tests](#view-model-tests)
- [Best Practices](#best-practices)
<!-- TOC END -->


## Overview

The Presentation Layer is responsible for UI components, view models, and user interaction. It follows the MVVM pattern and provides a clean interface between the UI and business logic.

## View Models

### User View Model

```swift
@MainActor
class UserViewModel: ObservableObject {
    @Published var user: User?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let userUseCase: UserUseCase
    
    init(userUseCase: UserUseCase) {
        self.userUseCase = userUseCase
    }
    
    func loadUser(id: UUID) async {
        isLoading = true
        errorMessage = nil
        
        do {
            user = try await userUseCase.getUser(id: id)
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func updateUser(_ user: User) async {
        isLoading = true
        errorMessage = nil
        
        do {
            self.user = try await userUseCase.updateUser(user)
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func deleteUser(id: UUID) async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await userUseCase.deleteUser(id: id)
            self.user = nil
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}
```

### Product List View Model

```swift
@MainActor
class ProductListViewModel: ObservableObject {
    @Published var products: [Product] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var selectedCategory: ProductCategory?
    
    private let productUseCase: ProductUseCase
    
    init(productUseCase: ProductUseCase) {
        self.productUseCase = productUseCase
    }
    
    func loadProducts() async {
        isLoading = true
        errorMessage = nil
        
        do {
            products = try await productUseCase.getProducts(category: selectedCategory)
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func filterByCategory(_ category: ProductCategory?) {
        selectedCategory = category
        Task {
            await loadProducts()
        }
    }
    
    func refreshProducts() async {
        await loadProducts()
    }
}
```

## SwiftUI Views

### User Profile View

```swift
struct UserProfileView: View {
    @StateObject private var viewModel: UserViewModel
    let userId: UUID
    
    init(userId: UUID, userUseCase: UserUseCase) {
        self.userId = userId
        self._viewModel = StateObject(wrappedValue: UserViewModel(userUseCase: userUseCase))
    }
    
    var body: some View {
        NavigationView {
            Group {
                if viewModel.isLoading {
                    ProgressView("Loading user...")
                } else if let user = viewModel.user {
                    UserProfileContent(user: user, viewModel: viewModel)
                } else if let errorMessage = viewModel.errorMessage {
                    ErrorView(message: errorMessage) {
                        Task {
                            await viewModel.loadUser(id: userId)
                        }
                    }
                } else {
                    EmptyStateView()
                }
            }
            .navigationTitle("User Profile")
            .task {
                await viewModel.loadUser(id: userId)
            }
        }
    }
}

struct UserProfileContent: View {
    let user: User
    @ObservedObject var viewModel: UserViewModel
    @State private var isEditing = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Profile Image
                AsyncImage(url: URL(string: user.profileImage ?? "")) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.gray)
                }
                .frame(width: 120, height: 120)
                .clipShape(Circle())
                
                // User Info
                VStack(spacing: 10) {
                    Text(user.name)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text(user.email)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("Member since \(user.createdAt.formatted(date: .abbreviated, time: .omitted))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Action Buttons
                HStack(spacing: 20) {
                    Button("Edit Profile") {
                        isEditing = true
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button("Delete Account") {
                        // Show confirmation dialog
                    }
                    .buttonStyle(.bordered)
                    .foregroundColor(.red)
                }
            }
            .padding()
        }
        .sheet(isPresented: $isEditing) {
            EditUserView(user: user, viewModel: viewModel)
        }
    }
}
```

### Product List View

```swift
struct ProductListView: View {
    @StateObject private var viewModel: ProductListViewModel
    @State private var searchText = ""
    
    init(productUseCase: ProductUseCase) {
        self._viewModel = StateObject(wrappedValue: ProductListViewModel(productUseCase: productUseCase))
    }
    
    var body: some View {
        NavigationView {
            Group {
                if viewModel.isLoading {
                    ProgressView("Loading products...")
                } else if let errorMessage = viewModel.errorMessage {
                    ErrorView(message: errorMessage) {
                        Task {
                            await viewModel.loadProducts()
                        }
                    }
                } else {
                    ProductListContent(
                        products: viewModel.products,
                        searchText: $searchText
                    )
                }
            }
            .navigationTitle("Products")
            .searchable(text: $searchText, prompt: "Search products")
            .refreshable {
                await viewModel.refreshProducts()
            }
            .task {
                await viewModel.loadProducts()
            }
        }
    }
}

struct ProductListContent: View {
    let products: [Product]
    @Binding var searchText: String
    
    var filteredProducts: [Product] {
        if searchText.isEmpty {
            return products
        } else {
            return products.filter { product in
                product.name.localizedCaseInsensitiveContains(searchText) ||
                product.description.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        List(filteredProducts) { product in
            NavigationLink(destination: ProductDetailView(product: product)) {
                ProductRowView(product: product)
            }
        }
        .listStyle(.plain)
    }
}

struct ProductRowView: View {
    let product: Product
    
    var body: some View {
        HStack(spacing: 15) {
            // Product Image
            AsyncImage(url: URL(string: product.images.first ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
            }
            .frame(width: 60, height: 60)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            
            // Product Info
            VStack(alignment: .leading, spacing: 4) {
                Text(product.name)
                    .font(.headline)
                    .lineLimit(2)
                
                Text(product.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                HStack {
                    Text(product.price, format: .currency(code: "USD"))
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    if !product.isAvailable {
                        Text("Out of Stock")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
}
```

## UIKit Integration

### UIKit View Controller

```swift
class UserProfileViewController: UIViewController {
    private let viewModel: UserViewModel
    private let userId: UUID
    
    private lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 60
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var emailLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var editButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Edit Profile", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    init(userId: UUID, userUseCase: UserUseCase) {
        self.userId = userId
        self.viewModel = UserViewModel(userUseCase: userUseCase)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        loadUser()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(profileImageView)
        view.addSubview(nameLabel)
        view.addSubview(emailLabel)
        view.addSubview(editButton)
        
        NSLayoutConstraint.activate([
            profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            profileImageView.widthAnchor.constraint(equalToConstant: 120),
            profileImageView.heightAnchor.constraint(equalToConstant: 120),
            
            nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 20),
            nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            emailLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            emailLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            emailLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            editButton.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 30),
            editButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            editButton.widthAnchor.constraint(equalToConstant: 200),
            editButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    private func setupBindings() {
        viewModel.$user
            .receive(on: DispatchQueue.main)
            .sink { [weak self] user in
                self?.updateUI(with: user)
            }
            .store(in: &cancellables)
        
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                self?.updateLoadingState(isLoading)
            }
            .store(in: &cancellables)
        
        viewModel.$errorMessage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] errorMessage in
                if let errorMessage = errorMessage {
                    self?.showError(errorMessage)
                }
            }
            .store(in: &cancellables)
    }
    
    private func loadUser() {
        Task {
            await viewModel.loadUser(id: userId)
        }
    }
    
    private func updateUI(with user: User?) {
        guard let user = user else { return }
        
        nameLabel.text = user.name
        emailLabel.text = user.email
        
        if let profileImageURL = user.profileImage {
            // Load image using URLSession or image loading library
        }
    }
    
    private func updateLoadingState(_ isLoading: Bool) {
        if isLoading {
            // Show loading indicator
        } else {
            // Hide loading indicator
        }
    }
    
    private func showError(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
```

## Error Handling

### Presentation Errors

```swift
enum PresentationError: Error, LocalizedError {
    case invalidInput
    case networkError
    case userNotFound
    case validationFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidInput:
            return "Invalid input provided"
        case .networkError:
            return "Network connection error"
        case .userNotFound:
            return "User not found"
        case .validationFailed(let message):
            return "Validation failed: \(message)"
        }
    }
}
```

## Testing

### View Model Tests

```swift
class UserViewModelTests: XCTestCase {
    var userViewModel: UserViewModel!
    var mockUserUseCase: MockUserUseCase!
    
    override func setUp() {
        super.setUp()
        mockUserUseCase = MockUserUseCase()
        userViewModel = UserViewModel(userUseCase: mockUserUseCase)
    }
    
    func testLoadUserSuccess() async {
        // Given
        let expectedUser = User(id: UUID(), email: "test@example.com", name: "Test User")
        mockUserUseCase.mockUser = expectedUser
        
        // When
        await userViewModel.loadUser(id: expectedUser.id)
        
        // Then
        XCTAssertEqual(userViewModel.user?.id, expectedUser.id)
        XCTAssertEqual(userViewModel.user?.email, expectedUser.email)
        XCTAssertFalse(userViewModel.isLoading)
        XCTAssertNil(userViewModel.errorMessage)
    }
    
    func testLoadUserFailure() async {
        // Given
        let expectedError = DomainError.userNotFound
        mockUserUseCase.mockError = expectedError
        
        // When
        await userViewModel.loadUser(id: UUID())
        
        // Then
        XCTAssertNil(userViewModel.user)
        XCTAssertFalse(userViewModel.isLoading)
        XCTAssertEqual(userViewModel.errorMessage, expectedError.localizedDescription)
    }
}
```

## Best Practices

1. **MVVM Pattern**: Separate business logic from UI
2. **Reactive Programming**: Use Combine for data binding
3. **Error Handling**: Provide user-friendly error messages
4. **Loading States**: Show appropriate loading indicators
5. **Testing**: Mock dependencies for comprehensive testing
6. **Accessibility**: Ensure UI components are accessible 