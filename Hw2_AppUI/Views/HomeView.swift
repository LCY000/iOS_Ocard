import SwiftUI

struct HomeView: View {
    @Environment(DataStore.self) private var store
    @State private var selectedBoard = "全部"
    @State private var showSearch = false
    @State private var showCreatePost = false
    @State private var showFAB = true
    @State private var previousScrollOffset: CGFloat = 0

    private let boards = ["全部", "熱門", "閒聊", "有趣", "感情", "美食", "3C", "時事", "工作", "課業"]

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                Theme.background.ignoresSafeArea()

                ScrollView {
                    LazyVStack(spacing: 0) {
                        // Board filter chips
                        boardChips
                            .padding(.top, 4)

                        // Posts
                        ForEach(filteredPosts) { post in
                            NavigationLink(destination: PostDetailView(postId: post.id)) {
                                PostCardView(post: post)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .background(
                        GeometryReader { geo in
                            Color.clear
                                .onChange(of: geo.frame(in: .global).minY) { oldValue, newValue in
                                    let delta = newValue - previousScrollOffset
                                    // Only react to meaningful scroll distances
                                    if abs(delta) > 5 {
                                        if delta < -10 {
                                            // Scrolling DOWN → hide FAB
                                            if showFAB {
                                                withAnimation(.easeOut(duration: 0.2)) {
                                                    showFAB = false
                                                }
                                            }
                                        } else if delta > 10 {
                                            // Scrolling UP → show FAB
                                            if !showFAB {
                                                withAnimation(.easeIn(duration: 0.2)) {
                                                    showFAB = true
                                                }
                                            }
                                        }
                                        previousScrollOffset = newValue
                                    }
                                }
                        }
                    )
                }
                .refreshable {
                    try? await Task.sleep(for: .seconds(0.8))
                }

                // Floating Action Button
                Button {
                    showCreatePost = true
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 56, height: 56)
                        .background(
                            Circle()
                                .fill(Theme.brandBlue)
                                .shadow(color: Theme.brandBlue.opacity(0.4), radius: 8, y: 4)
                        )
                }
                .padding(.trailing, 20)
                .padding(.bottom, 24)
                .scaleEffect(showFAB ? 1 : 0.01)
                .opacity(showFAB ? 1 : 0)
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: showFAB)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Ocard")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(Theme.brandBlue)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showSearch = true
                    } label: {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(Theme.textPrimary)
                    }
                }
            }
            .sheet(isPresented: $showSearch) {
                SearchView()
            }
            .sheet(isPresented: $showCreatePost) {
                CreatePostView()
            }
        }
    }

    private var filteredPosts: [Post] {
        store.postsForBoard(selectedBoard)
    }

    private var boardChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(boards, id: \.self) { board in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedBoard = board
                        }
                    } label: {
                        Text(board)
                            .font(.system(size: 14, weight: selectedBoard == board ? .semibold : .regular))
                            .foregroundStyle(selectedBoard == board ? .white : Theme.textSecondary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(selectedBoard == board ? Theme.brandBlue : Theme.chipBackground)
                            )
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
    }
}

#Preview {
    HomeView()
        .environment(DataStore.shared)
}
