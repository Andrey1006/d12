import SwiftUI

struct SectionHeader: View {
    let title: String
    var trailing: String = "All"

    var body: some View {
        HStack {
            Text(title)
                .font(.rounded(20, .bold))
                .foregroundColor(AppTheme.textPrimary)
            Spacer()
            HStack(spacing: 3) {
                Text(trailing)
                    .font(.rounded(14, .medium))
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
            }
            .foregroundColor(AppTheme.textSecondary)
        }
    }
}
