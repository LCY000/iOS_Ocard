import Foundation

enum Gender: String, Codable, CaseIterable {
    case male = "male"
    case female = "female"

    var displayName: String {
        switch self {
        case .male: return "男"
        case .female: return "女"
        }
    }
}

struct UserProfile: Identifiable, Codable, Equatable {
    var id: UUID
    var nickname: String
    var school: String
    var department: String
    var bio: String
    var avatarName: String
    var gender: Gender
    var postCount: Int
    var followerCount: Int
    var followingCount: Int

    init(
        id: UUID = UUID(),
        nickname: String = "Ocard 使用者",
        school: String = "台灣科技大學",
        department: String = "資訊工程系",
        bio: String = "Hello! 歡迎來到我的 Ocard ✨",
        avatarName: String = "person.circle.fill",
        gender: Gender = .male,
        postCount: Int = 0,
        followerCount: Int = 0,
        followingCount: Int = 0
    ) {
        self.id = id
        self.nickname = nickname
        self.school = school
        self.department = department
        self.bio = bio
        self.avatarName = avatarName
        self.gender = gender
        self.postCount = postCount
        self.followerCount = followerCount
        self.followingCount = followingCount
    }
}
