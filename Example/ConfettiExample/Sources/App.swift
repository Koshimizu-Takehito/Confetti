import SwiftUI

// MARK: - App

/// The main entry point of the ConfettiExample application.
///
/// This app demonstrates various integration patterns for using the Confetti library
/// in a SwiftUI application, including:
/// - Using Swift's `@Observable` macro (iOS 17+)
/// - Using `ObservableObject` protocol for backward compatibility
/// - Direct usage of built-in `ConfettiScreen` and `ConfettiPlayerScreen`
@main
struct App: SwiftUI.App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

#Preview {
    ContentView()
}
