import Foundation

struct Comment: Identifiable, Codable, Equatable {
    var id: UUID
    var postId: UUID
    var authorName: String
    var authorAvatar: String
    var authorGender: Gender
    var content: String
    var timestamp: Date
    var likeCount: Int
    var isLiked: Bool
    var floor: Int
    var replyToFloor: Int?

    init(
        id: UUID = UUID(),
        postId: UUID,
        authorName: String = "匿名",
        authorAvatar: String = "person.circle.fill",
        authorGender: Gender = .male,
        content: String,
        timestamp: Date = Date(),
        likeCount: Int = 0,
        isLiked: Bool = false,
        floor: Int = 1,
        replyToFloor: Int? = nil
    ) {
        self.id = id
        self.postId = postId
        self.authorName = authorName
        self.authorAvatar = authorAvatar
        self.authorGender = authorGender
        self.content = content
        self.timestamp = timestamp
        self.likeCount = likeCount
        self.isLiked = isLiked
        self.floor = floor
        self.replyToFloor = replyToFloor
    }
}
