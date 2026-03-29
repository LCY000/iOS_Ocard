import SwiftUI

struct ForumListView: View {
    @Environment(DataStore.self) private var store
    @State private var searchText = ""

    private var filteredForums: [Forum] {
        if searchText.isEmpty {
            return store.forums
        }
        return store.forums.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    private var subscribedForums: [Forum] {
        filteredForums.filter { $0.isSubscribed }
    }

    private var otherForums: [Forum] {
        filteredForums.filter { !$0.isSubscribed }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 12) {
                        // Search bar
                        HStack(spacing: 8) {
                            Image(systemName: "magnifyingglass")
                                .foregroundStyle(Theme.textTertiary)
                            TextField("搜尋看板", text: $searchText)
                                .font(.system(size: 15))
                        }
                        .padding(10)
                        .background(Theme.chipBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .padding(.horizontal, 16)
                        .padding(.top, 8)

                        // Subscribed Forums
                        if !subscribedForums.isEmpty {
                            sectionHeader("已追蹤的看板")
                            ForEach(subscribedForums) { forum in
                                NavigationLink(destination: ForumDetailView(forum: forum)) {
                                    forumRow(forum)
                                }
                                .buttonStyle(.plain)
                            }
                        }

                        // Other Forums
                        if !otherForums.isEmpty {
                            sectionHeader("探索更多看板")
                            ForEach(otherForums) { forum in
                                NavigationLink(destination: ForumDetailView(forum: forum)) {
                                    forumRow(forum)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(.bottom, 80)
                }
            }
            .navigationTitle("看板")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func sectionHeader(_ title: String) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Theme.textSecondary)
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }

    private func forumRow(_ forum: Forum) -> some View {
        HStack(spacing: 12) {
            Image(systemName: forum.icon)
                .font(.system(size: 22))
                .foregroundStyle(Theme.brandBlue)
                .frame(width: 44, height: 44)
                .background(Theme.brandLightBlue)
                .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 2) {
                Text(forum.name)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(Theme.textPrimary)
                Text("\(forum.subscriberCount.formatted()) 人追蹤")
                    .font(.system(size: 12))
                    .foregroundStyle(Theme.textTertiary)
            }

            Spacer()

            Button {
                withAnimation(.spring(response: 0.3)) {
                    store.toggleSubscribe(forum: forum)
                }
            } label: {
                Text(forum.isSubscribed ? "已追蹤" : "追蹤")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(forum.isSubscribed ? Theme.textSecondary : .white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(forum.isSubscribed ? Theme.chipBackground : Theme.brandBlue)
                    )
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cardCornerRadius))
        .padding(.horizontal, 12)
    }
}

// MARK: - Forum Detail View
struct ForumDetailView: View {
    @Environment(DataStore.self) private var store
    let forum: Forum

    private var forumPosts: [Post] {
        store.postsForBoard(forum.name)
    }

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    // Forum Header
                    VStack(spacing: 12) {
                        Image(systemName: forum.icon)
                            .font(.system(size: 40))
                            .foregroundStyle(.white)
                            .frame(width: 72, height: 72)
                            .background(Theme.brandBlue)
                            .clipShape(RoundedRectangle(cornerRadius: 20))

                        Text(forum.name)
                            .font(.system(size: 22, weight: .bold))
                            .foregroundStyle(Theme.textPrimary)

                        Text(forum.description)
                            .font(.system(size: 14))
                            .foregroundStyle(Theme.textSecondary)

                        Text("\(forum.subscriberCount.formatted()) 人追蹤")
                            .font(.system(size: 13))
                            .foregroundStyle(Theme.textTertiary)

                        Button {
                            store.toggleSubscribe(forum: forum)
                        } label: {
                            Text(forum.isSubscribed ? "已追蹤" : "追蹤")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(forum.isSubscribed ? Theme.brandBlue : .white)
                                .frame(width: 120)
                                .padding(.vertical, 10)
                                .background(
                                    Capsule()
                                        .fill(forum.isSubscribed ? Theme.brandLightBlue : Theme.brandBlue)
                                )
                        }
                    }
                    .padding(.vertical, 20)
                    .frame(maxWidth: .infinity)
                    .background(Theme.cardBackground)

                    Rectangle()
                        .fill(Theme.separator)
                        .frame(height: 8)

                    // Posts in this forum
                    if forumPosts.isEmpty {
                        VStack(spacing: 8) {
                            Image(systemName: "doc.text")
                                .font(.system(size: 32))
                                .foregroundStyle(Theme.textTertiary)
                            Text("這個看板還沒有文章")
                                .font(.system(size: 14))
                                .foregroundStyle(Theme.textTertiary)
                        }
                        .padding(.vertical, 60)
                    } else {
                        ForEach(forumPosts) { post in
                            NavigationLink(destination: PostDetailView(postId: post.id)) {
                                PostCardView(post: post)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(.bottom, 80)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}
