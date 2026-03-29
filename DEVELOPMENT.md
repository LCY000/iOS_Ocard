# DEVELOPMENT — Ocard 開發技術文件

> 本文件提供專案的完整技術細節，供開發者或 AI 快速理解與接手。

---

## 目錄

- [專案概覽](#專案概覽)
- [架構圖](#架構圖)
- [目錄結構與檔案說明](#目錄結構與檔案說明)
- [資料流與狀態管理](#資料流與狀態管理)
- [Model 詳細規格](#model-詳細規格)
- [View 詳細說明](#view-詳細說明)
- [共用模組](#共用模組)
- [Mock 資料系統](#mock-資料系統)
- [開發指南](#開發指南)
- [程式碼慣例](#程式碼慣例)

---

## 專案概覽

| 項目     | 內容                                             |
| -------- | ------------------------------------------------ |
| 專案名稱 | Hw2_AppUI（Ocard）                               |
| 平台     | iOS                                              |
| 框架     | SwiftUI                                          |
| 最低版本 | iOS 17+（使用 `@Observable`、`Layout` protocol） |
| 資料儲存 | UserDefaults（JSON 編碼）                        |
| 架構模式 | 類 MVVM — 單一 `DataStore` 管理所有狀態          |

---

## 架構圖

```
┌─────────────────────────────────────────────┐
│                   App Entry                 │
│              Hw2_AppUIApp.swift              │
│                     │                       │
│              ContentView.swift              │
│          (TabView — 4 Tabs 系統樣式)        │
├───────────┬───────────┬──────────┬──────────┤
│   首頁    │   看板     │   通知   │   我的   │
│ HomeView  │ForumList  │  Notif   │ Profile  │
│  + FAB    │  View     │  View    │  View    │
├───────────┴───────────┴──────────┴──────────┤
│                 DataStore                   │
│         (Singleton, @Observable)            │
│  ┌────────┬────────┬────────┬─────────────┐ │
│  │  User  │ Post[] │Comment │   Forum[]   │ │
│  │Profile │        │  []    │             │ │
│  └────────┴────────┴────────┴─────────────┘ │
│              UserDefaults                   │
└─────────────────────────────────────────────┘
```

---

## 目錄結構與檔案說明

```
Hw2_AppUI/
├── Hw2_AppUI.xcodeproj/       # Xcode 專案檔
└── Hw2_AppUI/                 # 主程式碼
    ├── Hw2_AppUIApp.swift     # App 進入點
    ├── ContentView.swift      # 主畫面 (TabView — 4 Tab 系統樣式)
    ├── DataStore.swift        # 資料管理中心 (單例模式)
    ├── Theme.swift            # 主題色彩/樣式 + AvatarView + 工具擴展
    │
    ├── Models/                # 資料模型
    │   ├── User.swift         # Gender enum + UserProfile struct
    │   ├── Post.swift         # 文章模型
    │   ├── Comment.swift      # 留言模型
    │   ├── Forum.swift        # 看板模型
    │   └── AppNotification.swift  # 通知模型
    │
    ├── Views/                 # 畫面元件
    │   ├── HomeView.swift         # 首頁（文章列表 + 看板篩選 + FAB 浮動發文按鈕）
    │   ├── ForumListView.swift    # 看板列表 + ForumDetailView
    │   ├── PostCardView.swift     # 文章卡片元件（列表用）
    │   ├── PostDetailView.swift   # 文章詳情頁（含留言區）
    │   ├── CreatePostView.swift   # 發文頁面
    │   ├── CommentRowView.swift   # 單則留言元件
    │   ├── SearchView.swift       # 搜尋頁面 + FlowLayout
    │   ├── NotificationView.swift # 通知頁面
    │   ├── ProfileView.swift      # 個人頁面（文章/收藏/留言）
    │   └── EditProfileView.swift  # 編輯個人資料
    │
    └── Assets.xcassets/       # 圖片資源
```

### 進入點 & 主頁面

| 檔案                   | 說明                                                                                                                                |
| ---------------------- | ----------------------------------------------------------------------------------------------------------------------------------- |
| **Hw2_AppUIApp.swift** | `@main` 進入點，將 `ContentView` 設為根畫面                                                                                         |
| **ContentView.swift**  | 包含 4 頁的 `TabView`（首頁/看板/通知/我的），使用系統 `.tabItem` 樣式。透過 `.environment(store)` 將 `DataStore` 注入到所有子 View |

---

## 資料流與狀態管理

```
View 層（SwiftUI）
    │
    ├── @Environment(DataStore.self)  ← 透過 Environment 讀取
    │
    ▼
DataStore（@Observable Singleton）
    │
    ├── currentUser: UserProfile      ← 當前使用者
    ├── posts: [Post]                 ← 所有文章
    ├── comments: [Comment]           ← 所有留言
    ├── forums: [Forum]               ← 所有看板
    ├── notifications: [AppNotification]← 通知
    │
    ├── 業務方法：toggleLike / addPost / addComment / addReply / ...
    │
    ▼
UserDefaults（JSON 持久化）
```

### 關鍵設計決策

1. **單一資料源（Single Source of Truth）**：`DataStore.shared` 是 Singleton，所有 View 共享同一份資料
2. **Swift Observation**：使用 `@Observable` 巨集（iOS 17+），搭配 `@Environment` 注入，自動偵測變更並更新 UI
3. **即時持久化**：每次資料操作後立即呼叫 `saveData()` 寫入 UserDefaults
4. **向下相容 Codable**：`Post` 使用自訂 `init(from decoder:)` 處理新增欄位（如 `bookmarkCount`），舊 JSON 解碼時自動補預設值，避免 Preview/舊資料解碼失敗

---

## Model 詳細規格

### Gender (enum)

```swift
enum Gender: String, Codable, CaseIterable {
    case male, female
    var displayName: String  // "男" / "女"
}
```

### UserProfile (struct)

| 屬性             | 型別     | 說明                      |
| ---------------- | -------- | ------------------------- |
| `id`             | `UUID`   | 唯一識別碼                |
| `nickname`       | `String` | 暱稱，預設 "Ocard 使用者" |
| `school`         | `String` | 學校名稱                  |
| `department`     | `String` | 科系                      |
| `bio`            | `String` | 自我介紹                  |
| `avatarName`     | `String` | SF Symbol 名稱            |
| `gender`         | `Gender` | 性別（影響頭像顏色）      |
| `postCount`      | `Int`    | 發文數                    |
| `followerCount`  | `Int`    | 粉絲數                    |
| `followingCount` | `Int`    | 追蹤中                    |

### Post (struct)

| 屬性            | 型別      | 說明                            |
| --------------- | --------- | ------------------------------- |
| `id`            | `UUID`    | 唯一識別碼                      |
| `authorId`      | `UUID`    | 作者 ID                         |
| `authorName`    | `String`  | 作者名稱                        |
| `authorAvatar`  | `String`  | 作者頭像                        |
| `authorGender`  | `Gender`  | 作者性別                        |
| `board`         | `String`  | 看板名稱                        |
| `title`         | `String`  | 標題                            |
| `content`       | `String`  | 內容                            |
| `imageName`     | `String?` | 圖片名稱（可選）                |
| `timestamp`     | `Date`    | 發佈時間                        |
| `likeCount`     | `Int`     | 按讚數                          |
| `dislikeCount`  | `Int`     | 倒讚數                          |
| `commentCount`  | `Int`     | 留言數                          |
| `bookmarkCount` | `Int`     | 收藏數（自訂 decoder 向下相容） |
| `isLiked`       | `Bool`    | 是否已按讚                      |
| `isDisliked`    | `Bool`    | 是否已倒讚                      |
| `isBookmarked`  | `Bool`    | 是否已收藏                      |

> `Post` 包含自訂 `init(from decoder:)`，`bookmarkCount` 使用 `decodeIfPresent` 向下相容舊 JSON。

### Comment (struct)

| 屬性           | 型別     | 說明                           |
| -------------- | -------- | ------------------------------ |
| `id`           | `UUID`   | 唯一識別碼                     |
| `postId`       | `UUID`   | 所屬文章 ID                    |
| `authorName`   | `String` | 留言者名稱                     |
| `authorAvatar` | `String` | 留言者頭像                     |
| `authorGender` | `Gender` | 留言者性別                     |
| `content`      | `String` | 留言內容                       |
| `timestamp`    | `Date`   | 留言時間                       |
| `likeCount`    | `Int`    | 按讚數                         |
| `isLiked`      | `Bool`   | 是否已按讚                     |
| `floor`        | `Int`    | 樓層數（B1, B2...）            |
| `replyToFloor` | `Int?`   | 回覆目標樓層（nil 表示非回覆） |

### Forum (struct)

| 屬性              | 型別     | 說明           |
| ----------------- | -------- | -------------- |
| `id`              | `UUID`   | 唯一識別碼     |
| `name`            | `String` | 看板名稱       |
| `icon`            | `String` | SF Symbol 名稱 |
| `description`     | `String` | 看板描述       |
| `subscriberCount` | `Int`    | 訂閱人數       |
| `isSubscribed`    | `Bool`   | 是否已訂閱     |

### AppNotification (struct)

| 屬性            | 型別               | 說明                                   |
| --------------- | ------------------ | -------------------------------------- |
| `id`            | `UUID`             | 唯一識別碼                             |
| `type`          | `NotificationType` | 通知類型（like/comment/follow/system） |
| `title`         | `String`           | 通知標題                               |
| `message`       | `String`           | 通知內容                               |
| `timestamp`     | `Date`             | 通知時間                               |
| `isRead`        | `Bool`             | 是否已讀                               |
| `relatedPostId` | `UUID?`            | 關聯文章 ID                            |

> 所有 Model 均遵循 `Identifiable`, `Codable`, `Equatable`。

---

## View 詳細說明

| 檔案                 | 說明                         | 重點功能                                                                                                                      |
| -------------------- | ---------------------------- | ----------------------------------------------------------------------------------------------------------------------------- |
| **HomeView**         | 首頁 — 文章動態牆            | 看板篩選 Chip、下拉更新、**FAB 浮動發文按鈕**（`onChange` + `GeometryReader` 偵測滾動方向，下滑隱藏/上滑顯現）、搜尋入口      |
| **ForumListView**    | 看板列表 + `ForumDetailView` | 搜尋看板、已追蹤/探索分組、訂閱切換動畫、看板詳情頁含文章                                                                     |
| **PostCardView**     | 文章卡片（可複用）           | Avatar、看板標籤、作者、時間、標題、內容預覽、按讚數 + 留言數 + 收藏數                                                        |
| **PostDetailView**   | 文章詳情 + 留言區            | 按讚/倒讚/收藏（含次數）/分享 Action Bar、留言列表含回覆功能、底部留言輸入框（VStack 固定佈局）、回覆指示器（回覆 BN + 取消） |
| **CreatePostView**   | 發文頁面                     | 看板選擇器 Sheet、標題/內容、工具列（照片/相機/表情/位置佔位）、發佈驗證                                                      |
| **CommentRowView**   | 單則留言                     | Avatar、樓層號、內容、時間、按讚、回覆按鈕（callback）、回覆標籤（「回覆 BN」膠囊）                                           |
| **SearchView**       | 搜尋頁面                     | 熱門搜尋標籤（FlowLayout）、最新文章、即時結果、空狀態                                                                        |
| **NotificationView** | 通知頁面                     | 列表、未讀/已讀區分、全部已讀、圖示色依類型                                                                                   |
| **ProfileView**      | 個人頁面                     | 頭像/使用者資訊、統計、三分頁（文章/收藏/留言紀錄）                                                                           |
| **EditProfileView**  | 編輯個人資料                 | 性別選擇（影響頭像色）、暱稱/學校/科系/自介、儲存                                                                             |

---

## 共用模組

### Theme.swift

集中管理所有設計 token：

| 分類   | 常數                                                         | 說明           |
| ------ | ------------------------------------------------------------ | -------------- |
| 品牌色 | `brandBlue`, `brandLightBlue`, `brandDarkBlue`               | #006AA6 系列   |
| 背景   | `background`, `cardBackground`, `navBackground`              | 灰底白卡       |
| 文字   | `textPrimary`, `textSecondary`, `textTertiary`               | 深→中→淺       |
| 語義色 | `likeRed`, `dislikeGray`, `bookmarkYellow`                   | 互動反饋       |
| 通知色 | `notifLike`, `notifComment`, `notifFollow`, `notifSystem`    | 各類通知       |
| 性別色 | `maleBlue`, `femalePink`, `maleLightBlue`, `femaleLightPink` | Dcard 頭像     |
| 漸層   | `headerGradient`                                             | 標題列背景     |
| 卡片   | `cardCornerRadius`, `cardShadow`                             | 統一圓角與陰影 |

#### 內含元件

- **`AvatarView(gender:size:)`** — Dcard 風格性別漸層圓形頭像
- **`Color(hex:)`** — 十六進位色碼轉 SwiftUI Color
- **`Date.timeAgoDisplay()`** — 「剛剛 / N 分鐘前 / N 小時前 / N 天前 / MM/dd」

### DataStore.swift — 核心業務方法

| 方法                                                   | 說明                             |
| ------------------------------------------------------ | -------------------------------- |
| `toggleLike(post:)`                                    | 按讚/取消（與倒讚互斥）          |
| `toggleDislike(post:)`                                 | 倒讚/取消（與按讚互斥）          |
| `toggleBookmark(post:)`                                | 收藏切換 + bookmarkCount 增減    |
| `addPost(board:title:content:)`                        | 新增文章                         |
| `deletePost(_:)`                                       | 刪除文章及關聯留言               |
| `addComment(postId:content:)`                          | 新增留言（自動算樓層、通知作者） |
| `addReply(postId:replyToFloor:content:)`               | 回覆特定樓層（Dcard 建樓）       |
| `toggleCommentLike(comment:)`                          | 留言按讚                         |
| `toggleSubscribe(forum:)`                              | 看板訂閱切換                     |
| `markAsRead(notification:)`                            | 單則通知已讀                     |
| `markAllAsRead()`                                      | 全部通知已讀                     |
| `updateProfile(...)`                                   | 更新個人資料                     |
| `postsForBoard(_:)`                                    | 依看板篩選文章                   |
| `searchPosts(query:)`                                  | 模糊搜尋文章                     |
| `userPosts()` / `bookmarkedPosts()` / `userComments()` | 個人頁面篩選                     |

---

## Mock 資料系統

- 首次啟動由 `seedMockData()` 產生：**14 個看板**、**15 篇文章**、**每篇 12 則情境留言**（共 180 則）、**5 則通知**
- 留言內容**按文章主題分類**，不隨機配對（如感情文配安慰留言、美食文配討論口味）
- 版本控制：`hasSeededKey = "ocard_has_seeded_v5"`，修改 Model 結構後遞增版本號可強制重新種子
- 留言者有 16 個個性化暱稱（小明、吃貨一枚、夜貓子、咖啡成癮者…）
- 約 30% 的留言為樓中回覆（`replyToFloor != nil`）

---

## 開發指南

### 新增一個 View

1. 在 `Views/` 建立新 `.swift` 檔
2. 用 `@Environment(DataStore.self)` 取得資料
3. 用 `Theme` 常數保持設計一致
4. 用 `AvatarView(gender:size:)` 顯示頭像

### 新增一個 Model

1. 在 `Models/` 建立 struct，遵循 `Identifiable, Codable, Equatable`
2. 若新增非 Optional 欄位，**必須**加自訂 `init(from decoder:)` 使用 `decodeIfPresent` + 預設值（參考 `Post.swift`）
3. 在 `DataStore` 中新增屬性 + UserDefaults Key
4. 更新 `saveData()` / `loadData()`
5. 結構變動後遞增 `hasSeededKey` 版本號

### 新增功能/操作

1. 在 `DataStore` 新增業務方法
2. 結尾呼叫 `saveData()` 確保持久化
3. 在 View 中呼叫 `store.yourMethod()`

### 修改主題色彩

修改 `Theme.swift` 對應靜態屬性即可全域生效：

- 品牌色：`brandBlue`, `brandLightBlue`, `brandDarkBlue`
- 語義色：`likeRed`, `bookmarkYellow`
- 性別色：`maleBlue`, `femalePink`

---

## 程式碼慣例

- View 內用 `MARK: -` 區分區塊
- 顏色一律用 `Theme.xxx`，不直接寫 hex
- 時間顯示一律用 `date.timeAgoDisplay()`
- Model 初始化都有預設參數便於快速建立
- 新增 Model 欄位時必須加 `init(from decoder:)` 向下相容
- 留言者名稱用有個性的暱稱，不用 B1/B2
