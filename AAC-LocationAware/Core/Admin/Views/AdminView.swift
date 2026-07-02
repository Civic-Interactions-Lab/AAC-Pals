import SwiftUI

struct AdminView: View {
    @Environment(AuthManager.self) private var authManager
    @Environment(UserManager.self) private var userManager
    @Environment(InteractionManager.self) private var interactionManager

    @State private var selectedUserId: String? = nil

    private var adminId: String { authManager.currentUser?.id ?? "" }
    private var analytics: AdminAnalytics { interactionManager.analytics }

    var body: some View {
        ZStack {
            Color(hex: "#FFF7EE").ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    header
                    statsGrid
                    userFilter
                    rankedLists
                    recentActivity
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 20)
            }
        }
        .task(id: adminId) {
            await load()
        }
        .onChange(of: selectedUserId) {
            Task { await load() }
        }
    }

    // MARK: - Sections

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text("Analytics")
                    .font(.system(size: 30, weight: .black, design: .rounded))
                    .foregroundStyle(Color(hex: "#1A1A2E"))
                Text("Interaction overview for your users")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(Color(hex: "#9CA3AF"))
            }
            Spacer()
            Button {
                Task { await load() }
            } label: {
                Image(systemName: interactionManager.isLoading ? "arrow.clockwise" : "arrow.clockwise")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(Color(hex: "#FF9F43"))
                    .rotationEffect(.degrees(interactionManager.isLoading ? 360 : 0))
                    .animation(interactionManager.isLoading ? .linear(duration: 1).repeatForever(autoreverses: false) : .default, value: interactionManager.isLoading)
                    .frame(width: 40, height: 40)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 2)
            }
            .disabled(interactionManager.isLoading)
        }
    }

    private var statsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            AdminStatCard(label: "Interactions", value: analytics.totalInteractions, icon: "hand.tap.fill", color: Color(hex: "#FF9F43"))
            AdminStatCard(label: "Users", value: analytics.uniqueUsers, icon: "person.2.fill", color: Color(hex: "#FF6B6B"))
            AdminStatCard(label: "Rooms", value: analytics.uniqueRooms, icon: "mappin.circle.fill", color: Color(hex: "#48DBFB"))
            AdminStatCard(label: "Words", value: analytics.uniqueWords, icon: "text.bubble.fill", color: Color(hex: "#1DD1A1"))
        }
    }

    private var userFilter: some View {
        AdminUserFilterBar(users: userManager.profiles, selectedUserId: $selectedUserId)
            .padding(.horizontal, -20)
    }

    private var rankedLists: some View {
        HStack(alignment: .top, spacing: 12) {
            AdminRankedSection(
                title: "Top Words",
                items: analytics.topWords.map { ($0.word, $0.count) },
                emptyText: "No word activity yet."
            )

            AdminRankedSection(
                title: "Top Rooms",
                items: analytics.topRooms.map { ($0.roomId.capitalized, $0.count) },
                emptyText: "No room activity yet."
            )

            if selectedUserId == nil {
                AdminRankedSection(
                    title: "Top Users",
                    items: analytics.topUsers.map { (userId, count) in
                        let name = userManager.profiles.first(where: { $0.id == userId })?.displayName ?? "Unknown"
                        return (name, count)
                    },
                    emptyText: "No user activity yet."
                )
            }
        }
    }

    private var recentActivity: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Activity")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Color(hex: "#1A1A2E"))

            if analytics.recentLogs.isEmpty {
                Text("No recent interactions found.")
                    .font(.system(size: 13))
                    .foregroundStyle(Color(hex: "#1A1A2E").opacity(0.4))
                    .padding(.vertical, 8)
            } else {
                VStack(spacing: 6) {
                    ForEach(analytics.recentLogs) { log in
                        AdminRecentLogRow(log: log)
                    }
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }

    // MARK: - Load

    private func load() async {
        await interactionManager.loadAnalytics(adminId: adminId, userId: selectedUserId)
    }
}

#Preview {
    AdminView().previewAllEnvironments()
}
