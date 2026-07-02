import SwiftUI

enum AppTab {
    case users
    case admin
}

struct MainTabView: View {
    @Environment(AuthManager.self) private var authManager
    @Environment(UserManager.self) private var userManager
    @State private var selectedTab: AppTab = .users

    var body: some View {
        ZStack(alignment: .topTrailing) {
            TabView(selection: $selectedTab) {
                UserSelectorView()
                    .tabItem { Label("Users", systemImage: "person.2.fill") }
                    .tag(AppTab.users)

                AdminView()
                    .tabItem { Label("Admin", systemImage: "chart.bar.fill") }
                    .tag(AppTab.admin)
            }
            .tint(Color(hex: "#FF9F43"))

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
            .padding(.top, 16)
            .padding(.trailing, 24)
        }
    }
}

#Preview {
    MainTabView().previewAllEnvironments()
}
