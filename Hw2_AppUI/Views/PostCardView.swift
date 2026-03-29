import SwiftUI

struct PostCardView: View {
    let post: Post

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Header: Avatar + Board tag + timestamp
            HStack(spacing: 8) {
                AvatarView(gender: post.authorGender, size: 28)

                Text(post.board)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Theme.brandBlue)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(
                        Capsule()
                            .fill(Theme.brandLightBlue)
                    )

                Text(post.authorName)
                    .font(.system(size: 12))
                    .foregroundStyle(Theme.textSecondary)

                Spacer()

                Text(post.timestamp.timeAgoDisplay())
                    .font(.system(size: 12))
                    .foregroundStyle(Theme.textTertiary)
            }

            // Title
            Text(post.title)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Theme.textPrimary)
                .lineLimit(2)

            // Content Preview
            Text(post.content)
                .font(.system(size: 14))
                .foregroundStyle(Theme.textSecondary)
                .lineLimit(3)
                .lineSpacing(2)

            // Bottom bar: like + comment + bookmark counts
            HStack(spacing: 16) {
                HStack(spacing: 4) {
                    Image(systemName: post.isLiked ? "heart.fill" : "heart")
                        .foregroundStyle(post.isLiked ? Theme.likeRed : Theme.textTertiary)
                        .font(.system(size: 14))
                    Text("\(post.likeCount)")
                        .font(.system(size: 13))
                        .foregroundStyle(Theme.textTertiary)
                }

                HStack(spacing: 4) {
                    Image(systemName: "bubble.left")
                        .font(.system(size: 14))
                        .foregroundStyle(Theme.textTertiary)
                    Text("\(post.commentCount)")
                        .font(.system(size: 13))
                        .foregroundStyle(Theme.textTertiary)
                }

                HStack(spacing: 4) {
                    Image(systemName: post.isBookmarked ? "bookmark.fill" : "bookmark")
                        .font(.system(size: 13))
                        .foregroundStyle(post.isBookmarked ? Theme.bookmarkYellow : Theme.textTertiary)
                    Text("\(post.bookmarkCount)")
                        .font(.system(size: 13))
                        .foregroundStyle(Theme.textTertiary)
                }

                Spacer()
            }
            .padding(.top, 2)
        }
        .padding(16)
        .background(Theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cardCornerRadius))
        .shadow(color: Theme.cardShadow, radius: 4, y: 2)
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
    }
}
