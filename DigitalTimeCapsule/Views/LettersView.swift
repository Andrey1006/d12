import SwiftUI

enum LetterFilter: String, CaseIterable, Identifiable {
    case all = "All"
    case sealed = "Sealed"
    case opened = "Opened"
    case favorites = "Favorites"

    var id: String { rawValue }
}

struct LettersView: View {
    @ObservedObject var viewModel: LettersViewModel

    @State private var filter: LetterFilter = .all
    @State private var selectedCategory: LetterCategory?
    @State private var query = ""

    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                Text("My Letters")
                    .font(.rounded(26, .heavy))
                    .foregroundColor(AppTheme.textPrimary)

                searchField

                statusFilter

                categoryFilter

                if filteredLetters.isEmpty {
                    emptyState
                } else {
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(filteredLetters) { letter in
                            NavigationLink(value: letter) {
                                LetterCard(letter: letter, width: gridItemWidth)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.top, 4)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, AppTheme.tabBarHeight + 20)
        }
        .background(AppTheme.background.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
    }

    private var searchField: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(AppTheme.textSecondary)
            TextField("", text: $query, prompt: Text("Search letters").foregroundColor(AppTheme.textSecondary))
                .font(.rounded(15, .regular))
                .foregroundColor(AppTheme.textPrimary)
            if !query.isEmpty {
                Button {
                    query = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(AppTheme.textSecondary)
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cornerMedium, style: .continuous)
                .fill(AppTheme.surface)
        )
    }

    private var statusFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(LetterFilter.allCases) { item in
                    Button {
                        filter = item
                        Haptics.selection()
                    } label: {
                        Text(item.rawValue)
                            .font(.rounded(14, .semibold))
                            .foregroundColor(filter == item ? .white : AppTheme.textSecondary)
                            .padding(.horizontal, 18)
                            .padding(.vertical, 9)
                            .background(
                                Capsule().fill(filter == item ? AppTheme.accent : AppTheme.surface)
                            )
                    }
                }
            }
        }
    }

    private var categoryFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                categoryChip(title: "All", icon: "square.grid.2x2.fill", isSelected: selectedCategory == nil) {
                    selectedCategory = nil
                }
                ForEach(LetterCategory.allCases) { option in
                    categoryChip(title: option.title, icon: option.icon, isSelected: selectedCategory == option) {
                        selectedCategory = option
                    }
                }
            }
        }
    }

    private func categoryChip(title: String, icon: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button {
            action()
            Haptics.selection()
        } label: {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .semibold))
                Text(title)
                    .font(.rounded(13, .semibold))
            }
            .foregroundColor(isSelected ? AppTheme.accent : AppTheme.textSecondary)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .stroke(isSelected ? AppTheme.accent : Color.white.opacity(0.12), lineWidth: 1.2)
            )
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "tray")
                .font(.system(size: 40, weight: .light))
                .foregroundColor(AppTheme.textSecondary)
            Text("Nothing here yet")
                .font(.rounded(17, .semibold))
                .foregroundColor(AppTheme.textPrimary)
            Text("Try a different filter or seal a new letter.")
                .font(.rounded(14, .regular))
                .foregroundColor(AppTheme.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 50)
    }

    private var filteredLetters: [Letter] {
        var base: [Letter]
        switch filter {
        case .all: base = viewModel.letters
        case .sealed: base = viewModel.letters.filter { $0.isSealed }
        case .opened: base = viewModel.letters.filter { $0.isOpened }
        case .favorites: base = viewModel.letters.filter { $0.isFavorite }
        }

        if let selectedCategory {
            base = base.filter { $0.category == selectedCategory }
        }

        let trimmed = query.trimmingCharacters(in: .whitespaces).lowercased()
        guard !trimmed.isEmpty else { return base }
        return base.filter {
            $0.title.lowercased().contains(trimmed) ||
            $0.recipient.lowercased().contains(trimmed) ||
            $0.message.lowercased().contains(trimmed)
        }
    }

    private var gridItemWidth: CGFloat {
        (UIScreen.main.bounds.width - 40 - 16) / 2
    }
}
