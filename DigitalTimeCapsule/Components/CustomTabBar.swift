import SwiftUI

enum AppTab {
    case home
    case letters
    case profile
    case settings
}

struct CustomTabBar: View {
    @Binding var selectedTab: AppTab
    var onCreate: () -> Void

    var body: some View {
        HStack(spacing: 0) {
            tabItem(.home, systemName: "house.fill", title: "Home")
            tabItem(.letters, systemName: "tray.full.fill", title: "Letters")
            createItem
            tabItem(.profile, systemName: "person.fill", title: "Profile")
            tabItem(.settings, systemName: "gearshape.fill", title: "Settings")
        }
        .padding(.horizontal, 10)
        .padding(.top, 8)
        .padding(.bottom, 6)
        .frame(maxWidth: .infinity)
        .background(
            AppTheme.surface
                .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
                .shadow(color: Color.black.opacity(0.4), radius: 12, y: -2)
                .ignoresSafeArea(edges: .bottom)
        )
    }

    private func tabItem(_ tab: AppTab, systemName: String, title: String) -> some View {
        Button {
            selectedTab = tab
        } label: {
            VStack(spacing: 5) {
                Image(systemName: systemName)
                    .font(.system(size: 19, weight: .semibold))
                Text(title)
                    .font(.rounded(10, .medium))
            }
            .foregroundColor(selectedTab == tab ? AppTheme.accent : AppTheme.textSecondary)
            .frame(maxWidth: .infinity)
        }
    }

    private var createItem: some View {
        Button(action: onCreate) {
            VStack(spacing: 5) {
                ZStack {
                    Circle()
                        .fill(AppTheme.accent)
                        .frame(width: 46, height: 46)
                    Image(systemName: "plus")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)
                }
                Text("New")
                    .font(.rounded(10, .medium))
                    .foregroundColor(AppTheme.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .offset(y: -6)
        }
    }
}
