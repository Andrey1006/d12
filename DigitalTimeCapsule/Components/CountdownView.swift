import SwiftUI

struct CountdownView: View {
    let target: Date
    var numberSize: CGFloat = 28

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { context in
            let remaining = max(0, target.timeIntervalSince(context.date))
            let total = Int(remaining)
            HStack(spacing: 12) {
                segment(total / 86400, "DAYS")
                divider
                segment((total % 86400) / 3600, "HRS")
                divider
                segment((total % 3600) / 60, "MIN")
                divider
                segment(total % 60, "SEC")
            }
        }
    }

    private func segment(_ value: Int, _ label: String) -> some View {
        VStack(spacing: 3) {
            Text(String(format: "%02d", value))
                .font(.system(size: numberSize, weight: .heavy, design: .rounded))
                .foregroundColor(.white)
                .monospacedDigit()
            Text(label)
                .font(.rounded(10, .bold))
                .foregroundColor(.white.opacity(0.75))
        }
    }

    private var divider: some View {
        Text(":")
            .font(.system(size: numberSize * 0.8, weight: .bold, design: .rounded))
            .foregroundColor(.white.opacity(0.5))
            .offset(y: -6)
    }
}
