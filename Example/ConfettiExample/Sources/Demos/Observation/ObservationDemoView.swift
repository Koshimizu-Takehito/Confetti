import ConfettiPlayback
import SwiftUI

// MARK: - ObservationDemoView

/// A demonstration view showcasing confetti integration using Swift's `@Observable` macro.
///
/// This view demonstrates the recommended integration pattern for iOS 17+ projects,
/// leveraging Swift's native observation system for automatic UI updates.
///
/// ## Overview
///
/// The view uses `@State` to hold an `@Observable` view model, which wraps
/// ``ConfettiPlayer`` and exposes render states that automatically trigger
/// SwiftUI view updates when particles move or change.
///
/// ## Key Features
///
/// - **Automatic observation**: No manual subscription or Combine required
/// - **Efficient updates**: Only re-renders when `renderStates` changes
/// - **Canvas-based rendering**: Uses SwiftUI's `Canvas` for high-performance drawing
///
/// ## Example Usage
///
/// ```swift
/// NavigationLink {
///     ObservationDemoView()
/// } label: {
///     Text("Observation Demo")
/// }
/// ```
///
/// - SeeAlso: ``ObservationDemoViewModel``
/// - SeeAlso: ``ObservableObjectDemoView`` for backward-compatible alternative
struct ObservationDemoView: View {
    // MARK: - Properties

    /// The view model managing confetti playback state using `@Observable`.
    @State private var viewModel = ObservationDemoViewModel()

    // MARK: - Body

    var body: some View {
        Canvas { context, _ in
            for state in viewModel.renderStates {
                context.opacity = state.opacity
                context.fill(Path(state: state), with: .color(Color(cgColor: state.color)))
            }
        }
        .overlay(alignment: .bottom) {
            DemoTriggerButton(.pink, .purple) {
                viewModel.fire()
            }
            .padding(.bottom)
        }
        .onGeometryChange(for: CGSize.self, of: \.size) { _, size in
            viewModel.canvasSize = size
        }
        .onDisappear {
            viewModel.stop()
        }
    }
}

// MARK: - Previews

#Preview {
    ObservationDemoView()
}
