import SwiftUI

// MARK: - DemoListRow

/// A styled list row component for displaying demo navigation items.
///
/// `DemoListRow` provides a consistent, visually appealing row layout with:
/// - A gradient-backed icon on the left
/// - Title and subtitle text on the right
///
/// ## Example Usage
///
/// ```swift
/// DemoListRow(
///     title: "Observation Demo",
///     subtitle: "Tap to trigger confetti",
///     systemImage: "sparkles",
///     colors: [.pink, .purple]
/// )
/// ```
struct DemoListRow: View {
    // MARK: - Properties

    /// The primary title text displayed in the row.
    let title: String

    /// The secondary descriptive text displayed below the title.
    let subtitle: String

    /// The SF Symbol name used for the row's icon.
    let systemImage: String

    /// The gradient colors applied to the icon's background.
    let colors: [Color]

    // MARK: - Body

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: systemImage)
                .accessibility(hidden: true)
                .font(.title)
                .foregroundColor(.white)
                .frame(width: 50, height: 50)
                .background(
                    LinearGradient(
                        colors: colors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(.rect(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
}

#Preview {
    Button {} label: {
        HStack {
            DemoListRow(
                title: "Simple View",
                subtitle: "Tap to trigger confetti",
                systemImage: "sparkles",
                colors: [.pink, .purple]
            )
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
        .padding(16)
    }
}
