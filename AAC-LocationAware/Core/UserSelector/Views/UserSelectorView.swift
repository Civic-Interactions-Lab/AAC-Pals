import SwiftUI

// MARK: - UserSelectorView

struct UserSelectorView: View {
    @Environment(AuthManager.self) private var authManager
    @Environment(UserManager.self) private var userManager

    @State private var showAddUser = false
    @State private var showEditUser: UserProfile? = nil
    @State private var showDeleteConfirm: UserProfile? = nil

    var body: some View {
        ZStack {
            DecorativeBackground()

            ScrollView {
                VStack(spacing: 0) {
                    HeroSection()
                        .padding(.top, 16)

                    if userManager.profiles.isEmpty {
                        EmptyState(onAdd: { showAddUser = true })
                            .padding(.top, 48)
                    } else {
                        UserGrid(
                            onEdit: { showEditUser = $0 },
                            onDelete: { showDeleteConfirm = $0 },
                            onAdd: { showAddUser = true }
                        )
                        .padding(.top, 12)
                        .padding(.bottom, 48)
                    }
                }
            }

            // Floating shapes — bottom right
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    FloatingShapes()
                        .frame(width: 120, height: 110)
                        .padding(.trailing, 32)
                        .padding(.bottom, 32)
                }
            }

            // Sign out gear — top right
            VStack {
                HStack {
                    Spacer()
                    Menu {
                        Button(role: .destructive) {
                            Task {
                                userManager.exitProfile()
                                await authManager.signOut()
                            }
                        } label: {
                            Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                        }
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(Color(hex: "#FF9F43").opacity(0.7))
                            .padding(12)
                            .background(.ultraThinMaterial, in: Circle())
                    }
                    .padding(.trailing, 24)
                    .padding(.top, 16)
                }
                Spacer()
            }

            // Modals
            if showAddUser {
                AddEditProfileModal(
                    mode: .add,
                    profile: nil,
                    isPresented: $showAddUser
                )
                .transition(.opacity)
            }

            if let profile = showEditUser {
                AddEditProfileModal(
                    mode: .edit,
                    profile: profile,
                    isPresented: Binding(
                        get: { showEditUser != nil },
                        set: { if !$0 { showEditUser = nil } }
                    )
                )
                .transition(.opacity)
            }
        }
        .ignoresSafeArea(.keyboard)
        .animation(.easeOut(duration: 0.18), value: showAddUser)
        .animation(.easeOut(duration: 0.18), value: showEditUser?.id)
        .confirmationDialog(
            "Delete \(showDeleteConfirm?.displayName ?? "user")?",
            isPresented: Binding(
                get: { showDeleteConfirm != nil },
                set: { if !$0 { showDeleteConfirm = nil } }
            ),
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                if let id = showDeleteConfirm?.id { Task { await userManager.deleteProfile(id: id) } }
                showDeleteConfirm = nil
            }
            Button("Cancel", role: .cancel) { showDeleteConfirm = nil }
        } message: {
            Text("This action cannot be undone.")
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

// MARK: - DecorativeBackground

private struct DecorativeBackground: View {
    var body: some View {
        ZStack {
            Color(hex: "#FFF7EE").ignoresSafeArea()

            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height

                Circle()
                    .fill(Color(hex: "#FF9F43").opacity(0.08))
                    .frame(width: 320, height: 320)
                    .offset(x: w * 0.78, y: h * 0.72)
                    .blur(radius: 40)

                Circle()
                    .fill(Color(hex: "#A29BFE").opacity(0.10))
                    .frame(width: 240, height: 240)
                    .offset(x: w * 0.88, y: h * 0.80)
                    .blur(radius: 36)

                Circle()
                    .fill(Color(hex: "#1DD1A1").opacity(0.08))
                    .frame(width: 200, height: 200)
                    .offset(x: w * 0.70, y: h * 0.85)
                    .blur(radius: 32)

                Circle()
                    .fill(Color(hex: "#FD79A8").opacity(0.07))
                    .frame(width: 160, height: 160)
                    .offset(x: w * 0.92, y: h * 0.88)
                    .blur(radius: 28)
            }
            .ignoresSafeArea()
        }
    }
}

// MARK: - HeroSection

private struct HeroSection: View {
    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Text("👋")
                        .font(.system(size: 18))
                    Text("Welcome back!")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(Color(hex: "#FF9F43"))
                }

                Text("Who's learning\ntoday?")
                    .font(.system(size: 30, weight: .black, design: .rounded))
                    .foregroundStyle(Color(hex: "#1A1A2E"))
                    .lineSpacing(2)

                Text("Choose a user to continue\ntheir adventure.")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(Color(hex: "#9CA3AF"))
                    .lineSpacing(2)
            }
            .padding(.leading, 32)

            Spacer()
        }
        .padding(.bottom, 28)
    }
}

private struct FloatingShapes: View {
    @State private var animate = false

    var body: some View {
        ZStack {
            Circle()
                .fill(LinearGradient(colors: [Color(hex: "#FF6B6B"), Color(hex: "#FF9F43")], startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 48, height: 48)
                .offset(x: -10, y: animate ? -6 : 0)
                .animation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true), value: animate)

            Circle()
                .fill(LinearGradient(colors: [Color(hex: "#A29BFE"), Color(hex: "#6C5CE7")], startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 32, height: 32)
                .offset(x: 36, y: animate ? 4 : -4)
                .animation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true).delay(0.4), value: animate)

            Circle()
                .fill(LinearGradient(colors: [Color(hex: "#1DD1A1"), Color(hex: "#00B894")], startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 22, height: 22)
                .offset(x: 16, y: animate ? 44 : 38)
                .animation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true).delay(0.8), value: animate)

            RoundedRectangle(cornerRadius: 8)
                .fill(LinearGradient(colors: [Color(hex: "#FD79A8"), Color(hex: "#E84393")], startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 20, height: 20)
                .rotationEffect(.degrees(animate ? 30 : 10))
                .offset(x: -28, y: animate ? 52 : 44)
                .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true).delay(0.2), value: animate)
        }
        .onAppear { animate = true }
    }
}

// MARK: - UserGrid

private struct UserGrid: View {
    @Environment(UserManager.self) private var userManager
    let onEdit: (UserProfile) -> Void
    let onDelete: (UserProfile) -> Void
    let onAdd: () -> Void

    var body: some View {
        LazyVGrid(
            columns: [GridItem(.adaptive(minimum: 200, maximum: 240), spacing: 28)],
            spacing: 28
        ) {
            ForEach(userManager.profiles) { profile in
                UserCard(
                    profile: profile,
                    onSelect: { userManager.selectProfile(profile) },
                    onEdit: { onEdit(profile) },
                    onDelete: { onDelete(profile) }
                )
            }
            AddUserCard(action: onAdd)
        }
        .padding(.horizontal, 32)
    }
}

// MARK: - UserCard

private struct UserCard: View {
    let profile: UserProfile
    let onSelect: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void

    @State private var isPressed = false

    private static let gradientPairs: [(String, String)] = [
        ("#FF6B6B", "#FF9F43"),
        ("#A29BFE", "#6C5CE7"),
        ("#54A0FF", "#2E86DE"),
        ("#1DD1A1", "#00B894"),
        ("#FD79A8", "#E84393"),
        ("#FDCB6E", "#E17055"),
    ]

    private var avatarGradient: LinearGradient {
        let pair = Self.gradientPairs[abs(profile.id.hashValue) % Self.gradientPairs.count]
        return LinearGradient(
            colors: [Color(hex: pair.0), Color(hex: pair.1)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var initials: String {
        profile.displayName
            .split(separator: " ")
            .prefix(2)
            .compactMap { $0.first.map(String.init) }
            .joined()
            .uppercased()
    }

    var body: some View {
        VStack(spacing: 20) {
            // Avatar
            ZStack {
                Circle()
                    .fill(avatarGradient)
                    .frame(width: 100, height: 100)
                    .shadow(color: Color(hex: "#FF9F43").opacity(0.35), radius: 16, x: 0, y: 8)

                Text(initials.isEmpty ? "?" : initials)
                    .font(.system(size: 38, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
            }

            // Name + subtitle
            VStack(spacing: 4) {
                Text(profile.displayName)
                    .font(.system(size: 18, weight: .black, design: .rounded))
                    .foregroundStyle(Color(hex: "#1A1A2E"))
                    .lineLimit(1)

                Text("Ready to learn!")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(Color(hex: "#B2BEC3"))
            }

            // Continue button
            Button(action: onSelect) {
                HStack(spacing: 6) {
                    Text("Continue")
                        .font(.system(size: 15, weight: .black, design: .rounded))
                    Image(systemName: "arrow.right")
                        .font(.system(size: 13, weight: .bold))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    LinearGradient(
                        colors: [Color(hex: "#FF9F43"), Color(hex: "#FF6B6B")],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .buttonStyle(.plain)
        }
        .padding(24)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 28))
        .shadow(color: .black.opacity(0.07), radius: 24, x: 0, y: 8)
        .scaleEffect(isPressed ? 0.97 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.65), value: isPressed)
        .contextMenu {
            Button {
                onEdit()
            } label: {
                Label("Rename", systemImage: "pencil")
            }

            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}

// MARK: - AddUserCard

private struct AddUserCard: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(Color(hex: "#FF9F43").opacity(0.05))
                        .frame(width: 100, height: 100)
                    Circle()
                        .strokeBorder(
                            Color(hex: "#FF9F43"),
                            style: StrokeStyle(lineWidth: 2.5, dash: [6, 4])
                        )
                        .frame(width: 100, height: 100)
                    Image(systemName: "plus")
                        .font(.system(size: 34, weight: .semibold))
                        .foregroundStyle(Color(hex: "#FF9F43"))
                }

                VStack(spacing: 4) {
                    Text("New User")
                        .font(.system(size: 18, weight: .black, design: .rounded))
                        .foregroundStyle(Color(hex: "#FF9F43"))

                    Text("Start a new adventure")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(Color(hex: "#FF9F43").opacity(0.55))
                }

                // Placeholder to match card height
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(hex: "#FF9F43").opacity(0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(Color(hex: "#FF9F43").opacity(0.3), lineWidth: 1.5)
                    )
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .overlay(
                        HStack(spacing: 6) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 15))
                            Text("Add User")
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                        }
                        .foregroundStyle(Color(hex: "#FF9F43"))
                    )
            }
            .padding(24)
            .background(
                ZStack {
                    Color.white
                    Color(hex: "#FF9F43").opacity(0.05)
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 28))
            .overlay(
                RoundedRectangle(cornerRadius: 28)
                    .strokeBorder(
                        Color(hex: "#FF9F43"),
                        style: StrokeStyle(lineWidth: 2, dash: [8, 5])
                    )
            )
            .shadow(color: Color(hex: "#FF9F43").opacity(0.10), radius: 20, x: 0, y: 6)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - EmptyState

private struct EmptyState: View {
    let onAdd: () -> Void

    var body: some View {
        VStack(spacing: 28) {
            ZStack {
                Circle()
                    .fill(Color(hex: "#FF9F43").opacity(0.1))
                    .frame(width: 120, height: 120)

                Image(systemName: "person.3.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(hex: "#FF9F43"), Color(hex: "#FF6B6B")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }

            VStack(spacing: 8) {
                Text("No users yet")
                    .font(.system(size: 24, weight: .black, design: .rounded))
                    .foregroundStyle(Color(hex: "#1A1A2E"))

                Text("Add your first user to get started")
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundStyle(Color(hex: "#9CA3AF"))
                    .multilineTextAlignment(.center)
            }

            Button(action: onAdd) {
                HStack(spacing: 8) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 17))
                    Text("Create User")
                        .font(.system(size: 17, weight: .black, design: .rounded))
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 40)
                .padding(.vertical, 18)
                .background(
                    LinearGradient(
                        colors: [Color(hex: "#FF9F43"), Color(hex: "#FF6B6B")],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(Capsule())
                .shadow(color: Color(hex: "#FF9F43").opacity(0.4), radius: 16, x: 0, y: 8)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 40)
    }
}

// MARK: - ProfileNameMode

enum ProfileNameMode { case add, edit }

// MARK: - AddEditProfileModal

private struct AddEditProfileModal: View {
    @Environment(UserManager.self) private var userManager

    let mode: ProfileNameMode
    let profile: UserProfile?
    @Binding var isPresented: Bool

    @State private var name = ""
    @State private var isSaving = false
    @FocusState private var focused: Bool

    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        ZStack {
            Color.black.opacity(0.35)
                .ignoresSafeArea()
                .onTapGesture { isPresented = false }

            VStack(alignment: .leading, spacing: 20) {
                // Title
                VStack(alignment: .leading, spacing: 4) {
                    Text(mode == .add ? "👤 Add User" : "✏️ Edit Name")
                        .font(.system(size: 22, weight: .black, design: .rounded))
                        .foregroundStyle(Color(hex: "#1A1A2E"))

                    Text("What should we call this user?")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(Color(hex: "#9CA3AF"))
                }

                // Text field
                TextField(mode == .add ? "e.g. Alex" : "New name", text: $name)
                    .font(.system(size: 17, weight: .medium, design: .rounded))
                    .padding(16)
                    .background(Color(hex: "#FFF7EE"))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .strokeBorder(
                                focused ? Color(hex: "#FF9F43") : Color(hex: "#FF9F43").opacity(0.25),
                                lineWidth: focused ? 2 : 1.5
                            )
                    )
                    .textInputAutocapitalization(.words)
                    .submitLabel(.done)
                    .focused($focused)
                    .onSubmit { save() }

                // Buttons
                HStack(spacing: 12) {
                    Button("Cancel") {
                        isPresented = false
                    }
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color(hex: "#FF9F43"))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color(hex: "#FF9F43").opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .buttonStyle(.plain)

                    Button(action: save) {
                        Group {
                            if isSaving {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text(mode == .add ? "Add" : "Save")
                                    .font(.system(size: 15, weight: .black, design: .rounded))
                            }
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            Group {
                                if isValid {
                                    LinearGradient(
                                        colors: [Color(hex: "#FF9F43"), Color(hex: "#FF6B6B")],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                } else {
                                    LinearGradient(
                                        colors: [Color(hex: "#E5E7EB"), Color(hex: "#E5E7EB")],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                }
                            }
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .buttonStyle(.plain)
                    .disabled(!isValid || isSaving)
                }
            }
            .padding(28)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 28))
            .shadow(color: .black.opacity(0.18), radius: 48, x: 0, y: 20)
            .frame(maxWidth: 400)
            .padding(.horizontal, 28)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea(.keyboard)
        .onAppear {
            if mode == .edit { name = profile?.displayName ?? "" }
            Task { @MainActor in focused = true }
        }
    }

    private func save() {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        isSaving = true
        if mode == .add {
            Task { await userManager.addProfile(displayName: trimmed) }
        } else if let id = profile?.id {
            Task { await userManager.renameProfile(id: id, displayName: trimmed) }
        }
        isPresented = false
    }
}

// MARK: - Previews

#Preview("With users") {
    let authManager = AuthManager(service: MockAuthService(authUser: .mock))
    let userManager = UserManager(service: MockUserService())
    
    UserSelectorView()
        .environment(authManager)
        .environment(userManager)
        .environment(PictogramManager(service: MockPictogramService()))
        .task { await userManager.loadProfiles() }
}

#Preview("Empty") {
    let authManager = AuthManager(service: MockAuthService(authUser: .mock))
    let userManager = UserManager(service: MockUserService(profiles: []))
    UserSelectorView()
        .environment(authManager)
        .environment(userManager)
        .environment(PictogramManager(service: MockPictogramService()))
        .task { await userManager.loadProfiles() }
}
