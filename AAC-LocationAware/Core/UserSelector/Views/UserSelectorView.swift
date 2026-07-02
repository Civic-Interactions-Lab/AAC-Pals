import SwiftUI

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
                    HeroSection(adminName: authManager.currentUser?.email.components(separatedBy: "@").first ?? "")
                        .padding(.top, 16)

                    if userManager.isLoading {
                        ProgressView()
                            .tint(Color(hex: "#FF9F43"))
                            .scaleEffect(1.4)
                            .padding(.top, 80)
                    } else if userManager.profiles.isEmpty {
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
                            .foregroundStyle(Color(hex: "#FF9F43"))
                            .padding(12)
                            .background(Color.white.opacity(0.85), in: Circle())
                            .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 2)
                    }
                    .padding(.trailing, 24)
                    .padding(.top, 16)
                }
                Spacer()
            }

            if showAddUser {
                AddEditProfileModal(mode: .add, profile: nil, isPresented: $showAddUser)
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
        .task(id: authManager.currentUser?.id) {
            guard let adminId = authManager.currentUser?.id else { return }
            userManager.clearProfiles()
            await userManager.loadProfiles(adminId: adminId)
        }
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
                if let id = showDeleteConfirm?.id, let adminId = authManager.currentUser?.id {
                    Task { await userManager.deleteProfile(id: id, adminId: adminId) }
                }
                showDeleteConfirm = nil
            }
            Button("Cancel", role: .cancel) { showDeleteConfirm = nil }
        } message: {
            Text("This action cannot be undone.")
        }
        .toolbar(.hidden, for: .navigationBar)
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
        .task { await userManager.loadProfiles(adminId: "preview-admin") }
}

#Preview("Empty") {
    let authManager = AuthManager(service: MockAuthService(authUser: .mock))
    let userManager = UserManager(service: MockUserService(profiles: []))

    UserSelectorView()
        .environment(authManager)
        .environment(userManager)
        .environment(PictogramManager(service: MockPictogramService()))
        .task { await userManager.loadProfiles(adminId: "preview-admin") }
}
