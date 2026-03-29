import Foundation

struct Forum: Identifiable, Codable, Equatable {
    var id: UUID
    var name: String
    var icon: String
    var description: String
    var subscriberCount: Int
    var isSubscribed: Bool

    init(
        id: UUID = UUID(),
        name: String,
        icon: String = "bubble.left.and.bubble.right.fill",
        description: String = "",
        subscriberCount: Int = 0,
        isSubscribed: Bool = false
    ) {
        self.id = id
        self.name = name
        self.icon = icon
        self.description = description
        self.subscriberCount = subscriberCount
        self.isSubscribed = isSubscribed
    }
}
