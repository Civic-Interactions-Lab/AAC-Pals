import SwiftUI
import Charts

struct AdminView: View {
    @Environment(AuthManager.self) private var authManager
    @Environment(UserManager.self) private var userManager
    @Environment(AdminManager.self) private var adminManager
    @Environment(InteractionManager.self) private var interactionManager

    @State private var selectedUserId: String? = nil

    private var adminId: String { authManager.currentUser?.id ?? "" }
    private var analytics: AdminAnalytics { interactionManager.analytics }

    private func roomLabel(for id: String) -> String {
        adminManager.rooms.first(where: { $0.id == id })?.label ?? id
    }

    private func userName(for id: String) -> String {
        userManager.profiles.first(where: { $0.id == id })?.displayName ?? "Unknown"
    }

    var body: some View {
        ZStack {
            Color(hex: "#FFF7EE").ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    header
                    statsGrid
                    userFilter
                    activityChart
                    HStack(alignment: .top, spacing: 12) {
                        wordsPerUserChart
                        roomUsageChart
                    }
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

    // MARK: - Helpers

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
                Image(systemName: "arrow.clockwise")
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

    // MARK: - Activity Chart

    private struct DayCount: Identifiable {
        let id: Date
        let day: Date
        let count: Int
    }

    private var chartData: [DayCount] {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        // Build last 14 days as slots so every day appears even if 0 interactions
        let slots: [Date] = (0..<14).compactMap { offset in
            cal.date(byAdding: .day, value: -13 + offset, to: today)
        }
        let grouped = Dictionary(grouping: interactionManager.logs) { log in
            cal.startOfDay(for: log.pressedAt)
        }
        return slots.map { day in
            DayCount(id: day, day: day, count: grouped[day]?.count ?? 0)
        }
    }

    private var activityChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Activity (last 14 days)")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Color(hex: "#1A1A2E"))

            Chart(chartData) { entry in
                BarMark(
                    x: .value("Day", entry.day, unit: .day),
                    y: .value("Interactions", entry.count)
                )
                .foregroundStyle(Color(hex: "#FF9F43"))
                .cornerRadius(3)
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .day, count: 2)) { value in
                    AxisGridLine()
                    AxisValueLabel(format: .dateTime.month(.abbreviated).day())
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading) { _ in
                    AxisGridLine()
                    AxisValueLabel()
                }
            }
            .frame(height: 140)
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }

    // MARK: - Words Per User Chart

    private struct UserWordCount: Identifiable {
        let id: String
        let name: String
        let count: Int
    }

    private var wordsPerUserData: [UserWordCount] {
        let grouped = Dictionary(grouping: interactionManager.logs, by: \.userId)
        return grouped.map { userId, logs in
            UserWordCount(
                id: userId,
                name: userManager.profiles.first(where: { $0.id == userId })?.displayName ?? "Unknown",
                count: logs.count
            )
        }.sorted { $0.count > $1.count }
    }

    private var wordsPerUserChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Words per user")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Color(hex: "#1A1A2E"))

            if wordsPerUserData.isEmpty {
                Text("No data yet.")
                    .font(.system(size: 13))
                    .foregroundStyle(Color(hex: "#1A1A2E").opacity(0.4))
                    .padding(.vertical, 8)
            } else {
                Chart(wordsPerUserData) { entry in
                    BarMark(
                        x: .value("User", entry.name),
                        y: .value("Words", entry.count)
                    )
                    .foregroundStyle(Color(hex: "#FF6B6B"))
                    .cornerRadius(6)
                    .annotation(position: .top) {
                        Text("\(entry.count)")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(Color(hex: "#FF6B6B"))
                    }
                }
                .chartXAxis {
                    AxisMarks { _ in AxisValueLabel() }
                }
                .chartYAxis(.hidden)
                .frame(height: 140)
            }
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }

    // MARK: - Room Usage Chart

    private struct RoomShare: Identifiable {
        let id: String
        let label: String
        let count: Int
    }

    private let roomChartColors: [Color] = [
        Color(hex: "#FF9F43"), Color(hex: "#48DBFB"), Color(hex: "#1DD1A1"),
        Color(hex: "#FF6B6B"), Color(hex: "#A29BFE")
    ]

    private var roomShareData: [RoomShare] {
        let grouped = Dictionary(grouping: interactionManager.logs, by: \.roomId)
        return grouped.map { roomId, logs in
            RoomShare(id: roomId, label: roomLabel(for: roomId), count: logs.count)
        }.sorted { $0.count > $1.count }
    }

    private var roomUsageChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Room usage")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Color(hex: "#1A1A2E"))

            if roomShareData.isEmpty {
                Text("No data yet.")
                    .font(.system(size: 13))
                    .foregroundStyle(Color(hex: "#1A1A2E").opacity(0.4))
                    .padding(.vertical, 8)
            } else {
                HStack(spacing: 20) {
                    Chart(roomShareData) { entry in
                        SectorMark(
                            angle: .value("Count", entry.count),
                            innerRadius: .ratio(0.55),
                            angularInset: 2
                        )
                        .foregroundStyle(by: .value("Room", entry.label))
                        .cornerRadius(4)
                    }
                    .chartForegroundStyleScale(
                        domain: roomShareData.map(\.label),
                        range: roomChartColors.prefix(roomShareData.count).map { $0 }
                    )
                    .chartLegend(.hidden)
                    .frame(width: 120, height: 120)

                    VStack(alignment: .leading, spacing: 6) {
                        ForEach(Array(roomShareData.prefix(5).enumerated()), id: \.offset) { i, entry in
                            HStack(spacing: 6) {
                                Circle()
                                    .fill(roomChartColors[min(i, roomChartColors.count - 1)])
                                    .frame(width: 8, height: 8)
                                Text(entry.label)
                                    .font(.system(size: 12))
                                    .foregroundStyle(Color(hex: "#1A1A2E"))
                                    .lineLimit(1)
                                Spacer()
                                Text("\(entry.count)")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundStyle(Color(hex: "#9CA3AF"))
                            }
                        }
                    }
                }
                .frame(height: 140)
            }
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }

    // MARK: - Ranked Lists

    private var rankedLists: some View {
        HStack(alignment: .top, spacing: 12) {
            AdminRankedSection(
                title: "Top Words",
                items: analytics.topWords.map { ($0.word, $0.count) },
                emptyText: "No word activity yet."
            )

            AdminRankedSection(
                title: "Top Rooms",
                items: analytics.topRooms.map { (roomLabel(for: $0.roomId), $0.count) },
                emptyText: "No room activity yet."
            )

            if selectedUserId == nil {
                AdminRankedSection(
                    title: "Top Users",
                    items: analytics.topUsers.map { (userName(for: $0.userId), $0.count) },
                    emptyText: "No user activity yet."
                )
            }
        }
    }

    // MARK: - Recent Activity

    private struct UserDaySummary: Identifiable {
        let id: String  // userId + day string
        let userId: String
        let day: Date
        let wordCount: Int
        let topRoom: String
        let lastSeen: Date
    }

    private var activitySummaries: [UserDaySummary] {
        let cal = Calendar.current
        // Group all logs by (userId, day)
        let grouped = Dictionary(grouping: interactionManager.logs) { log in
            "\(log.userId)_\(cal.startOfDay(for: log.pressedAt).timeIntervalSince1970)"
        }
        let summaries = grouped.compactMap { key, logs -> UserDaySummary? in
            guard let first = logs.first else { return nil }
            let day = cal.startOfDay(for: first.pressedAt)
            let topRoomId = Dictionary(grouping: logs, by: \.roomId)
                .max(by: { $0.value.count < $1.value.count })?.key ?? first.roomId
            let lastSeen = logs.map(\.pressedAt).max() ?? first.pressedAt
            return UserDaySummary(
                id: key,
                userId: first.userId,
                day: day,
                wordCount: logs.count,
                topRoom: roomLabel(for: topRoomId),
                lastSeen: lastSeen
            )
        }
        return summaries.sorted { $0.lastSeen > $1.lastSeen }.prefix(20).map { $0 }
    }

    private var recentActivity: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Activity")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Color(hex: "#1A1A2E"))

            if activitySummaries.isEmpty {
                Text("No recent interactions found.")
                    .font(.system(size: 13))
                    .foregroundStyle(Color(hex: "#1A1A2E").opacity(0.4))
                    .padding(.vertical, 8)
            } else {
                VStack(spacing: 8) {
                    ForEach(activitySummaries) { summary in
                        HStack(spacing: 12) {
                            Circle()
                                .fill(Color(hex: "#FF9F43").opacity(0.15))
                                .frame(width: 40, height: 40)
                                .overlay(
                                    Text(String(userName(for: summary.userId).prefix(1)).uppercased())
                                        .font(.system(size: 15, weight: .bold))
                                        .foregroundStyle(Color(hex: "#FF9F43"))
                                )

                            VStack(alignment: .leading, spacing: 2) {
                                HStack(spacing: 6) {
                                    Text(userName(for: summary.userId))
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundStyle(Color(hex: "#1A1A2E"))
                                    Text("·")
                                        .foregroundStyle(Color(hex: "#9CA3AF"))
                                    Text("\(summary.wordCount) words")
                                        .font(.system(size: 13))
                                        .foregroundStyle(Color(hex: "#FF9F43"))
                                }
                                Text("in \(summary.topRoom)")
                                    .font(.system(size: 12))
                                    .foregroundStyle(Color(hex: "#1A1A2E").opacity(0.5))
                            }

                            Spacer()

                            VStack(alignment: .trailing, spacing: 2) {
                                Text(summary.day, style: .relative)
                                    .font(.system(size: 11))
                                    .foregroundStyle(Color(hex: "#1A1A2E").opacity(0.4))
                                Text(summary.lastSeen.formatted(.dateTime.hour().minute()))
                                    .font(.system(size: 11))
                                    .foregroundStyle(Color(hex: "#1A1A2E").opacity(0.3))
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(Color(hex: "#FF9F43").opacity(0.04))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
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
        await adminManager.loadRooms(adminId: adminId)
        await interactionManager.loadAnalytics(adminId: adminId, userId: selectedUserId)
    }
}

#Preview {
    AdminView().previewAllEnvironments()
}
