import SwiftUI

struct PostDetailView: View {
    @Environment(DataStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    let postId: UUID
    @State private var commentText = ""
    @State private var replyingToFloor: Int? = nil
    @FocusState private var isCommentFocused: Bool

    private var post: Post? {
        store.posts.first(where: { $0.id == postId })
    }

    private var comments: [Comment] {
        store.commentsForPost(postId)
    }

    var body: some View {
        if let post = post {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        // Article Header
                        articleHeader(post)

                        // Article Content
                        articleContent(post)

                        // Action Bar
                        actionBar(post)

                        // Divider
                        Rectangle()
                            .fill(Theme.separator)
                            .frame(height: 8)

                        // Comments Section
                        commentsSection
                    }
                }

                // Comment Input Bar (outside ScrollView, fixed at bottom)
                commentInputBar
            }
            .background(Theme.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(post.board)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Theme.textPrimary)
                }
            }
        }
    }

    // MARK: - Article Header
    private func articleHeader(_ post: Post) -> some View {
        HStack(spacing: 12) {
            AvatarView(gender: post.authorGender, size: 40)

            VStack(alignment: .leading, spacing: 2) {
                Text(post.authorName)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(Theme.textPrimary)

                HStack(spacing: 4) {
                    Text(post.board)
                        .font(.system(size: 12))
                        .foregroundStyle(Theme.brandBlue)
                    Text("·")
                        .foregroundStyle(Theme.textTertiary)
                    Text(post.timestamp.timeAgoDisplay())
                        .font(.system(size: 12))
                        .foregroundStyle(Theme.textTertiary)
                }
            }

            Spacer()

            Menu {
                Button(role: .destructive) {
                    // Report placeholder
                } label: {
                    Label("檢舉", systemImage: "exclamationmark.triangle")
                }
            } label: {
                Image(systemName: "ellipsis")
                    .foregroundStyle(Theme.textTertiary)
                    .padding(8)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.cardBackground)
    }

    // MARK: - Article Content
    private func articleContent(_ post: Post) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(post.title)
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(Theme.textPrimary)

            Text(post.content)
                .font(.system(size: 16))
                .foregroundStyle(Theme.textPrimary)
                .lineSpacing(6)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.cardBackground)
    }

    // MARK: - Action Bar
    private func actionBar(_ post: Post) -> some View {
        HStack(spacing: 0) {
            // Like
            actionButton(
                icon: post.isLiked ? "heart.fill" : "heart",
                label: "\(post.likeCount)",
                color: post.isLiked ? Theme.likeRed : Theme.textSecondary
            ) {
                withAnimation(.spring(response: 0.3)) {
                    store.toggleLike(post: post)
                }
            }

            // Dislike
            actionButton(
                icon: post.isDisliked ? "hand.thumbsdown.fill" : "hand.thumbsdown",
                label: post.dislikeCount > 0 ? "\(post.dislikeCount)" : "",
                color: post.isDisliked ? Theme.brandBlue : Theme.textSecondary
            ) {
                withAnimation(.spring(response: 0.3)) {
                    store.toggleDislike(post: post)
                }
            }

            // Bookmark with count
            actionButton(
                icon: post.isBookmarked ? "bookmark.fill" : "bookmark",
                label: "\(post.bookmarkCount)",
                color: post.isBookmarked ? Theme.bookmarkYellow : Theme.textSecondary
            ) {
                withAnimation(.spring(response: 0.3)) {
                    store.toggleBookmark(post: post)
                }
            }

            // Share
            actionButton(
                icon: "square.and.arrow.up",
                label: "分享",
                color: Theme.textSecondary
            ) {
                // share placeholder
            }
        }
        .padding(.vertical, 4)
        .background(Theme.cardBackground)
    }

    private func actionButton(icon: String, label: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                if !label.isEmpty {
                    Text(label)
                        .font(.system(size: 13))
                }
            }
            .foregroundStyle(color)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
        }
    }

    // MARK: - Comments Section
    private var commentsSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("留言 \(comments.count)")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Theme.textPrimary)
                .padding(16)

            if comments.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "bubble.left.and.bubble.right")
                        .font(.system(size: 32))
                        .foregroundStyle(Theme.textTertiary)
                    Text("還沒有留言，來當第一個吧！")
                        .font(.system(size: 14))
                        .foregroundStyle(Theme.textTertiary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                ForEach(comments) { comment in
                    CommentRowView(comment: comment) {
                        replyingToFloor = comment.floor
                        isCommentFocused = true
                    }
                    if comment.id != comments.last?.id {
                        Divider()
                            .padding(.leading, 56)
                    }
                }
            }
        }
        .background(Theme.cardBackground)
    }

    // MARK: - Comment Input Bar
    private var commentInputBar: some View {
        VStack(spacing: 0) {
            Divider()

            // Reply indicator
            if let replyFloor = replyingToFloor {
                HStack {
                    Text("回覆 B\(replyFloor)")
                        .font(.system(size: 13))
                        .foregroundStyle(Theme.brandBlue)

                    Spacer()

                    Button {
                        replyingToFloor = nil
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 16))
                            .foregroundStyle(Theme.textTertiary)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Theme.brandLightBlue.opacity(0.5))
            }

            HStack(spacing: 10) {
                AvatarView(gender: store.currentUser.gender, size: 30)

                TextField(replyingToFloor != nil ? "回覆 B\(replyingToFloor!)..." : "留言...", text: $commentText)
                    .font(.system(size: 15))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Theme.chipBackground)
                    .clipShape(Capsule())
                    .focused($isCommentFocused)

                if !commentText.isEmpty {
                    Button {
                        if let replyFloor = replyingToFloor {
                            store.addReply(postId: postId, replyToFloor: replyFloor, content: commentText)
                        } else {
                            store.addComment(postId: postId, content: commentText)
                        }
                        commentText = ""
                        replyingToFloor = nil
                        isCommentFocused = false
                    } label: {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 30))
                            .foregroundStyle(Theme.brandBlue)
                    }
                    .transition(.scale)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
        .background(.ultraThinMaterial)
    }
}
