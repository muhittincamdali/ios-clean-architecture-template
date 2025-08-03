import SwiftUI

/**
 * User View - Presentation Layer
 * 
 * This view displays user information with premium UI/UX design.
 * It follows SwiftUI best practices and Clean Architecture principles.
 * 
 * - Author: iOS Clean Architecture Team
 * - Version: 2.0.0
 * - Date: 2024-01-15
 */
struct UserView: View {
    @StateObject private var viewModel: UserViewModel
    @State private var showingCreateUser = false
    @State private var showingEditUser = false
    @State private var selectedUser: User?
    
    init(getUserUseCase: GetUserUseCaseProtocol,
         getUsersUseCase: GetUsersUseCaseProtocol,
         createUserUseCase: CreateUserUseCaseProtocol,
         updateUserUseCase: UpdateUserUseCaseProtocol,
         deleteUserUseCase: DeleteUserUseCaseProtocol,
         searchUsersUseCase: SearchUsersUseCaseProtocol) {
        self._viewModel = StateObject(wrappedValue: UserViewModel(
            getUserUseCase: getUserUseCase,
            getUsersUseCase: getUsersUseCase,
            createUserUseCase: createUserUseCase,
            updateUserUseCase: updateUserUseCase,
            deleteUserUseCase: deleteUserUseCase,
            searchUsersUseCase: searchUsersUseCase
        ))
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Bar
                SearchBar(text: $viewModel.searchQuery) {
                    Task {
                        await viewModel.searchUsers(query: viewModel.searchQuery)
                    }
                }
                .padding(.horizontal)
                .padding(.top)
                
                // Filter Picker
                FilterPicker(selectedRole: $viewModel.selectedRole) {
                    Task {
                        await viewModel.filterUsersByRole(viewModel.selectedRole)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
                
                // Content
                if viewModel.isLoading && viewModel.users.isEmpty {
                    LoadingView()
                } else if let error = viewModel.error {
                    ErrorView(error: error) {
                        Task {
                            await viewModel.retry()
                        }
                    }
                } else if viewModel.users.isEmpty {
                    EmptyStateView()
                } else {
                    UserListView(
                        users: viewModel.users,
                        onUserTap: { user in
                            selectedUser = user
                        },
                        onDeleteUser: { user in
                            Task {
                                await viewModel.deleteUser(id: user.id)
                            }
                        }
                    )
                    .refreshable {
                        await viewModel.refreshUsers()
                    }
                }
            }
            .navigationTitle("Users")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingCreateUser = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.primaryBlue)
                            .font(.title2)
                    }
                }
            }
            .task {
                await viewModel.loadUsers()
            }
            .sheet(isPresented: $showingCreateUser) {
                CreateUserView { name, email, role in
                    Task {
                        let success = await viewModel.createUser(name: name, email: email, role: role)
                        if success {
                            showingCreateUser = false
                        }
                    }
                }
            }
            .sheet(item: $selectedUser) { user in
                UserDetailView(user: user) { updatedUser in
                    Task {
                        await viewModel.updateUser(updatedUser)
                    }
                }
            }
        }
        .alert("Error", isPresented: .constant(viewModel.error != nil)) {
            Button("OK") {
                viewModel.clearError()
            }
        } message: {
            if let error = viewModel.error {
                Text(error.localizedDescription)
            }
        }
    }
}

// MARK: - Search Bar
struct SearchBar: View {
    @Binding var text: String
    let onSearch: () -> Void
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Search users...", text: $text)
                .textFieldStyle(PlainTextFieldStyle())
                .onSubmit {
                    onSearch()
                }
            
            if !text.isEmpty {
                Button(action: {
                    text = ""
                    onSearch()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - Filter Picker
struct FilterPicker: View {
    @Binding var selectedRole: UserRole?
    let onFilter: () -> Void
    
    var body: some View {
        HStack {
            Text("Filter:")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Picker("Role", selection: $selectedRole) {
                Text("All Roles").tag(nil as UserRole?)
                ForEach(UserRole.allCases, id: \.self) { role in
                    Text(role.displayName).tag(role as UserRole?)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .onChange(of: selectedRole) { _ in
                onFilter()
            }
        }
    }
}

// MARK: - User List View
struct UserListView: View {
    let users: [User]
    let onUserTap: (User) -> Void
    let onDeleteUser: (User) -> Void
    
    var body: some View {
        List(users) { user in
            UserRowView(user: user)
                .onTapGesture {
                    onUserTap(user)
                }
                .swipeActions(edge: .trailing) {
                    Button(role: .destructive) {
                        onDeleteUser(user)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
        }
        .listStyle(PlainListStyle())
    }
}

// MARK: - User Row View
struct UserRowView: View {
    let user: User
    
    var body: some View {
        HStack(spacing: 12) {
            // Avatar
            if user.hasAvatar {
                AsyncImage(url: URL(string: user.avatarURL!)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Image(systemName: "person.circle.fill")
                        .foregroundColor(.gray)
                }
                .frame(width: 50, height: 50)
                .clipShape(Circle())
            } else {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.primaryBlue)
            }
            
            // User Info
            VStack(alignment: .leading, spacing: 4) {
                Text(user.displayName)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(user.email)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                HStack {
                    Text(user.role.displayName)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(roleColor.opacity(0.2))
                        .foregroundColor(roleColor)
                        .cornerRadius(8)
                    
                    if !user.isActive {
                        Text("Inactive")
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.red.opacity(0.2))
                            .foregroundColor(.red)
                            .cornerRadius(8)
                    }
                }
            }
            
            Spacer()
            
            // Status Indicator
            Circle()
                .fill(user.isActive ? Color.green : Color.red)
                .frame(width: 8, height: 8)
        }
        .padding(.vertical, 4)
    }
    
    private var roleColor: Color {
        switch user.role {
        case .user:
            return .blue
        case .moderator:
            return .orange
        case .admin:
            return .red
        }
    }
}

// MARK: - Loading View
struct LoadingView: View {
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            
            Text("Loading users...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Error View
struct ErrorView: View {
    let error: Error
    let retryAction: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 50))
                .foregroundColor(.orange)
            
            Text("Something went wrong")
                .font(.headline)
            
            Text(error.localizedDescription)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Retry") {
                retryAction()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Empty State View
struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.3.fill")
                .font(.system(size: 50))
                .foregroundColor(.gray)
            
            Text("No users found")
                .font(.headline)
            
            Text("Users will appear here once they are added to the system.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
} 