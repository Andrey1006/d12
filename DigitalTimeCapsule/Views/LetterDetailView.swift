import SwiftUI

struct LetterDetailView: View {
    @ObservedObject var viewModel: LettersViewModel
    let letterID: UUID

    @Environment(\.dismiss) private var dismiss

    @State private var showingEdit = false
    @State private var showingDeleteConfirm = false
    @State private var showConfetti = false

    var body: some View {
        if let letter = viewModel.letter(with: letterID) {
            content(for: letter)
        } else {
            Text("Letter not found")
                .foregroundColor(AppTheme.textSecondary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(AppTheme.background.ignoresSafeArea())
        }
    }

    private func content(for letter: Letter) -> some View {
        ZStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 22) {
                    banner(for: letter)

                    VStack(alignment: .leading, spacing: 8) {
                        Text(letter.isSealed ? "This letter is sealed" : "Ready to open")
                            .font(.rounded(22, .bold))
                            .foregroundColor(AppTheme.textPrimary)

                        Text(letter.isSealed
                             ? "It will unlock on \(letter.unlockDateText)."
                             : "The wait is over. You can open this letter now.")
                            .font(.rounded(15, .regular))
                            .foregroundColor(AppTheme.textSecondary)
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        HStack(spacing: 10) {
                            Text("To \(letter.recipient)")
                                .font(.rounded(18, .bold))
                                .foregroundColor(AppTheme.textPrimary)
                            categoryTag(letter.category)
                        }

                        Text(revealText(for: letter))
                            .font(.rounded(15, .regular))
                            .foregroundColor(letter.isOpened ? AppTheme.textPrimary : AppTheme.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                            .animation(.easeInOut, value: letter.isOpened)

                        if letter.isOpened, let data = letter.photoData, let uiImage = UIImage(data: data) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(maxWidth: .infinity)
                                .frame(height: 220)
                                .clipped()
                                .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerMedium, style: .continuous))
                                .padding(.top, 6)
                                .transition(.opacity.combined(with: .scale(scale: 0.96)))
                        } else if letter.hasPhoto && letter.isSealed {
                            HStack(spacing: 8) {
                                Image(systemName: "photo.fill")
                                Text("A photo is sealed inside this letter.")
                            }
                            .font(.rounded(13, .medium))
                            .foregroundColor(AppTheme.textSecondary)
                            .padding(.top, 4)
                        }
                    }

                    VStack(spacing: 12) {
                        OutlineButton(title: letter.isSealed ? "Locked" : "Open Letter",
                                      enabled: !letter.isSealed) {
                            openLetter(letter)
                        }
                        if letter.isSealed {
                            OutlineButton(title: "Edit Letter") {
                                showingEdit = true
                            }
                        }
                        OutlineButton(title: "Delete Letter", destructive: true) {
                            showingDeleteConfirm = true
                        }
                    }
                }
                .padding(20)
                .padding(.bottom, 40)
            }

            if showConfetti {
                ConfettiView()
                    .ignoresSafeArea()
                    .transition(.opacity)
            }
        }
        .background(AppTheme.background.ignoresSafeArea())
        .navigationTitle("Capsule")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    viewModel.toggleFavorite(letter)
                    Haptics.impact(.light)
                } label: {
                    Image(systemName: letter.isFavorite ? "star.fill" : "star")
                        .foregroundColor(letter.isFavorite ? .yellow : AppTheme.textSecondary)
                }
            }
        }
        .sheet(isPresented: $showingEdit) {
            CreateLetterView(viewModel: viewModel, editing: letter)
        }
        .confirmationDialog("Delete this letter?",
                            isPresented: $showingDeleteConfirm,
                            titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                viewModel.delete(letter)
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This action cannot be undone.")
        }
    }

    private func banner(for letter: Letter) -> some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: AppTheme.cornerLarge, style: .continuous)
                .fill(letter.accent.gradient)

            VStack(alignment: .leading, spacing: 12) {
                Text(letter.isSealed ? "SEALED CAPSULE" : "UNLOCKED")
                    .font(.rounded(13, .heavy))
                    .foregroundColor(.white.opacity(0.9))

                if letter.isSealed {
                    CountdownView(target: letter.unlockAt)
                } else {
                    HStack(spacing: 10) {
                        Image(systemName: "lock.open.fill")
                            .font(.system(size: 30, weight: .bold))
                        Text("Open now")
                            .font(.rounded(28, .heavy))
                    }
                    .foregroundColor(.white)
                }
            }
            .padding(22)
        }
        .frame(height: 170)
    }

    private func categoryTag(_ category: LetterCategory) -> some View {
        HStack(spacing: 5) {
            Image(systemName: category.icon)
                .font(.system(size: 11, weight: .semibold))
            Text(category.title)
                .font(.rounded(12, .semibold))
        }
        .foregroundColor(AppTheme.accent)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(Capsule().fill(AppTheme.accent.opacity(0.15)))
    }

    private func openLetter(_ letter: Letter) {
        Haptics.success()
        withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
            viewModel.open(letter)
            showConfetti = true
        }
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 2_600_000_000)
            withAnimation { showConfetti = false }
        }
    }

    private func revealText(for letter: Letter) -> String {
        if letter.isSealed {
            return "The content stays hidden until the unlock date."
        }
        if letter.isOpened {
            return letter.message
        }
        return "Tap Open Letter to reveal the message."
    }
}
