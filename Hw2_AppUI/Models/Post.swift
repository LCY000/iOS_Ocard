import Foundation

struct Post: Identifiable, Codable, Equatable {
    var id: UUID
    var authorId: UUID
    var authorName: String
    var authorAvatar: String
    var authorGender: Gender
    var board: String
    var title: String
    var content: String
    var imageName: String?
    var timestamp: Date
    var likeCount: Int
    var dislikeCount: Int
    var commentCount: Int
    var bookmarkCount: Int
    var isLiked: Bool
    var isDisliked: Bool
    var isBookmarked: Bool

    init(
        id: UUID = UUID(),
        authorId: UUID = UUID(),
        authorName: String = "匿名",
        authorAvatar: String = "person.circle.fill",
        authorGender: Gender = .male,
        board: String = "閒聊",
        title: String,
        content: String,
        imageName: String? = nil,
        timestamp: Date = Date(),
        likeCount: Int = 0,
        dislikeCount: Int = 0,
        commentCount: Int = 0,
        bookmarkCount: Int = 0,
        isLiked: Bool = false,
        isDisliked: Bool = false,
        isBookmarked: Bool = false
    ) {
        self.id = id
        self.authorId = authorId
        self.authorName = authorName
        self.authorAvatar = authorAvatar
        self.authorGender = authorGender
        self.board = board
        self.title = title
        self.content = content
        self.imageName = imageName
        self.timestamp = timestamp
        self.likeCount = likeCount
        self.dislikeCount = dislikeCount
        self.commentCount = commentCount
        self.bookmarkCount = bookmarkCount
        self.isLiked = isLiked
        self.isDisliked = isDisliked
        self.isBookmarked = isBookmarked
    }

    // Backward-compatible decoding for new fields
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        authorId = try container.decode(UUID.self, forKey: .authorId)
        authorName = try container.decode(String.self, forKey: .authorName)
        authorAvatar = try container.decode(String.self, forKey: .authorAvatar)
        authorGender = try container.decode(Gender.self, forKey: .authorGender)
        board = try container.decode(String.self, forKey: .board)
        title = try container.decode(String.self, forKey: .title)
        content = try container.decode(String.self, forKey: .content)
        imageName = try container.decodeIfPresent(String.self, forKey: .imageName)
        timestamp = try container.decode(Date.self, forKey: .timestamp)
        likeCount = try container.decode(Int.self, forKey: .likeCount)
        dislikeCount = try container.decode(Int.self, forKey: .dislikeCount)
        commentCount = try container.decode(Int.self, forKey: .commentCount)
        bookmarkCount = try container.decodeIfPresent(Int.self, forKey: .bookmarkCount) ?? 0
        isLiked = try container.decode(Bool.self, forKey: .isLiked)
        isDisliked = try container.decode(Bool.self, forKey: .isDisliked)
        isBookmarked = try container.decode(Bool.self, forKey: .isBookmarked)
    }
}
