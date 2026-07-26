import SwiftUI

struct LetterCard: View {
    let letter: Letter
    var width: CGFloat = 160

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack(alignment: .topTrailing) {
                RoundedRectangle(cornerRadius: AppTheme.cornerMedium, style: .continuous)
                    .fill(letter.accent.gradient)
                    .frame(width: width, height: width * 0.92)
                    .overlay(
                        Image(systemName: letter.isSealed ? "lock.fill" : "envelope.open.fill")
                            .font(.system(size: 30, weight: .bold))
                            .foregroundColor(.white.opacity(0.85))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.cornerMedium, style: .continuous)
                            .stroke(AppTheme.cardStroke, lineWidth: 1)
                    )

                badge
                    .padding(8)

                if letter.isFavorite {
                    Image(systemName: "star.fill")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.yellow)
                        .padding(6)
                        .background(Circle().fill(Color.black.opacity(0.4)))
                        .padding(8)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                }

                if letter.hasPhoto {
                    Image(systemName: "photo.fill")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white)
                        .padding(6)
                        .background(Circle().fill(Color.black.opacity(0.4)))
                        .padding(8)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                }
            }

            Text(letter.title)
                .font(.rounded(14, .semibold))
                .foregroundColor(AppTheme.textPrimary)
                .lineLimit(1)

            HStack(spacing: 5) {
                Image(systemName: letter.category.icon)
                    .font(.system(size: 11, weight: .semibold))
                Text(letter.isSealed ? "\(letter.daysRemaining)d left" : "Ready")
                    .font(.rounded(12, .medium))
            }
            .foregroundColor(AppTheme.textSecondary)
        }
        .frame(width: width, alignment: .leading)
    }

    private var badge: some View {
        Text(letter.isSealed ? "SEALED" : "OPEN")
            .font(.rounded(10, .heavy))
            .foregroundColor(.black)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Capsule().fill(letter.isSealed ? AppTheme.seal : AppTheme.accent)
            )
    }
}
