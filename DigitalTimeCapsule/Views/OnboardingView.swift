import SwiftUI

struct OnboardingSlide: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let subtitle: String
    let accent: LetterAccent
}

struct OnboardingView: View {
    var onFinish: () -> Void

    @State private var page = 0

    private let slides = [
        OnboardingSlide(icon: "envelope.fill",
                        title: "Write to the future",
                        subtitle: "Leave a message for your future self or a friend, with a photo if you like.",
                        accent: .amber),
        OnboardingSlide(icon: "lock.fill",
                        title: "Seal it in time",
                        subtitle: "Choose an unlock date. The letter stays sealed and cannot be opened until then.",
                        accent: .violet),
        OnboardingSlide(icon: "sparkles",
                        title: "Open when the day comes",
                        subtitle: "We remind you the moment it unlocks. Relive who you were back then.",
                        accent: .teal)
    ]

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                TabView(selection: $page) {
                    ForEach(Array(slides.enumerated()), id: \.element.id) { index, slide in
                        slideView(slide)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .indexViewStyle(.page(backgroundDisplayMode: .always))

                VStack(spacing: 14) {
                    PrimaryButton(title: page == slides.count - 1 ? "Get Started" : "Next") {
                        if page < slides.count - 1 {
                            withAnimation { page += 1 }
                        } else {
                            Haptics.success()
                            onFinish()
                        }
                    }

                    Button("Skip") {
                        onFinish()
                    }
                    .font(.rounded(15, .medium))
                    .foregroundColor(AppTheme.textSecondary)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
    }

    private func slideView(_ slide: OnboardingSlide) -> some View {
        VStack(spacing: 28) {
            ZStack {
                Circle()
                    .fill(slide.accent.gradient)
                    .frame(width: 150, height: 150)
                Image(systemName: slide.icon)
                    .font(.system(size: 62, weight: .bold))
                    .foregroundColor(.white)
            }

            VStack(spacing: 14) {
                Text(slide.title)
                    .font(.rounded(28, .heavy))
                    .foregroundColor(AppTheme.textPrimary)
                    .multilineTextAlignment(.center)

                Text(slide.subtitle)
                    .font(.rounded(16, .regular))
                    .foregroundColor(AppTheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
        }
        .padding(.bottom, 40)
    }
}
