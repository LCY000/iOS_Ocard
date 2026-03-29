import SwiftUI

struct CreatePostView: View {
    @Environment(DataStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @State private var selectedBoard = "閒聊"
    @State private var title = ""
    @State private var content = ""
    @State private var showBoardPicker = false

    private let boards = ["閒聊", "有趣", "感情", "美食", "穿搭", "彩妝", "時事", "工作", "3C", "追劇", "運動", "旅遊", "音樂", "課業"]

    private var canPost: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty &&
        !content.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 0) {
                        // Board Selector
                        Button {
                            showBoardPicker = true
                        } label: {
                            HStack {
                                Image(systemName: "square.grid.2x2")
                                    .foregroundStyle(Theme.brandBlue)
                                Text(selectedBoard)
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundStyle(Theme.textPrimary)
                                Image(systemName: "chevron.down")
                                    .font(.system(size: 12))
                                    .foregroundStyle(Theme.textTertiary)
                                Spacer()
                            }
                            .padding(16)
                            .background(Theme.cardBackground)
                        }

                        Divider()

                        // Title Input
                        TextField("標題", text: $title)
                            .font(.system(size: 20, weight: .bold))
                            .padding(16)
                            .background(Theme.cardBackground)

                        Divider()

                        // Content Input
                        ZStack(alignment: .topLeading) {
                            if content.isEmpty {
                                Text("分享你的想法...")
                                    .foregroundStyle(Theme.textTertiary)
                                    .padding(.top, 8)
                                    .padding(.leading, 4)
                            }

                            TextEditor(text: $content)
                                .font(.system(size: 16))
                                .frame(minHeight: 300)
                                .scrollContentBackground(.hidden)
                                .background(.clear)
                        }
                        .padding(16)
                        .background(Theme.cardBackground)

                        // Toolbar icons
                        HStack(spacing: 20) {
                            toolButton(icon: "photo", label: "照片")
                            toolButton(icon: "camera", label: "相機")
                            toolButton(icon: "face.smiling", label: "表情")
                            toolButton(icon: "mappin", label: "位置")
                            Spacer()
                        }
                        .padding(16)
                        .background(Theme.cardBackground)
                    }
                }
            }
            .navigationTitle("發文")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                    .foregroundStyle(Theme.textSecondary)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("發佈") {
                        store.addPost(board: selectedBoard, title: title, content: content)
                        dismiss()
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(canPost ? Theme.brandBlue : Theme.textTertiary)
                    .disabled(!canPost)
                }
            }
            .sheet(isPresented: $showBoardPicker) {
                boardPickerSheet
            }
        }
    }

    private func toolButton(icon: String, label: String) -> some View {
        Button { } label: {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                Text(label)
                    .font(.system(size: 11))
            }
            .foregroundStyle(Theme.textSecondary)
        }
    }

    private var boardPickerSheet: some View {
        NavigationStack {
            List(boards, id: \.self) { board in
                Button {
                    selectedBoard = board
                    showBoardPicker = false
                } label: {
                    HStack {
                        Text(board)
                            .foregroundStyle(Theme.textPrimary)
                        Spacer()
                        if selectedBoard == board {
                            Image(systemName: "checkmark")
                                .foregroundStyle(Theme.brandBlue)
                        }
                    }
                }
            }
            .navigationTitle("選擇看板")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("完成") {
                        showBoardPicker = false
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }
}
