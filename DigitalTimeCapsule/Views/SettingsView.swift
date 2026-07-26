import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: LettersViewModel

    @AppStorage(NotificationSettingsKey.enabled) private var notificationsEnabled = true
    @AppStorage(NotificationSettingsKey.sound) private var soundEnabled = true

    @State private var activePage: LegalPage?
    @State private var showingDeleteAll = false

    private let privacyURL = URL(string: "https://novalinecore.pages.dev/#privacy")!

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 18) {
                Text("Settings")
                    .font(.rounded(26, .heavy))
                    .foregroundColor(AppTheme.textPrimary)

                sectionTitle("Preferences")
                VStack(spacing: 12) {
                    toggleRow(icon: "bell.fill", title: "Notifications", isOn: $notificationsEnabled)
                    toggleRow(icon: "speaker.wave.2.fill", title: "Notification Sound", isOn: $soundEnabled)
                        .opacity(notificationsEnabled ? 1 : 0.4)
                        .disabled(!notificationsEnabled)
                }

                sectionTitle("Data")
                VStack(spacing: 12) {
                    actionRow(icon: "trash.fill", title: "Delete All Letters", destructive: true) {
                        showingDeleteAll = true
                    }
                }

                sectionTitle("Legal")
                VStack(spacing: 12) {
                    linkRow(icon: "hand.raised.fill", title: "Privacy Policy") {
                        activePage = LegalPage(title: "Privacy Policy", url: privacyURL)
                    }
                }

                Text("Version 1.0")
                    .font(.rounded(13, .regular))
                    .foregroundColor(AppTheme.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 10)
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, AppTheme.tabBarHeight + 20)
        }
        .background(AppTheme.background.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $activePage) { page in
            WebPageSheet(page: page)
        }
        .confirmationDialog("Delete all letters?",
                            isPresented: $showingDeleteAll,
                            titleVisibility: .visible) {
            Button("Delete All", role: .destructive) {
                viewModel.deleteAll()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This permanently removes every letter. This action cannot be undone.")
        }
        .onChange(of: notificationsEnabled) { enabled in
            if enabled {
                NotificationManager.shared.rescheduleAll(viewModel.letters)
            } else {
                NotificationManager.shared.cancelAll()
            }
        }
        .onChange(of: soundEnabled) { _ in
            if notificationsEnabled {
                NotificationManager.shared.rescheduleAll(viewModel.letters)
            }
        }
    }

    private func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(.rounded(15, .semibold))
            .foregroundColor(AppTheme.textSecondary)
            .padding(.top, 6)
    }

    private func toggleRow(icon: String, title: String, isOn: Binding<Bool>) -> some View {
        HStack(spacing: 14) {
            rowIcon(icon)
            Text(title)
                .font(.rounded(16, .medium))
                .foregroundColor(AppTheme.textPrimary)
            Spacer()
            Toggle("", isOn: isOn)
                .labelsHidden()
                .tint(AppTheme.accent)
        }
        .padding(16)
        .background(rowBackground)
    }

    private func actionRow(icon: String, title: String, destructive: Bool = false, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(destructive ? Color(red: 0.95, green: 0.4, blue: 0.4) : AppTheme.accent)
                    .frame(width: 26)
                Text(title)
                    .font(.rounded(16, .medium))
                    .foregroundColor(destructive ? Color(red: 0.95, green: 0.4, blue: 0.4) : AppTheme.textPrimary)
                Spacer()
            }
            .padding(16)
            .background(rowBackground)
        }
    }

    private func linkRow(icon: String, title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                rowIcon(icon)
                Text(title)
                    .font(.rounded(16, .medium))
                    .foregroundColor(AppTheme.textPrimary)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(AppTheme.textSecondary)
            }
            .padding(16)
            .background(rowBackground)
        }
    }

    private func rowIcon(_ icon: String) -> some View {
        Image(systemName: icon)
            .font(.system(size: 18))
            .foregroundColor(AppTheme.accent)
            .frame(width: 26)
    }

    private var rowBackground: some View {
        RoundedRectangle(cornerRadius: AppTheme.cornerMedium, style: .continuous)
            .fill(AppTheme.surface)
    }
}
