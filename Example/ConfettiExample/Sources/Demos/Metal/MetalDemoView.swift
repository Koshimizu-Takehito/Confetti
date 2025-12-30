import ConfettiPlayback
import SwiftUI

// MARK: - MetalDemoView

/// A demonstration view showcasing confetti rendering using Metal.
///
/// This view demonstrates custom Metal shader based particle rendering,
/// providing higher performance compared to Canvas-based rendering.
///
/// ## Overview
///
/// The view uses `MetalConfettiView` to render particles using
/// instanced drawing with custom Metal shaders. This demonstrates how to
/// implement custom Metal-based rendering with `ConfettiPlayer`.
///
/// ## Key Features
///
/// - **Metal shaders**: Particles rendered using custom vertex/fragment shaders
/// - **Instanced rendering**: Efficient batch rendering of all particles
/// - **Alpha blending**: Smooth transparency effects
///
/// ## Example Usage
///
/// ```swift
/// NavigationLink {
///     MetalDemoView()
/// } label: {
///     Text("Metal Demo")
/// }
/// ```
struct MetalDemoView: View {
    // MARK: - Properties

    /// The view model managing confetti playback state.
    @State private var viewModel = MetalDemoViewModel()

    // MARK: - Body

    var body: some View {
        MetalConfettiView(renderStates: viewModel.renderStates)
            .overlay(alignment: .bottom) {
                DemoTriggerButton(.yellow, .orange) {
                    viewModel.fire()
                }
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 50, trailing: 0))
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
    MetalDemoView()
}
