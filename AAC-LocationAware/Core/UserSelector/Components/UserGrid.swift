import SwiftUI

struct UserGrid: View {
    @Environment(UserManager.self) private var userManager
    let onEdit: (UserProfile) -> Void
    let onDelete: (UserProfile) -> Void
    let onAdd: () -> Void
    let onSelectPending: (UserProfile) -> Void

    var body: some View {
        LazyVGrid(
            columns: [GridItem(.adaptive(minimum: 200, maximum: 240), spacing: 28)],
            spacing: 28
        ) {
            ForEach(userManager.profiles) { profile in
                UserCard(
                    profile: profile,
                    onSelect: { onSelectPending(profile) },
                    onEdit: { onEdit(profile) },
                    onDelete: { onDelete(profile) }
                )
            }
            AddUserCard(action: onAdd)
        }
        .padding(.horizontal, 32)
    }
}

#Preview {
    let userManager = UserManager(service: MockUserService())
    ZStack {
        DecorativeBackground()
        ScrollView {
            UserGrid(onEdit: { _ in }, onDelete: { _ in }, onAdd: {}, onSelectPending: { _ in })
                .padding(.top, 16)
        }
    }
    .environment(userManager)
    .task { await userManager.loadProfiles(adminId: "preview-admin") }
}
