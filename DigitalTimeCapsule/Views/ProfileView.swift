import SwiftUI

struct ProfileView: View {
    @ObservedObject var viewModel: LettersViewModel

    private let columns = [
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14)
    ]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                header

                nextUnlockCard

                LazyVGrid(columns: columns, spacing: 14) {
                    StatTile(icon: "tray.full.fill", value: "\(viewModel.totalCount)", label: "Total letters", tint: AppTheme.accent)
                    StatTile(icon: "lock.fill", value: "\(viewModel.sealedCount)", label: "Sealed", tint: AppTheme.seal)
                    StatTile(icon: "envelope.open.fill", value: "\(viewModel.openedCount)", label: "Opened", tint: AppTheme.accentSoft)
                    StatTile(icon: "bell.badge.fill", value: "\(viewModel.readyCount)", label: "Ready now", tint: AppTheme.accent)
                }

                waitCard
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, AppTheme.tabBarHeight + 20)
        }
        .background(AppTheme.background.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(LetterAccent.amber.gradient)
                    .frame(width: 60, height: 60)
                Image(systemName: "person.fill")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(.white)
            }
            VStack(alignment: .leading, spacing: 3) {
                Text("Your Capsule")
                    .font(.rounded(24, .heavy))
                    .foregroundColor(AppTheme.textPrimary)
                Text("Messages across time")
                    .font(.rounded(14, .regular))
                    .foregroundColor(AppTheme.textSecondary)
            }
            Spacer()
        }
    }

    @ViewBuilder
    private var nextUnlockCard: some View {
        if let next = viewModel.nextUnlock {
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: AppTheme.cornerLarge, style: .continuous)
                    .fill(next.accent.gradient)

                VStack(alignment: .leading, spacing: 12) {
                    Text("NEXT TO UNLOCK")
                        .font(.rounded(12, .heavy))
                        .foregroundColor(.white.opacity(0.9))
                    CountdownView(target: next.unlockAt, numberSize: 24)
                    Text("\"\(next.title)\"")
                        .font(.rounded(14, .semibold))
                        .foregroundColor(.white.opacity(0.9))
                        .lineLimit(1)
                }
                .padding(20)
            }
            .frame(height: 160)
        } else {
            infoCard(text: "No sealed letters yet. Seal one to start the countdown.")
        }
    }

    private var waitCard: some View {
        HStack(spacing: 14) {
            Image(systemName: "hourglass")
                .font(.system(size: 24))
                .foregroundColor(AppTheme.accent)
            VStack(alignment: .leading, spacing: 3) {
                Text("Longest wait")
                    .font(.rounded(13, .medium))
                    .foregroundColor(AppTheme.textSecondary)
                Text("\(viewModel.longestWaitDays) days")
                    .font(.rounded(20, .bold))
                    .foregroundColor(AppTheme.textPrimary)
            }
            Spacer()
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cornerLarge, style: .continuous)
                .fill(AppTheme.surface)
        )
    }

    private func infoCard(text: String) -> some View {
        Text(text)
            .font(.rounded(15, .medium))
            .foregroundColor(AppTheme.textSecondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.cornerLarge, style: .continuous)
                    .fill(AppTheme.surface)
            )
    }
}

private struct StatTile: View {
    let icon: String
    let value: String
    let label: String
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(tint)
            Text(value)
                .font(.rounded(30, .heavy))
                .foregroundColor(AppTheme.textPrimary)
            Text(label)
                .font(.rounded(13, .medium))
                .foregroundColor(AppTheme.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cornerLarge, style: .continuous)
                .fill(AppTheme.surface)
        )
    }
}
