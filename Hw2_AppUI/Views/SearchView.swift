import SwiftUI

struct SearchView: View {
    @Environment(DataStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @FocusState private var isSearchFocused: Bool

    private let trendingTopics = ["AI 發展", "MacBook Pro", "拉麵推薦", "韓劇推薦", "健身", "京都旅遊", "春天穿搭", "防曬"]

    private var searchResults: [Post] {
        store.searchPosts(query: searchText)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        if searchText.isEmpty {
                            // Trending
                            VStack(alignment: .leading, spacing: 12) {
                                Text("🔥 熱門搜尋")
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundStyle(Theme.textPrimary)
                                    .padding(.horizontal, 16)

                                FlowLayout(spacing: 8) {
                                    ForEach(trendingTopics, id: \.self) { topic in
                                        Button {
                                            searchText = topic
                                        } label: {
                                            Text(topic)
                                                .font(.system(size: 14))
                                                .foregroundStyle(Theme.textPrimary)
                                                .padding(.horizontal, 14)
                                                .padding(.vertical, 8)
                                                .background(Theme.chipBackground)
                                                .clipShape(Capsule())
                                        }
                                    }
                                }
                                .padding(.horizontal, 16)
                            }
                            .padding(.top, 8)

                            // Recent Posts
                            VStack(alignment: .leading, spacing: 8) {
                                Text("📰 最新文章")
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundStyle(Theme.textPrimary)
                                    .padding(.horizontal, 16)

                                ForEach(Array(store.posts.prefix(5))) { post in
                                    NavigationLink(destination: PostDetailView(postId: post.id)) {
                                        searchResultRow(post)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.top, 8)
                        } else {
                            // Search Results
                            if searchResults.isEmpty {
                                VStack(spacing: 12) {
                                    Image(systemName: "magnifyingglass")
                                        .font(.system(size: 36))
                                        .foregroundStyle(Theme.textTertiary)
                                    Text("找不到相關文章")
                                        .font(.system(size: 16))
                                        .foregroundStyle(Theme.textSecondary)
                                    Text("試試其他關鍵字")
                                        .font(.system(size: 14))
                                        .foregroundStyle(Theme.textTertiary)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.top, 60)
                            } else {
                                Text("搜尋結果 (\(searchResults.count))")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundStyle(Theme.textSecondary)
                                    .padding(.horizontal, 16)
                                    .padding(.top, 8)

                                ForEach(searchResults) { post in
                                    NavigationLink(destination: PostDetailView(postId: post.id)) {
                                        PostCardView(post: post)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("搜尋")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "搜尋文章")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("關閉") {
                        dismiss()
                    }
                    .foregroundStyle(Theme.brandBlue)
                }
            }
        }
    }

    private func searchResultRow(_ post: Post) -> some View {
        HStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 4) {
                Text(post.title)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(Theme.textPrimary)
                    .lineLimit(1)

                Text(post.content)
                    .font(.system(size: 13))
                    .foregroundStyle(Theme.textSecondary)
                    .lineLimit(1)
            }

            Spacer()

            Text(post.board)
                .font(.system(size: 11))
                .foregroundStyle(Theme.brandBlue)
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(Theme.brandLightBlue)
                .clipShape(Capsule())
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
}

// MARK: - Flow Layout for Trending Tags
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.width ?? 0, subviews: subviews, spacing: spacing)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, subview) in subviews.enumerated() {
            let point = result.positions[index]
            subview.place(at: CGPoint(x: point.x + bounds.minX, y: point.y + bounds.minY), proposal: .unspecified)
        }
    }

    struct FlowResult {
        var positions: [CGPoint] = []
        var size: CGSize = .zero

        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var rowHeight: CGFloat = 0

            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                if x + size.width > maxWidth, x > 0 {
                    x = 0
                    y += rowHeight + spacing
                    rowHeight = 0
                }
                positions.append(CGPoint(x: x, y: y))
                rowHeight = max(rowHeight, size.height)
                x += size.width + spacing
                self.size.width = max(self.size.width, x)
            }
            self.size.height = y + rowHeight
        }
    }
}
