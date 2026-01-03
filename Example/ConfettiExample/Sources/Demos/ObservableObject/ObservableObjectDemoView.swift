import ConfettiPlayback
import SwiftUI

// MARK: - ObservableObjectDemoView

/// A demonstration view showcasing confetti integration using `ObservableObject` protocol.
///
/// This view demonstrates a backward-compatible integration pattern suitable for
/// projects targeting iOS versions prior to iOS 17, or for codebases already using
/// Combine-based architectures.
///
/// ## Overview
///
/// The view uses `@StateObject` to hold an `ObservableObject` view model, which
/// bridges the `@Observable` player's render states to `@Published` properties
/// using manual observation tracking.
///
/// ## Key Features
///
/// - **Backward compatible**: Works with iOS 16+ using `@StateObject`
/// - **Combine integration**: Uses `@Published` for state propagation
/// - **Manual bridging**: Demonstrates `withObservationTracking` for bridging patterns
///
/// ## Example Usage
///
/// ```swift
/// NavigationLink {
///     ObservableObjectDemoView()
/// } label: {
///     Text("ObservableObject Demo")
/// }
/// ```
///
/// - SeeAlso: ``ObservableObjectDemoViewModel``
/// - SeeAlso: ``ObservationDemoView`` for modern iOS 17+ alternative
struct ObservableObjectDemoView: View {
    // MARK: - Properties

    /// The view model managing confetti playback state using `ObservableObject`.
    @StateObject private var viewModel = ObservableObjectDemoViewModel()

    // MARK: - Body

    var body: some View {
        Canvas { context, _ in
            for state in viewModel.renderStates {
                context.opacity = state.opacity
                context.fill(Path(state: state), with: .color(Color(cgColor: state.color)))
            }
        }
        .overlay(alignment: .bottom) {
            DemoTriggerButton(.orange, .red) {
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

#Preview {
    ObservableObjectDemoView()
}
