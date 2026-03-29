import SwiftUI

struct Theme {
    // MARK: - Brand Colors
    static let brandBlue = Color(hex: "006AA6")
    static let brandLightBlue = Color(hex: "E8F4FD")
    static let brandDarkBlue = Color(hex: "004D7A")

    // MARK: - Background
    static let background = Color(hex: "F5F5F5")
    static let cardBackground = Color.white
    static let navBackground = Color.white

    // MARK: - Text
    static let textPrimary = Color(hex: "1A1A1A")
    static let textSecondary = Color(hex: "8E8E93")
    static let textTertiary = Color(hex: "AEAEB2")

    // MARK: - Semantic
    static let likeRed = Color(hex: "FF3B30")
    static let dislikeGray = Color(hex: "8E8E93")
    static let bookmarkYellow = Color(hex: "FFCC00")
    static let separator = Color(hex: "E5E5EA")
    static let chipBackground = Color(hex: "F2F2F7")
    static let chipSelected = Color(hex: "006AA6")

    // MARK: - Notification Colors
    static let notifLike = Color(hex: "FF3B30")
    static let notifComment = Color(hex: "007AFF")
    static let notifFollow = Color(hex: "34C759")
    static let notifSystem = Color(hex: "FF9500")

    // MARK: - Gender Avatar Colors (Dcard Style)
    static let maleBlue = Color(hex: "5B9BD5")
    static let maleLightBlue = Color(hex: "D6E8F7")
    static let femalePink = Color(hex: "E8789A")
    static let femaleLightPink = Color(hex: "FCE4EC")

    static func genderColor(_ gender: Gender) -> Color {
        gender == .male ? maleBlue : femalePink
    }

    static func genderLightColor(_ gender: Gender) -> Color {
        gender == .male ? maleLightBlue : femaleLightPink
    }

    // MARK: - Gradients
    static let headerGradient = LinearGradient(
        colors: [Color(hex: "006AA6"), Color(hex: "0088CC")],
        startPoint: .leading,
        endPoint: .trailing
    )

    // MARK: - Card Style
    static let cardCornerRadius: CGFloat = 12
    static let cardShadow: Color = Color.black.opacity(0.06)
}

// MARK: - Dcard-Style Avatar View
struct AvatarView: View {
    let gender: Gender
    var size: CGFloat = 36

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: gender == .male
                            ? [Color(hex: "5B9BD5"), Color(hex: "4A8BC2")]
                            : [Color(hex: "E8789A"), Color(hex: "D5627F")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: size, height: size)

            Image(systemName: "person.fill")
                .font(.system(size: size * 0.45, weight: .medium))
                .foregroundStyle(.white)
        }
    }
}

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = ((int >> 24) & 0xFF, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Date Formatting
extension Date {
    func timeAgoDisplay() -> String {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.minute, .hour, .day, .weekOfYear], from: self, to: now)

        if let weeks = components.weekOfYear, weeks > 0 {
            let formatter = DateFormatter()
            formatter.dateFormat = "MM/dd"
            return formatter.string(from: self)
        }
        if let days = components.day, days > 0 {
            return "\(days) 天前"
        }
        if let hours = components.hour, hours > 0 {
            return "\(hours) 小時前"
        }
        if let minutes = components.minute, minutes > 0 {
            return "\(minutes) 分鐘前"
        }
        return "剛剛"
    }
}
