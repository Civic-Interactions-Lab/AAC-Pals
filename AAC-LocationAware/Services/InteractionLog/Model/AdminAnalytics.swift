import Foundation

struct AdminAnalytics {
    var totalInteractions: Int = 0
    var uniqueUsers: Int = 0
    var uniqueRooms: Int = 0
    var uniqueWords: Int = 0
    var topWords: [(word: String, count: Int)] = []
    var topRooms: [(roomId: String, count: Int)] = []
    var topUsers: [(userId: String, count: Int)] = []
    var recentLogs: [InteractionLog] = []

    static func compute(from logs: [InteractionLog]) -> AdminAnalytics {
        var analytics = AdminAnalytics()
        analytics.totalInteractions = logs.count
        analytics.uniqueUsers = Set(logs.map(\.userId)).count
        analytics.uniqueRooms = Set(logs.map(\.roomId)).count

        let wordCounts = Dictionary(grouping: logs, by: \.word).mapValues(\.count)
        analytics.uniqueWords = wordCounts.keys.count
        analytics.topWords = wordCounts.sorted { $0.value > $1.value }.prefix(5).map { ($0.key, $0.value) }

        let roomCounts = Dictionary(grouping: logs, by: \.roomId).mapValues(\.count)
        analytics.topRooms = roomCounts.sorted { $0.value > $1.value }.prefix(5).map { ($0.key, $0.value) }

        let userCounts = Dictionary(grouping: logs, by: \.userId).mapValues(\.count)
        analytics.topUsers = userCounts.sorted { $0.value > $1.value }.prefix(5).map { ($0.key, $0.value) }

        analytics.recentLogs = Array(logs.prefix(25))
        return analytics
    }
}
