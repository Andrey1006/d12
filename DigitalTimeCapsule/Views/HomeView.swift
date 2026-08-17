import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: LettersViewModel
    var onCreate: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            if viewModel.letters.isEmpty {
                emptyState
            } else {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        heroCarousel

                        VStack(spacing: 14) {
                            SectionHeader(title: "Ready to Open")
                            horizontalRow
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.top, 16)
                    .padding(.bottom, 16)
                }
            }

            nextCapsuleCard
                .padding(.horizontal, 20)
                .padding(.bottom, AppTheme.tabBarHeight + 12)
        }
        .background(AppTheme.background.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Novaline Core")
                    .font(.rounded(18, .bold))
                    .foregroundColor(AppTheme.textPrimary)
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "envelope.open")
                .font(.system(size: 52, weight: .light))
                .foregroundColor(AppTheme.accent)
            Text("No capsules yet")
                .font(.rounded(20, .bold))
                .foregroundColor(AppTheme.textPrimary)
            Text("Write your first letter to the future and seal it until a date you choose.")
                .font(.rounded(15, .regular))
                .foregroundColor(AppTheme.textSecondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 40)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var heroCarousel: some View {
        TabView {
            ForEach(viewModel.featured) { letter in
                NavigationLink(value: letter) {
                    HeroCard(letter: letter)
                        .padding(.horizontal, 20)
                }
                .buttonStyle(.plain)
            }
        }
        .frame(height: 210)
        .tabViewStyle(.page(indexDisplayMode: .always))
        .indexViewStyle(.page(backgroundDisplayMode: .always))
    }

    private var horizontalRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 14) {
                ForEach(displayRow) { letter in
                    NavigationLink(value: letter) {
                        LetterCard(letter: letter, width: 150)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var displayRow: [Letter] {
        let source = viewModel.ready.isEmpty ? viewModel.sealed : viewModel.ready
        return Array(source.prefix(6))
    }

    private var nextCapsuleCard: some View {
        VStack(spacing: 14) {
            HStack(spacing: 14) {
                Image(systemName: "gift.fill")
                    .font(.system(size: 26))
                    .foregroundColor(AppTheme.accent)

                VStack(alignment: .leading, spacing: 4) {
                    Text("SEAL A NEW LETTER")
                        .font(.rounded(12, .heavy))
                        .foregroundColor(AppTheme.textPrimary)
                    Text("Write to your future self and lock it until a chosen date.")
                        .font(.rounded(12, .regular))
                        .foregroundColor(AppTheme.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 0)
            }

            PrimaryButton(title: "Create Letter", action: onCreate)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cornerLarge, style: .continuous)
                .fill(AppTheme.surface)
        )
    }
}

private struct HeroCard: View {
    let letter: Letter

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: AppTheme.cornerLarge, style: .continuous)
                .fill(letter.accent.gradient)
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.cornerLarge, style: .continuous)
                        .stroke(AppTheme.cardStroke, lineWidth: 1)
                )

            VStack(alignment: .leading, spacing: 6) {
                Text(letter.isSealed ? "SEALED" : "READY TO OPEN")
                    .font(.rounded(12, .heavy))
                    .foregroundColor(.white.opacity(0.9))

                Text(letter.isSealed ? "\(letter.daysRemaining)" : "OPEN")
                    .font(.system(size: 56, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)

                Text(letter.isSealed ? "days until \(letter.unlockDateText)" : "Unlocked \(letter.unlockDateText)")
                    .font(.rounded(14, .medium))
                    .foregroundColor(.white.opacity(0.85))

                Text(letter.title)
                    .font(.rounded(15, .semibold))
                    .foregroundColor(.white)
            }
            .padding(20)
        }
        .frame(height: 190)
    }
}
