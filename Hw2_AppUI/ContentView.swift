//
//  ContentView.swift
//  Hw2_AppUI
//
//  Created by ChengYou on 2026/3/27.
//

import SwiftUI

struct ContentView: View {
    @State private var store = DataStore.shared
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("首頁")
                }
                .tag(0)

            ForumListView()
                .tabItem {
                    Image(systemName: "square.grid.2x2.fill")
                    Text("看板")
                }
                .tag(1)

            NotificationView()
                .tabItem {
                    Image(systemName: "bell.fill")
                    Text("通知")
                }
                .tag(2)

            ProfileView()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("我的")
                }
                .tag(3)
        }
        .tint(Theme.brandBlue)
        .environment(store)
    }
}

#Preview {
    ContentView()
}
