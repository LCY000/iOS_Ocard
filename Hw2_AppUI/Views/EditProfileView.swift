import SwiftUI

struct EditProfileView: View {
    @Environment(DataStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    @State private var nickname = ""
    @State private var school = ""
    @State private var department = ""
    @State private var bio = ""
    @State private var selectedAvatar = "person.circle.fill"
    @State private var selectedGender: Gender = .male

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Avatar Preview with Gender Color
                        VStack(spacing: 12) {
                            AvatarView(gender: selectedGender, size: 90)

                            // Gender Selector
                            HStack(spacing: 16) {
                                ForEach(Gender.allCases, id: \.self) { gender in
                                    Button {
                                        withAnimation(.spring(response: 0.3)) {
                                            selectedGender = gender
                                        }
                                    } label: {
                                        HStack(spacing: 6) {
                                            Circle()
                                                .fill(
                                                    gender == .male
                                                        ? Theme.maleBlue
                                                        : Theme.femalePink
                                                )
                                                .frame(width: 20, height: 20)
                                                .overlay(
                                                    Image(systemName: "person.fill")
                                                        .font(.system(size: 10))
                                                        .foregroundStyle(.white)
                                                )

                                            Text(gender.displayName)
                                                .font(.system(size: 15, weight: .medium))
                                                .foregroundStyle(
                                                    selectedGender == gender
                                                        ? Theme.textPrimary
                                                        : Theme.textTertiary
                                                )
                                        }
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 10)
                                        .background(
                                            Capsule()
                                                .fill(
                                                    selectedGender == gender
                                                        ? Theme.genderLightColor(gender)
                                                        : Theme.chipBackground
                                                )
                                        )
                                        .overlay(
                                            Capsule()
                                                .stroke(
                                                    selectedGender == gender
                                                        ? Theme.genderColor(gender)
                                                        : Color.clear,
                                                    lineWidth: 2
                                                )
                                        )
                                    }
                                }
                            }

                            Text("選擇性別會改變頭像顏色")
                                .font(.system(size: 12))
                                .foregroundStyle(Theme.textTertiary)
                        }
                        .padding(.vertical, 20)
                        .background(Theme.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: Theme.cardCornerRadius))
                        .padding(.horizontal, 12)

                        // Profile Fields
                        VStack(spacing: 0) {
                            profileField(title: "暱稱", text: $nickname, placeholder: "輸入暱稱")
                            Divider().padding(.leading, 16)
                            profileField(title: "學校", text: $school, placeholder: "輸入學校名稱")
                            Divider().padding(.leading, 16)
                            profileField(title: "科系", text: $department, placeholder: "輸入科系名稱")
                            Divider().padding(.leading, 16)

                            VStack(alignment: .leading, spacing: 6) {
                                Text("自我介紹")
                                    .font(.system(size: 13))
                                    .foregroundStyle(Theme.textSecondary)

                                TextEditor(text: $bio)
                                    .font(.system(size: 15))
                                    .frame(minHeight: 80)
                                    .scrollContentBackground(.hidden)
                            }
                            .padding(16)
                        }
                        .background(Theme.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: Theme.cardCornerRadius))
                        .padding(.horizontal, 12)
                    }
                    .padding(.top, 16)
                }
            }
            .navigationTitle("編輯個人資料")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                    .foregroundStyle(Theme.textSecondary)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("儲存") {
                        store.updateProfile(
                            nickname: nickname,
                            school: school,
                            department: department,
                            bio: bio,
                            avatarName: selectedAvatar,
                            gender: selectedGender
                        )
                        dismiss()
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Theme.brandBlue)
                }
            }
            .onAppear {
                nickname = store.currentUser.nickname
                school = store.currentUser.school
                department = store.currentUser.department
                bio = store.currentUser.bio
                selectedAvatar = store.currentUser.avatarName
                selectedGender = store.currentUser.gender
            }
        }
    }

    private func profileField(title: String, text: Binding<String>, placeholder: String) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 15))
                .foregroundStyle(Theme.textSecondary)
                .frame(width: 60, alignment: .leading)

            TextField(placeholder, text: text)
                .font(.system(size: 15))
        }
        .padding(16)
    }
}
