import SwiftUI

// MARK: - DemoTriggerButton

/// A stylized capsule-shaped button for triggering confetti animations.
///
/// `DemoTriggerButton` provides a visually appealing trigger mechanism with:
/// - Customizable gradient background colors
/// - Capsule shape with subtle shadow
/// - Consistent "Confetti!" label
///
/// ## Example Usage
///
/// ```swift
/// DemoTriggerButton(.pink, .purple) {
///     viewModel.fire()
/// }
/// ```
struct DemoTriggerButton: View {
    // MARK: - Properties

    /// The gradient colors applied to the button's background.
    var colors: [Color]

    /// The closure executed when the button is tapped.
    var action: () -> Void

    init(_ colors: Color..., action: @escaping () -> Void) {
        self.colors = colors
        self.action = action
    }

    init(colors: [Color], action: @escaping () -> Void) {
        self.colors = colors
        self.action = action
    }

    // MARK: - Body

    var body: some View {
        Button(action: action) {
            Text("Confetti!")
                .padding(.horizontal, 40)
                .padding(.vertical, 16)
                .background {
                    LinearGradient(
                        colors: colors,
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                }
                .clipShape(.capsule)
                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                .contentShape(.capsule)
        }
        .font(.headline.bold())
        .foregroundStyle(.white)
    }
}
