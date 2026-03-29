import Foundation
import SwiftUI

@Observable
class DataStore {
    static let shared = DataStore()

    var currentUser: UserProfile
    var posts: [Post]
    var comments: [Comment]
    var forums: [Forum]
    var notifications: [AppNotification]

    // MARK: - UserDefaults Keys
    private let userKey = "ocard_user"
    private let postsKey = "ocard_posts"
    private let commentsKey = "ocard_comments"
    private let forumsKey = "ocard_forums"
    private let notificationsKey = "ocard_notifications"
    private let hasSeededKey = "ocard_has_seeded_v6"

    private init() {
        currentUser = UserProfile()
        posts = []
        comments = []
        forums = []
        notifications = []
        loadData()
        if !UserDefaults.standard.bool(forKey: hasSeededKey) {
            seedMockData()
            UserDefaults.standard.set(true, forKey: hasSeededKey)
            saveData()
        }
    }

    // MARK: - Persistence
    func saveData() {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(currentUser) {
            UserDefaults.standard.set(data, forKey: userKey)
        }
        if let data = try? encoder.encode(posts) {
            UserDefaults.standard.set(data, forKey: postsKey)
        }
        if let data = try? encoder.encode(comments) {
            UserDefaults.standard.set(data, forKey: commentsKey)
        }
        if let data = try? encoder.encode(forums) {
            UserDefaults.standard.set(data, forKey: forumsKey)
        }
        if let data = try? encoder.encode(notifications) {
            UserDefaults.standard.set(data, forKey: notificationsKey)
        }
    }

    private func loadData() {
        let decoder = JSONDecoder()
        if let data = UserDefaults.standard.data(forKey: userKey),
           let user = try? decoder.decode(UserProfile.self, from: data) {
            currentUser = user
        }
        if let data = UserDefaults.standard.data(forKey: postsKey),
           let items = try? decoder.decode([Post].self, from: data) {
            posts = items
        }
        if let data = UserDefaults.standard.data(forKey: commentsKey),
           let items = try? decoder.decode([Comment].self, from: data) {
            comments = items
        }
        if let data = UserDefaults.standard.data(forKey: forumsKey),
           let items = try? decoder.decode([Forum].self, from: data) {
            forums = items
        }
        if let data = UserDefaults.standard.data(forKey: notificationsKey),
           let items = try? decoder.decode([AppNotification].self, from: data) {
            notifications = items
        }
    }

    // MARK: - Post Actions
    func toggleLike(post: Post) {
        guard let index = posts.firstIndex(where: { $0.id == post.id }) else { return }
        if posts[index].isLiked {
            posts[index].isLiked = false
            posts[index].likeCount -= 1
        } else {
            posts[index].isLiked = true
            posts[index].likeCount += 1
            if posts[index].isDisliked {
                posts[index].isDisliked = false
                posts[index].dislikeCount -= 1
            }
        }
        saveData()
    }

    func toggleDislike(post: Post) {
        guard let index = posts.firstIndex(where: { $0.id == post.id }) else { return }
        if posts[index].isDisliked {
            posts[index].isDisliked = false
            posts[index].dislikeCount -= 1
        } else {
            posts[index].isDisliked = true
            posts[index].dislikeCount += 1
            if posts[index].isLiked {
                posts[index].isLiked = false
                posts[index].likeCount -= 1
            }
        }
        saveData()
    }

    func toggleBookmark(post: Post) {
        guard let index = posts.firstIndex(where: { $0.id == post.id }) else { return }
        posts[index].isBookmarked.toggle()
        posts[index].bookmarkCount += posts[index].isBookmarked ? 1 : -1
        saveData()
    }

    func addPost(board: String, title: String, content: String) {
        let post = Post(
            authorId: currentUser.id,
            authorName: currentUser.nickname,
            authorAvatar: currentUser.avatarName,
            authorGender: currentUser.gender,
            board: board,
            title: title,
            content: content
        )
        posts.insert(post, at: 0)
        currentUser.postCount += 1
        saveData()
    }

    func deletePost(_ post: Post) {
        posts.removeAll { $0.id == post.id }
        comments.removeAll { $0.postId == post.id }
        currentUser.postCount = max(0, currentUser.postCount - 1)
        saveData()
    }

    // MARK: - Comment Actions
    func addComment(postId: UUID, content: String) {
        let existingComments = comments.filter { $0.postId == postId }
        let floor = existingComments.count + 1
        let comment = Comment(
            postId: postId,
            authorName: currentUser.nickname,
            authorAvatar: currentUser.avatarName,
            authorGender: currentUser.gender,
            content: content,
            floor: floor
        )
        comments.append(comment)
        if let index = posts.firstIndex(where: { $0.id == postId }) {
            posts[index].commentCount += 1
        }

        // Add notification
        if let post = posts.first(where: { $0.id == postId }),
           post.authorId == currentUser.id {
            // Don't notify self
        } else {
            let notif = AppNotification(
                type: .comment,
                title: "新留言",
                message: "\(currentUser.nickname) 在你的文章留言了",
                relatedPostId: postId
            )
            notifications.insert(notif, at: 0)
        }
        saveData()
    }

    func addReply(postId: UUID, replyToFloor: Int, content: String) {
        let existingComments = comments.filter { $0.postId == postId }
        let floor = existingComments.count + 1
        let comment = Comment(
            postId: postId,
            authorName: currentUser.nickname,
            authorAvatar: currentUser.avatarName,
            authorGender: currentUser.gender,
            content: content,
            floor: floor,
            replyToFloor: replyToFloor
        )
        comments.append(comment)
        if let index = posts.firstIndex(where: { $0.id == postId }) {
            posts[index].commentCount += 1
        }

        if let post = posts.first(where: { $0.id == postId }),
           post.authorId == currentUser.id {
            // Don't notify self
        } else {
            let notif = AppNotification(
                type: .comment,
                title: "新回覆",
                message: "\(currentUser.nickname) 回覆了 B\(replyToFloor) 的留言",
                relatedPostId: postId
            )
            notifications.insert(notif, at: 0)
        }
        saveData()
    }

    func toggleCommentLike(comment: Comment) {
        guard let index = comments.firstIndex(where: { $0.id == comment.id }) else { return }
        if comments[index].isLiked {
            comments[index].isLiked = false
            comments[index].likeCount -= 1
        } else {
            comments[index].isLiked = true
            comments[index].likeCount += 1
        }
        saveData()
    }

    func commentsForPost(_ postId: UUID) -> [Comment] {
        comments.filter { $0.postId == postId }.sorted { $0.floor < $1.floor }
    }

    // MARK: - Forum Actions
    func toggleSubscribe(forum: Forum) {
        guard let index = forums.firstIndex(where: { $0.id == forum.id }) else { return }
        forums[index].isSubscribed.toggle()
        forums[index].subscriberCount += forums[index].isSubscribed ? 1 : -1
        saveData()
    }

    // MARK: - Notification Actions
    func markAsRead(notification: AppNotification) {
        guard let index = notifications.firstIndex(where: { $0.id == notification.id }) else { return }
        notifications[index].isRead = true
        saveData()
    }

    func markAllAsRead() {
        for i in notifications.indices {
            notifications[i].isRead = true
        }
        saveData()
    }

    var unreadNotificationCount: Int {
        notifications.filter { !$0.isRead }.count
    }

    // MARK: - Profile Actions
    func updateProfile(nickname: String, school: String, department: String, bio: String, avatarName: String, gender: Gender) {
        currentUser.nickname = nickname
        currentUser.school = school
        currentUser.department = department
        currentUser.bio = bio
        currentUser.avatarName = avatarName
        currentUser.gender = gender
        saveData()
    }

    // MARK: - Filtered Data
    func postsForBoard(_ board: String) -> [Post] {
        if board == "全部" || board == "熱門" {
            return posts.sorted { $0.timestamp > $1.timestamp }
        }
        return posts.filter { $0.board == board }.sorted { $0.timestamp > $1.timestamp }
    }

    func userPosts() -> [Post] {
        posts.filter { $0.authorId == currentUser.id }.sorted { $0.timestamp > $1.timestamp }
    }

    func bookmarkedPosts() -> [Post] {
        posts.filter { $0.isBookmarked }.sorted { $0.timestamp > $1.timestamp }
    }

    func userComments() -> [Comment] {
        comments.filter { $0.authorName == currentUser.nickname }.sorted { $0.timestamp > $1.timestamp }
    }

    func searchPosts(query: String) -> [Post] {
        guard !query.isEmpty else { return [] }
        let q = query.lowercased()
        return posts.filter {
            $0.title.lowercased().contains(q) ||
            $0.content.lowercased().contains(q) ||
            $0.board.lowercased().contains(q)
        }
    }

    // MARK: - Seed Mock Data
    private func seedMockData() {
        // Forums
        forums = [
            Forum(name: "閒聊", icon: "bubble.left.and.bubble.right.fill", description: "隨意聊天的地方", subscriberCount: 128_000, isSubscribed: true),
            Forum(name: "有趣", icon: "face.smiling.fill", description: "分享有趣的事物", subscriberCount: 95_000, isSubscribed: true),
            Forum(name: "感情", icon: "heart.fill", description: "感情分享與討論", subscriberCount: 112_000, isSubscribed: false),
            Forum(name: "美食", icon: "fork.knife", description: "美食推薦與食記", subscriberCount: 87_000, isSubscribed: true),
            Forum(name: "穿搭", icon: "tshirt.fill", description: "穿搭分享與討論", subscriberCount: 76_000, isSubscribed: false),
            Forum(name: "彩妝", icon: "sparkles", description: "彩妝保養心得", subscriberCount: 68_000, isSubscribed: false),
            Forum(name: "時事", icon: "newspaper.fill", description: "時事話題討論", subscriberCount: 102_000, isSubscribed: true),
            Forum(name: "工作", icon: "briefcase.fill", description: "職場經驗分享", subscriberCount: 91_000, isSubscribed: false),
            Forum(name: "3C", icon: "desktopcomputer", description: "3C 科技產品討論", subscriberCount: 83_000, isSubscribed: true),
            Forum(name: "追劇", icon: "tv.fill", description: "戲劇綜藝討論", subscriberCount: 79_000, isSubscribed: false),
            Forum(name: "運動", icon: "figure.run", description: "運動健身分享", subscriberCount: 65_000, isSubscribed: false),
            Forum(name: "旅遊", icon: "airplane", description: "旅遊經驗分享", subscriberCount: 72_000, isSubscribed: true),
            Forum(name: "音樂", icon: "music.note", description: "音樂推薦討論", subscriberCount: 58_000, isSubscribed: false),
            Forum(name: "課業", icon: "book.fill", description: "課業學習討論", subscriberCount: 94_000, isSubscribed: true),
        ]

        // Posts — tuple: (board, title, content, authorInfo, likeCount, commentCount, gender, isCurrentUser)
        let postData: [(String, String, String, String, Int, Int, Gender, Bool)] = [
            ("閒聊", "今天在圖書館發生超尷尬的事", "今天在圖書館讀書讀到一半，肚子突然發出超大聲的咕嚕聲，整個安靜的空間都聽得到 😭 旁邊的人都看過來了...\n\n最尷尬的是我旁邊坐的竟然是我暗戀的學長，我真的想找個地洞鑽進去...\n\n有沒有人也在圖書館發生過很糗的事啊？", "台大 · 資工系", 87, 23, .female, false),
            ("美食", "台北車站附近超好吃的拉麵推薦！", "最近發現北車 M8 出口附近新開了一家拉麵店，叫做「麵道」\n\n他們的豚骨拉麵真的太好喝了！湯頭非常濃郁但不會膩，叉燒也烤得恰到好處，半熟蛋的蛋黃超級流動 🤤\n\n重點是價格也很合理，一碗才 180 元！\n\n推薦大家去試試！", "輔大 · 日文系", 156, 45, .male, true),
            ("感情", "分手三個月了 還是好想他", "跟前任在一起三年多，三個月前他說他累了想分開...\n\n這三個月來我試著讓自己忙碌，去健身、學新東西，但每到晚上還是會想起他\n\n尤其是經過我們以前常去的那間咖啡廳，眼淚就忍不住流下來\n\n大家都說時間會沖淡一切，但好像還要很久很久...", "政大 · 心理系", 234, 89, .female, false),
            ("有趣", "我家貓咪居然學會開門了 🐱", "養了兩年的橘貓最近進化了！\n\n前幾天聽到房間門被打開，以為是室友，結果一看竟然是我家那隻橘貓自己跳上去按門把手把門打開的！\n\n我上網查了一下好像不少貓咪都會，但親眼看到還是覺得他太聰明了吧 😂\n\n養貓的大家有沒有遇過類似的事？", "成大 · 機械系", 312, 67, .male, false),
            ("3C", "M4 MacBook Pro 用了兩個月心得", "兩個月前入手了 M4 Pro 的 MacBook Pro 14 吋\n\n先說結論：真的值得升級！\n\n效能：跑 Xcode 編譯速度快了超多，大專案也不會卡\n螢幕：mini-LED 真的太美了\n續航：正常使用一天下來還有 30% 以上\n\n唯一小缺點是 Thunderbolt 5 目前還沒什麼週邊可以用到全速\n\n整體來說非常滿意！有問題歡迎留言問我", "台科大 · 資工系", 198, 56, .male, false),
            ("穿搭", "春天穿搭分享 🌸", "最近天氣越來越暖了，分享一下我最近的穿搭！\n\n以淺色系為主，搭配一件薄外套剛剛好\n\n上衣：UNIQLO 奶油白針織衫\n下身：Zara 卡其色寬褲\n鞋：New Balance 530\n包：Longchamp 水餃包\n\n春天就是要穿得清爽！大家最近都怎麼穿？", "淡江 · 大傳系", 145, 34, .female, false),
            ("時事", "關於最近的 AI 發展大家怎麼看？", "最近 AI 的發展真的太快了，從 ChatGPT 到現在各種 AI 工具層出不窮\n\n身為資工系的學生，一方面覺得很興奮，另一方面也有點擔心未來工作會不會被取代\n\n特別是看到 AI 已經可以寫程式、畫圖、做影片了...\n\n大家對於 AI 的未來發展有什麼想法嗎？會擔心嗎？", "清大 · 資工系", 267, 112, .male, false),
            ("工作", "第一份工作心得分享（軟體工程師）", "去年六月畢業，現在在某科技公司當軟體工程師快一年了\n\n分享幾個新鮮人的心得：\n\n1. 不會就問，不要自己硬撐\n2. 寫程式只佔工作的一部分，溝通能力也超重要\n3. 保持學習的習慣，技術更新很快\n4. 健康真的要顧好，久坐很傷身\n\n未來有想進科技業的可以交流！", "交大 · 資工系", 189, 43, .male, false),
            ("閒聊", "室友的奇葩行為讓我崩潰", "我室友最近的行為真的讓我很無言...\n\n1. 凌晨三點大聲打電動還開喇叭\n2. 把我的牙膏擠到剩一點點也不說\n3. 洗完衣服不拿出來，放在洗衣機裡面臭掉\n4. 邀請朋友來寢室玩到半夜卻不先說\n\n已經溝通過好幾次了但完全沒用，該怎麼辦啊 😤", "中興 · 企管系", 432, 156, .female, false),
            ("追劇", "最近在追的韓劇推薦！超好看", "最近追了幾部韓劇都超好看，來推薦給大家！\n\n1.《與惡魔有約》- 奇幻浪漫劇，男女主角超有 CP 感\n2.《黑暗榮耀》第二季 - 復仇爽劇，每集都超精彩\n3.《淚之女王》- 虐心但好看，金秀賢太帥了\n\n大家最近有在追什麼好劇嗎？求推薦！", "銘傳 · 廣告系", 278, 98, .female, false),
            ("運動", "健身新手三個月的變化", "三個月前開始上健身房，分享一下心得和變化\n\n飲食：\n- 每天蛋白質攝取 1.6g/kg\n- 減少精緻糖和加工食品\n- 多喝水\n\n訓練：\n- 一週練四天，胸背肩腿分開\n- 從空槓開始慢慢加重量\n\n目前體重從 72 降到 68，體脂從 25% 到 20%\n最明顯的變化是衣服穿起來更好看了！加油 💪", "北大 · 體育系", 167, 38, .male, false),
            ("旅遊", "日本京都五天四夜攻略", "上個月去了京都，分享一下行程！\n\nDay 1: 伏見稻荷大社 → 清水寺 → 花見小路\nDay 2: 金閣寺 → 龍安寺 → 嵐山竹林\nDay 3: 奈良公園 → 東大寺（餵鹿超可愛）\nDay 4: 二條城 → 錦市場 → 河原町購物\nDay 5: 宇治 → 平等院 → 抹茶甜點巡禮\n\n預算大約三萬含機票，CP 值超高！\n有要去的歡迎問我～", "東海 · 日文系", 356, 87, .female, false),
            ("課業", "大學選課的血淚經驗談", "大四了回頭看選課這件事真的有很多心得想分享\n\n1. 通識不要都選涼課，有些認真的通識真的會學到東西\n2. 大一大二把必修修完，大三大四才不會撞課\n3. 選課系統一開就要搶，不然好課都沒了\n4. 可以先去旁聽第一週再決定要不要退選\n5. 跟學長姐要課程心得很重要！\n\n希望對學弟妹有幫助～", "師大 · 教育系", 223, 52, .male, false),
            ("音樂", "分享最近單曲循環的歌 🎵", "最近一直在聽這幾首歌，分享給大家！\n\n1. 告五人 -《在這座城市遺失了你》\n2. 韋禮安 -《而立》\n3. 9m88 -《Plastic Love》\n4. 落日飛車 -《My Jinji》\n5. IU -《Love wins all》\n\n每首都超好聽！大家最近在聽什麼？一起交換歌單！", "北藝大 · 音樂系", 134, 76, .female, false),
            ("彩妝", "開架防曬評比！夏天必看", "夏天快到了，整理了幾款熱門開架防曬的使用心得：\n\n1. Anessa 金鑽 - 防曬力最強但稍微泛白\n2. Biore 含水防曬 - 最清爽但防水力較弱\n3. 曼秀雷敦 Skin Aqua - CP 值最高\n4. Canmake Mermaid - 妝前最好用\n5. Orbis 防曬 - 最適合敏感肌\n\n個人最推 Skin Aqua，便宜又好用！", "文化 · 生科系", 189, 42, .female, false),
        ]

        var generatedPosts: [Post] = []
        var generatedComments: [Comment] = []

        for (i, data) in postData.enumerated() {
            let postId = UUID()
            let isUserPost = data.7
            let post = Post(
                id: postId,
                authorId: isUserPost ? currentUser.id : UUID(),
                authorName: isUserPost ? currentUser.nickname : (data.3.components(separatedBy: " · ").first ?? "匿名"),
                authorAvatar: "person.circle.fill",
                authorGender: isUserPost ? currentUser.gender : data.6,
                board: data.0,
                title: data.1,
                content: data.2,
                timestamp: Date().addingTimeInterval(Double(-i * 3600 - Int.random(in: 0...3600))),
                likeCount: data.4,
                bookmarkCount: Int.random(in: 5...60)
            )
            generatedPosts.append(post)

            // Per-post contextual comments (index matches postData)
            let perPostComments: [[String]] = [
                // 0: 閒聊 - 圖書館尷尬的事
                ["天啊我也在圖書館放過屁超大聲 😭", "笑死，這根本社死現場", "學長有回頭看你嗎？後來呢！", "我上次在圖書館打翻整杯咖啡...", "肚子叫真的超尷尬 我每次都帶零食", "拍拍～下次記得吃飽再去", "哈哈哈哈太可愛了吧", "我之前在圖書館睡著還打呼...", "暗戀的學長在旁邊這也太刺激了", "圖書館真的是社死聖地", "我有次手機鬧鐘忘關在圖書館響超久", "原 po 加油 下次一定沒事的 ❤️"],
                // 1: 美食 - 拉麵推薦
                ["太讚了！請問他們幾點開？", "M8 出口那邊我知道！改天去試", "180 這價格真的佛心 🤤", "豚骨拉麵派的站出來！", "我也吃過！半熟蛋真的超好吃", "有素食選項嗎？", "推推～上個月去過，排了 30 分鐘但值得", "他們的叉燒飯也很推薦！", "附近還有一家沾麵也不錯，可以順便試試", "看完肚子好餓 😂", "請問有辣的口味嗎？", "已收藏！週末就去 📌"],
                // 2: 感情 - 分手三個月
                ["拍拍 時間真的是最好的解藥 ❤️", "三年真的很長...你辛苦了", "我也經歷過，大概半年後才真正放下", "不要去那間咖啡廳了，換條路走", "抱抱你 🤗 要對自己好一點", "去旅行吧！換個環境會好一點", "分手一年了我還是會想到他...", "可以試著寫日記把情緒抒發出來", "你值得更好的！", "我是哭著看完這篇的...", "時間會把最好的人帶到你身邊的", "原 po 加油，你不孤單 💕"],
                // 3: 有趣 - 貓咪開門
                ["橘貓真的太聰明了！😂", "我家的貓只會盯著門叫...", "有影片嗎？好想看！", "貓咪：你以為這扇門能擋住我？", "我家狗看到會嚇到", "進化了！下一步就是開冰箱了", "橘貓真的是貓界天才 🐱", "我家貓會開抽屜偷零食...", "太可愛了吧哈哈哈", "牠是不是以前看你開過然後學起來的？", "請分享更多貓咪日常 🥺", "養貓的每天都有驚喜"],
                // 4: 3C - M4 MacBook Pro
                ["M4 Pro 真的快很多！同意", "14 吋螢幕會不會太小？考慮 16 吋", "請問你之前用什麼機型？差異感明顯嗎？", "我還在猶豫 M4 還是等 M5...", "續航那麼強！可以不帶充電器出門嗎？", "Xcode 編譯快是真的 工作效率提升好多", "學生價買大概多少？", "TB5 週邊真的還太少了 同意你說的", "mini-LED 看影片真的是享受", "我用 M2 還撐得住，但看完好心動", "記憶體選 18G 夠用嗎？", "感謝分享！決定入手了 💸"],
                // 5: 穿搭 - 春天穿搭
                ["NB 530 好好看！我也有一雙", "這套配色好清爽 🌸", "寬褲真的春天必備", "UNIQLO 針織衫哪個色號？想去找", "我最近都穿帽 T + 長裙", "水餃包搭這套超適合", "春天穿搭就是要淺色！同意", "請問寬褲是哪款？想入手", "拜託分享更多穿搭 🙏", "好好看～我都不知道怎麼搭", "有男生版的穿搭建議嗎？", "看完想去逛街了 😂"],
                // 6: 時事 - AI 發展
                ["工具要會用不會被取代，不會用才會", "身為文組覺得很有危機感...", "AI 是工具，重點是你怎麼用它", "我覺得溝通和創意能力還是 AI 取代不了的", "其實 AI 也創造了很多新工作機會", "擔心 +1 但也很期待未來的發展", "我已經開始學 AI 相關課程了", "不只資工系，各行各業都受影響", "關鍵是持續學習，不要停下來", "用 AI 寫程式效率真的提升超多", "未來的工作型態一定會大改變", "推薦大家可以先學 prompt engineering"],
                // 7: 工作 - 第一份工作心得
                ["第四點真的！久坐超傷腰", "溝通能力 +1 比寫程式還重要", "請問第一年薪水大概多少呀？", "新鮮人最重要的就是態度 推推", "你的心得跟我主管說的一模一樣", "請問你是用什麼語言？", "加班多嗎？工作生活平衡如何？", "保持學習真的很重要！科技變太快了", "想問面試有什麼建議嗎？", "羨慕～我還在找第一份工作中 😢", "很實用的分享 已收藏 📌", "同是軟體工程師，完全同意你說的"],
                // 8: 閒聊 - 室友奇葩行為
                ["凌晨三點開喇叭也太離譜...", "我室友更誇張 直接帶男/女友過夜", "可以跟宿舍管理員反映嗎？", "建議直接換寢室 溝通沒用就別浪費時間了", "牙膏那個我也遇過 超無言", "拍拍～壞室友真的會影響大學生活", "我之前也遇過 後來直接搬出去住了", "洗衣機那個太噁了吧 😤", "建議買個耳塞 至少睡覺不受影響", "大學室友真的要看運氣...", "可以找舍監或 RA 幫忙協調", "記錄下來 必要時可以申請換寢"],
                // 9: 追劇 - 韓劇推薦
                ["淚之女王真的超好看！已哭爛", "黑暗榮耀第二季是神劇 推推", "金秀賢太帥了 每部都看 😍", "推《非常律師禹英禑》也超好看！", "最近在追《背著善宰跑》", "有沒有推薦不虐的？我怕受不了 😂", "來推《怪物》也很精彩！懸疑推理類的", "韓劇品質真的越來越高了", "求推薦搞笑類的韓劇！", "追劇追到半夜 隔天上課打瞌睡...", "與惡魔有約的 OST 也超好聽", "Netflix 上面都有嗎？還是要用其他平台"],
                // 10: 運動 - 健身三個月
                ["三個月就有這成果太厲害了！", "蛋白質攝取那個很重要 推", "請問你去哪間健身房？月費多少？", "從空槓開始真的是正確的做法 👍", "我也想開始健身但不知道從何開始...", "體脂降 5% 很厲害欸！", "可以分享你的菜單嗎？", "減少精緻糖真的差很多 我試過", "一週四天會不會太累？怎麼安排的", "衣服穿起來好看真的是最大動力 💪", "有推薦的蛋白粉品牌嗎？", "已收藏 準備跟著做 📌"],
                // 11: 旅遊 - 京都攻略
                ["三萬含機票也太划算！怎麼訂的？", "嵐山竹林真的超美 推推", "餵鹿超可愛！但要小心被咬 😂", "宇治的抹茶真的是世界級的好喝", "排清水寺會不會排很久？", "住哪個區域比較方便？推薦嗎", "我預計明年去！先收藏 📌", "錦市場的玉子燒必吃！", "請問你是哪個月去的？怕太熱", "伏見稻荷大社的千鳥居超壯觀", "日本的交通建議買什麼 pass？", "看完好想立刻飛去日本！✈️"],
                // 12: 課業 - 選課經驗
                ["大一沒聽學長姐的話 大三好後悔...", "第三點太真實了 搶課像打仗", "通識選認真的 +1 真的會學到東西", "旁聽第一週真的很重要！", "推薦大家用選課評價網站查", "我大二才開始規劃 有點晚了 😢", "必修先修完真的是金句！", "早八的課能不選就不選 相信我", "教授很重要 同一門課不同教授差很多", "這篇根本大學生存手冊 已收藏", "學長姐的筆記和考古題也很重要～", "推推 希望學弟妹不要走冤枉路"],
                // 13: 音樂 - 單曲循環
                ["告五人那首真的超好哭 😢", "落日飛車讚讚！My Jinji 一生推", "IU 的歌每首都是經典", "推薦茄子蛋的《浪流連》也很好聽", "我最近在聽 Aimer 的新專輯", "9m88 的聲音太有魅力了", "可以推薦幾首適合讀書聽的嗎？", "韋禮安的歌詞寫得真的很好", "已加入歌單 謝謝分享！🎵", "推落日飛車！他們的歌都超有氛圍", "最近在聽五月天的《知足》單曲循環", "有沒有推薦冷門但超好聽的？"],
                // 14: 彩妝 - 防曬評比
                ["Skin Aqua 我也用！CP 值真的最高", "Anessa 泛白這點真的有點困擾", "敏感肌推 Orbis +1 不會過敏", "Canmake 當妝前真的超好用", "請問哪款最適合男生用？", "Biore 適合不出汗的場合", "開架防曬就很夠用了 不用買專櫃", "提醒大家防曬要補擦才有效喔！", "擦防曬記得要卸妝～", "混油肌推薦哪款？不想太油", "物理防曬跟化學防曬怎麼選？", "已收藏！夏天必備清單 ☀️"],
            ]

            let authorNames = ["小明", "路人甲", "吃貨一枚", "夜貓子", "學霸不是我", "咖啡成癮者",
                               "追劇達人", "佛系大學生", "社畜日常", "喵喵控", "健身狂",
                               "音樂廢人", "旅行者", "職場新鮮人", "深夜食堂", "文青本青"]

            let postComments = perPostComments[i]
            let commentCount = postComments.count
            for j in 0..<commentCount {
                let commentGender: Gender = Bool.random() ? .male : .female
                let author = authorNames[j % authorNames.count]

                // First few comments are direct, later ones have 30% chance to be a reply
                let isReply = j > 2 && Int.random(in: 0...9) < 3
                let replyFloor: Int? = isReply ? Int.random(in: 1...min(j, 3)) : nil

                let cmnt = Comment(
                    postId: postId,
                    authorName: author,
                    authorGender: commentGender,
                    content: postComments[j],
                    timestamp: Date().addingTimeInterval(Double(-i * 3600 + j * 300 + Int.random(in: 0...200))),
                    likeCount: Int.random(in: 0...50),
                    floor: j + 1,
                    replyToFloor: replyFloor
                )
                generatedComments.append(cmnt)
            }

            // Update post's commentCount to match actual generated comments
            generatedPosts[generatedPosts.count - 1].commentCount = commentCount
        }

        posts = generatedPosts
        comments = generatedComments
        currentUser.postCount = 1

        // Notifications
        notifications = [
            AppNotification(type: .like, title: "有人按讚", message: "有人對你的文章「台北車站附近超好吃的拉麵推薦！」按了愛心", timestamp: Date().addingTimeInterval(-1800)),
            AppNotification(type: .comment, title: "新留言", message: "B3 在你的文章「台北車站附近超好吃的拉麵推薦！」留言了", timestamp: Date().addingTimeInterval(-3600)),
            AppNotification(type: .like, title: "有人按讚", message: "有人對你的文章「台北車站附近超好吃的拉麵推薦！」按了愛心", timestamp: Date().addingTimeInterval(-7200)),
            AppNotification(type: .follow, title: "新追蹤者", message: "有一位新的追蹤者關注了你", timestamp: Date().addingTimeInterval(-10800)),
            AppNotification(type: .system, title: "系統通知", message: "歡迎使用 Ocard！快來發表你的第一篇文章吧！", timestamp: Date().addingTimeInterval(-86400), isRead: true),
        ]
    }
}
