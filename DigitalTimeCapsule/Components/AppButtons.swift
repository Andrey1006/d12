import SwiftUI

struct PrimaryButton: View {
    let title: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.rounded(17, .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: AppTheme.cornerMedium, style: .continuous)
                        .fill(AppTheme.accent)
                )
        }
    }
}

struct OutlineButton: View {
    let title: String
    var destructive: Bool = false
    var enabled: Bool = true
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.rounded(15, .semibold))
                .foregroundColor(foreground)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 15)
                .background(
                    RoundedRectangle(cornerRadius: AppTheme.cornerMedium, style: .continuous)
                        .stroke(border, lineWidth: 1.2)
                )
        }
        .disabled(!enabled)
    }

    private var foreground: Color {
        if !enabled { return AppTheme.textSecondary.opacity(0.5) }
        return destructive ? Color(red: 0.95, green: 0.4, blue: 0.4) : AppTheme.textPrimary
    }

    private var border: Color {
        if !enabled { return AppTheme.cardStroke }
        return destructive ? Color(red: 0.95, green: 0.4, blue: 0.4).opacity(0.6) : Color.white.opacity(0.18)
    }
}
