import SwiftUI

struct NotificationView: View {
    @Environment(DataStore.self) private var store

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()

                if store.notifications.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "bell.slash")
                            .font(.system(size: 40))
                            .foregroundStyle(Theme.textTertiary)
                        Text("目前沒有通知")
                            .font(.system(size: 16))
                            .foregroundStyle(Theme.textSecondary)
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 1) {
                            ForEach(store.notifications) { notification in
                                notificationRow(notification)
                            }
                        }
                        .padding(.bottom, 80)
                    }
                }
            }
            .navigationTitle("通知")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if store.unreadNotificationCount > 0 {
                        Button {
                            store.markAllAsRead()
                        } label: {
                            Text("全部已讀")
                                .font(.system(size: 14))
                                .foregroundStyle(Theme.brandBlue)
                        }
                    }
                }
            }
        }
    }

    private func notificationRow(_ notification: AppNotification) -> some View {
        Button {
            store.markAsRead(notification: notification)
        } label: {
            HStack(spacing: 12) {
                // Icon
                ZStack {
                    Circle()
                        .fill(notificationColor(notification.type).opacity(0.15))
                        .frame(width: 44, height: 44)

                    Image(systemName: notification.type.icon)
                        .font(.system(size: 18))
                        .foregroundStyle(notificationColor(notification.type))
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(notification.title)
                        .font(.system(size: 15, weight: notification.isRead ? .regular : .semibold))
                        .foregroundStyle(Theme.textPrimary)

                    Text(notification.message)
                        .font(.system(size: 13))
                        .foregroundStyle(Theme.textSecondary)
                        .lineLimit(2)

                    Text(notification.timestamp.timeAgoDisplay())
                        .font(.system(size: 11))
                        .foregroundStyle(Theme.textTertiary)
                }

                Spacer()

                if !notification.isRead {
                    Circle()
                        .fill(Theme.brandBlue)
                        .frame(width: 8, height: 8)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(notification.isRead ? Theme.cardBackground : Theme.brandLightBlue.opacity(0.3))
        }
    }

    private func notificationColor(_ type: AppNotification.NotificationType) -> Color {
        switch type {
        case .like: return Theme.notifLike
        case .comment: return Theme.notifComment
        case .follow: return Theme.notifFollow
        case .system: return Theme.notifSystem
        }
    }
}
