import SwiftUI

struct CommentRowView: View {
    @Environment(DataStore.self) private var store
    let comment: Comment
    var onReply: (() -> Void)? = nil

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            AvatarView(gender: comment.authorGender, size: 30)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("B\(comment.floor)")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Theme.brandBlue)

                    Text(comment.authorName)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Theme.textPrimary)

                    Spacer()

                    Text(comment.timestamp.timeAgoDisplay())
                        .font(.system(size: 11))
                        .foregroundStyle(Theme.textTertiary)
                }

                // Reply tag (Dcard 建樓風格)
                if let replyFloor = comment.replyToFloor {
                    Text("回覆 B\(replyFloor)")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Theme.brandBlue)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Theme.brandLightBlue)
                        .clipShape(Capsule())
                }

                Text(comment.content)
                    .font(.system(size: 15))
                    .foregroundStyle(Theme.textPrimary)
                    .lineSpacing(3)

                // Like & Reply buttons
                HStack(spacing: 16) {
                    Button {
                        withAnimation(.spring(response: 0.3)) {
                            store.toggleCommentLike(comment: comment)
                        }
                    } label: {
                        HStack(spacing: 3) {
                            Image(systemName: comment.isLiked ? "heart.fill" : "heart")
                                .font(.system(size: 12))
                            if comment.likeCount > 0 {
                                Text("\(comment.likeCount)")
                                    .font(.system(size: 12))
                            }
                        }
                        .foregroundStyle(comment.isLiked ? Theme.likeRed : Theme.textTertiary)
                    }

                    if let onReply = onReply {
                        Button {
                            onReply()
                        } label: {
                            HStack(spacing: 3) {
                                Image(systemName: "arrowshape.turn.up.left")
                                    .font(.system(size: 12))
                                Text("回覆")
                                    .font(.system(size: 12))
                            }
                            .foregroundStyle(Theme.textTertiary)
                        }
                    }
                }
                .padding(.top, 4)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }
}
