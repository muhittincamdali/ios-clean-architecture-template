import SwiftUI
import Combine

/**
 * User List View - Presentation Layer
 * 
 * Professional SwiftUI view implementation with advanced features:
 * - Lazy loading
 * - Pull to refresh
 * - Search functionality
 * - Filtering options
 * - Smooth animations
 * - Accessibility support
 * 
 * - Author: iOS Clean Architecture Team
 * - Version: 2.0.0
 * - Date: 2024-01-15
 */

// MARK: - User List View
struct UserListView: View {
    
    // MARK: - Properties
    @StateObject private var viewModel: UserListViewModel
    @State private var searchText = ""
    @State private var selectedFilter: UserFilter = .all
    @State private var showingAddUser = false
    @State private var showingUserDetail = false
    @State private var selectedUser: User?
    @State private var isRefreshing = false
    
    // MARK: - Animation Properties
    @State private var animateList = false
    @State private var animateSearch = false
    @State private var animateFilter = false
    
    // MARK: - Initialization
    init(viewModel: UserListViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // MARK: - Search and Filter Section
                searchAndFilterSection
                
                // MARK: - Content Section
                contentSection
            }
            .navigationTitle("Users")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                toolbarContent
            }
            .refreshable {
                await refreshUsers()
            }
            .onAppear {
                setupAnimations()
                Task {
                    await viewModel.loadUsers()
                }
            }
            .sheet(isPresented: $showingAddUser) {
                AddUserView(viewModel: viewModel)
            }
            .sheet(isPresented: $showingUserDetail) {
                if let user = selectedUser {
                    UserDetailView(user: user, viewModel: viewModel)
                }
            }
        }
        .searchable(text: $searchText, prompt: "Search users...")
        .onChange(of: searchText) { newValue in
            Task {
                await viewModel.searchUsers(query: newValue)
            }
        }
    }
    
    // MARK: - Search and Filter Section
    private var searchAndFilterSection: some View {
        VStack(spacing: 16) {
            // Search Bar
            SearchBarView(
                text: $searchText,
                placeholder: "Search by name or email...",
                isAnimating: $animateSearch
            )
            .padding(.horizontal)
            
            // Filter Picker
            FilterPickerView(
                selectedFilter: $selectedFilter,
                isAnimating: $animateFilter
            ) { filter in
                Task {
                    await viewModel.filterUsers(by: filter)
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    // MARK: - Content Section
    private var contentSection: some View {
        Group {
            if viewModel.isLoading && viewModel.users.isEmpty {
                LoadingView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let error = viewModel.error {
                ErrorView(
                    error: error,
                    retryAction: {
                        Task {
                            await viewModel.loadUsers()
                        }
                    }
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.users.isEmpty {
                EmptyStateView(
                    title: "No Users Found",
                    message: "Try adjusting your search or filters",
                    actionTitle: "Add User",
                    action: {
                        showingAddUser = true
                    }
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                userListContent
            }
        }
    }
    
    // MARK: - User List Content
    private var userListContent: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(Array(viewModel.users.enumerated()), id: \.element.id) { index, user in
                    UserCardView(
                        user: user,
                        isAnimating: $animateList,
                        delay: Double(index) * 0.1
                    ) {
                        selectedUser = user
                        showingUserDetail = true
                    } onDelete: {
                        Task {
                            await viewModel.deleteUser(id: user.id)
                        }
                    }
                    .transition(.asymmetric(
                        insertion: .scale.combined(with: .opacity),
                        removal: .scale.combined(with: .opacity)
                    ))
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 100) // Space for floating action button
        }
        .overlay(
            // Floating Action Button
            FloatingActionButton(
                action: {
                    showingAddUser = true
                }
            )
            .padding(.trailing, 20)
            .padding(.bottom, 20),
            alignment: .bottomTrailing
        )
    }
    
    // MARK: - Toolbar Content
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button("Settings") {
                // Settings action
            }
            .foregroundColor(.primary)
        }
        
        ToolbarItem(placement: .navigationBarTrailing) {
            Menu {
                Button("Add User") {
                    showingAddUser = true
                }
                
                Button("Export Users") {
                    Task {
                        await viewModel.exportUsers()
                    }
                }
                
                Button("Refresh") {
                    Task {
                        await refreshUsers()
                    }
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .foregroundColor(.primary)
            }
        }
    }
    
    // MARK: - Private Methods
    private func setupAnimations() {
        withAnimation(.easeInOut(duration: 0.6)) {
            animateSearch = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.easeInOut(duration: 0.6)) {
                animateFilter = true
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation(.easeInOut(duration: 0.8)) {
                animateList = true
            }
        }
    }
    
    private func refreshUsers() async {
        isRefreshing = true
        await viewModel.loadUsers()
        isRefreshing = false
    }
}

// MARK: - User Card View
struct UserCardView: View {
    let user: User
    @Binding var isAnimating: Bool
    let delay: Double
    let onTap: () -> Void
    let onDelete: () -> Void
    
    @State private var isPressed = false
    @State private var showDeleteAlert = false
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Avatar
                UserAvatarView(user: user)
                    .frame(width: 50, height: 50)
                
                // User Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(user.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    Text(user.email)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                    
                    HStack(spacing: 8) {
                        UserRoleBadge(role: user.role)
                        
                        if user.isActive {
                            StatusBadge(isActive: user.isActive)
                        }
                    }
                }
                
                Spacer()
                
                // Action Buttons
                HStack(spacing: 8) {
                    Button(action: {
                        // Edit action
                    }) {
                        Image(systemName: "pencil")
                            .foregroundColor(.blue)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Button(action: {
                        showDeleteAlert = true
                    }) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(16)
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .opacity(isAnimating ? 1.0 : 0.0)
            .offset(y: isAnimating ? 0 : 50)
            .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(delay), value: isAnimating)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = pressing
            }
        }, perform: {})
        .alert("Delete User", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                onDelete()
            }
        } message: {
            Text("Are you sure you want to delete \(user.name)? This action cannot be undone.")
        }
    }
}

// MARK: - User Avatar View
struct UserAvatarView: View {
    let user: User
    
    var body: some View {
        Group {
            if let avatarURL = user.avatarURL, !avatarURL.isEmpty {
                AsyncImage(url: URL(string: avatarURL)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    placeholderView
                }
            } else {
                placeholderView
            }
        }
        .clipShape(Circle())
        .overlay(
            Circle()
                .stroke(Color.blue.opacity(0.3), lineWidth: 2)
        )
    }
    
    private var placeholderView: some View {
        ZStack {
            Circle()
                .fill(LinearGradient(
                    colors: [.blue, .purple],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
            
            Text(user.name.prefix(1).uppercased())
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
    }
}

// MARK: - User Role Badge
struct UserRoleBadge: View {
    let role: UserRole
    
    var body: some View {
        Text(role.displayName)
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(roleColor.opacity(0.2))
            .foregroundColor(roleColor)
            .cornerRadius(8)
    }
    
    private var roleColor: Color {
        switch role {
        case .user:
            return .blue
        case .moderator:
            return .orange
        case .admin:
            return .red
        }
    }
}

// MARK: - Status Badge
struct StatusBadge: View {
    let isActive: Bool
    
    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(isActive ? .green : .gray)
                .frame(width: 6, height: 6)
            
            Text(isActive ? "Active" : "Inactive")
                .font(.caption)
                .foregroundColor(isActive ? .green : .gray)
        }
    }
}

// MARK: - Search Bar View
struct SearchBarView: View {
    @Binding var text: String
    let placeholder: String
    @Binding var isAnimating: Bool
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField(placeholder, text: $text)
                .textFieldStyle(PlainTextFieldStyle())
            
            if !text.isEmpty {
                Button(action: {
                    text = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .opacity(isAnimating ? 1.0 : 0.0)
        .offset(x: isAnimating ? 0 : -50)
    }
}

// MARK: - Filter Picker View
struct FilterPickerView: View {
    @Binding var selectedFilter: UserFilter
    @Binding var isAnimating: Bool
    let onFilterChanged: (UserFilter) -> Void
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(UserFilter.allCases, id: \.self) { filter in
                    FilterChipView(
                        filter: filter,
                        isSelected: selectedFilter == filter
                    ) {
                        selectedFilter = filter
                        onFilterChanged(filter)
                    }
                }
            }
            .padding(.horizontal)
        }
        .opacity(isAnimating ? 1.0 : 0.0)
        .offset(y: isAnimating ? 0 : 30)
    }
}

// MARK: - Filter Chip View
struct FilterChipView: View {
    let filter: UserFilter
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(filter.displayName)
                .font(.caption)
                .fontWeight(.medium)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.blue : Color(.systemGray5))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(16)
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

// MARK: - Floating Action Button
struct FloatingActionButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "plus")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(width: 56, height: 56)
                .background(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(Circle())
                .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Loading View
struct LoadingView: View {
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
                .rotationEffect(.degrees(isAnimating ? 360 : 0))
                .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: isAnimating)
            
            Text("Loading users...")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .onAppear {
            isAnimating = true
        }
    }
}

// MARK: - Error View
struct ErrorView: View {
    let error: Error
    let retryAction: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.orange)
            
            Text("Something went wrong")
                .font(.headline)
            
            Text(error.localizedDescription)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Try Again") {
                retryAction()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

// MARK: - Empty State View
struct EmptyStateView: View {
    let title: String
    let message: String
    let actionTitle: String
    let action: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.3")
                .font(.system(size: 50))
                .foregroundColor(.secondary)
            
            Text(title)
                .font(.headline)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button(actionTitle) {
                action()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

// MARK: - User Filter
enum UserFilter: CaseIterable {
    case all
    case active
    case inactive
    case admin
    case moderator
    case user
    
    var displayName: String {
        switch self {
        case .all:
            return "All"
        case .active:
            return "Active"
        case .inactive:
            return "Inactive"
        case .admin:
            return "Admin"
        case .moderator:
            return "Moderator"
        case .user:
            return "User"
        }
    }
}

// MARK: - Preview
struct UserListView_Previews: PreviewProvider {
    static var previews: some View {
        UserListView(viewModel: UserListViewModel(
            getUserUseCase: MockGetUserUseCase(),
            getUsersUseCase: MockGetUsersUseCase(),
            createUserUseCase: MockCreateUserUseCase(),
            updateUserUseCase: MockUpdateUserUseCase(),
            deleteUserUseCase: MockDeleteUserUseCase(),
            searchUsersUseCase: MockSearchUsersUseCase()
        ))
    }
}
