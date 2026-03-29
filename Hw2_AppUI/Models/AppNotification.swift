import Foundation

struct AppNotification: Identifiable, Codable, Equatable {
    var id: UUID
    var type: NotificationType
    var title: String
    var message: String
    var timestamp: Date
    var isRead: Bool
    var relatedPostId: UUID?

    enum NotificationType: String, Codable {
        case like = "like"
        case comment = "comment"
        case follow = "follow"
        case system = "system"

        var icon: String {
            switch self {
            case .like: return "heart.fill"
            case .comment: return "bubble.left.fill"
            case .follow: return "person.badge.plus"
            case .system: return "bell.fill"
            }
        }

        var color: String {
            switch self {
            case .like: return "notifLike"
            case .comment: return "notifComment"
            case .follow: return "notifFollow"
            case .system: return "notifSystem"
            }
        }
    }

    init(
        id: UUID = UUID(),
        type: NotificationType,
        title: String,
        message: String,
        timestamp: Date = Date(),
        isRead: Bool = false,
        relatedPostId: UUID? = nil
    ) {
        self.id = id
        self.type = type
        self.title = title
        self.message = message
        self.timestamp = timestamp
        self.isRead = isRead
        self.relatedPostId = relatedPostId
    }
}
