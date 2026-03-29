import SwiftUI

struct ProfileView: View {
    @Environment(DataStore.self) private var store
    @State private var selectedTab = 0
    @State private var showEditProfile = false

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 0) {
                        // Profile Header
                        profileHeader

                        // Stats Bar
                        statsBar

                        // Segmented Tabs
                        segmentedTabs

                        // Tab Content
                        tabContent
                    }
                    .padding(.bottom, 80)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showEditProfile) {
                EditProfileView()
            }
        }
    }

    // MARK: - Profile Header
    private var profileHeader: some View {
        VStack(spacing: 12) {
            // Avatar
            AvatarView(gender: store.currentUser.gender, size: 80)

            Text(store.currentUser.nickname)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(Theme.textPrimary)

            HStack(spacing: 4) {
                Image(systemName: "graduationcap.fill")
                    .font(.system(size: 12))
                    .foregroundStyle(Theme.brandBlue)
                Text("\(store.currentUser.school) · \(store.currentUser.department)")
                    .font(.system(size: 13))
                    .foregroundStyle(Theme.textSecondary)
            }

            if !store.currentUser.bio.isEmpty {
                Text(store.currentUser.bio)
                    .font(.system(size: 14))
                    .foregroundStyle(Theme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }

            Button {
                showEditProfile = true
            } label: {
                Text("編輯個人資料")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Theme.brandBlue)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .stroke(Theme.brandBlue, lineWidth: 1.5)
                    )
            }
        }
        .padding(.top, 30)
        .padding(.bottom, 16)
        .frame(maxWidth: .infinity)
        .background(Theme.cardBackground)
    }

    // MARK: - Stats Bar
    private var statsBar: some View {
        HStack(spacing: 0) {
            statItem(value: store.currentUser.postCount, label: "文章")
            Divider().frame(height: 30)
            statItem(value: store.currentUser.followerCount, label: "粉絲")
            Divider().frame(height: 30)
            statItem(value: store.currentUser.followingCount, label: "追蹤中")
        }
        .padding(.vertical, 12)
        .background(Theme.cardBackground)
        .padding(.top, 1)
    }

    private func statItem(value: Int, label: String) -> some View {
        VStack(spacing: 2) {
            Text("\(value)")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(Theme.textPrimary)
            Text(label)
                .font(.system(size: 12))
                .foregroundStyle(Theme.textTertiary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Segmented Tabs
    private var segmentedTabs: some View {
        HStack(spacing: 0) {
            profileTabButton(title: "我的文章", tag: 0)
            profileTabButton(title: "收藏", tag: 1)
            profileTabButton(title: "留言紀錄", tag: 2)
        }
        .padding(.vertical, 4)
        .background(Theme.cardBackground)
        .padding(.top, 8)
    }

    private func profileTabButton(title: String, tag: Int) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedTab = tag
            }
        } label: {
            VStack(spacing: 10) {
                Text(title)
                    .font(.system(size: 15, weight: selectedTab == tag ? .semibold : .regular))
                    .foregroundStyle(selectedTab == tag ? Theme.brandBlue : Theme.textSecondary)
                    .padding(.top, 6)

                Rectangle()
                    .fill(selectedTab == tag ? Theme.brandBlue : Color.clear)
                    .frame(height: 2)
            }
            .frame(maxWidth: .infinity)
        }
    }

    // MARK: - Tab Content
    @ViewBuilder
    private var tabContent: some View {
        switch selectedTab {
        case 0:
            postsList(store.userPosts(), emptyMessage: "還沒有發表任何文章", emptyIcon: "doc.text")
        case 1:
            postsList(store.bookmarkedPosts(), emptyMessage: "還沒有收藏任何文章", emptyIcon: "bookmark")
        case 2:
            commentsList
        default:
            EmptyView()
        }
    }

    private func postsList(_ posts: [Post], emptyMessage: String, emptyIcon: String) -> some View {
        Group {
            if posts.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: emptyIcon)
                        .font(.system(size: 32))
                        .foregroundStyle(Theme.textTertiary)
                    Text(emptyMessage)
                        .font(.system(size: 14))
                        .foregroundStyle(Theme.textTertiary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 60)
            } else {
                ForEach(posts) { post in
                    NavigationLink(destination: PostDetailView(postId: post.id)) {
                        PostCardView(post: post)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var commentsList: some View {
        Group {
            let userComments = store.userComments()
            if userComments.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "bubble.left")
                        .font(.system(size: 32))
                        .foregroundStyle(Theme.textTertiary)
                    Text("還沒有留過言")
                        .font(.system(size: 14))
                        .foregroundStyle(Theme.textTertiary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 60)
            } else {
                ForEach(userComments) { comment in
                    VStack(alignment: .leading, spacing: 6) {
                        // Find the post title
                        if let post = store.posts.first(where: { $0.id == comment.postId }) {
                            NavigationLink(destination: PostDetailView(postId: post.id)) {
                                HStack {
                                    Text(post.title)
                                        .font(.system(size: 13))
                                        .foregroundStyle(Theme.brandBlue)
                                        .lineLimit(1)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 10))
                                        .foregroundStyle(Theme.textTertiary)
                                }
                            }
                        }

                        Text(comment.content)
                            .font(.system(size: 15))
                            .foregroundStyle(Theme.textPrimary)

                        Text(comment.timestamp.timeAgoDisplay())
                            .font(.system(size: 11))
                            .foregroundStyle(Theme.textTertiary)
                    }
                    .padding(16)
                    .background(Theme.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: Theme.cardCornerRadius))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 3)
                }
            }
        }
    }
}

#Preview {
    ProfileView()
        .environment(DataStore.shared)
}
