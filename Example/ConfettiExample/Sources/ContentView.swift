import SwiftUI

// MARK: - ContentView

/// The main content view with tabbed navigation.
///
/// Provides three main sections:
/// - **Platform**: Integration with various rendering technologies
/// - **Basic**: Fundamental usage patterns from the README
/// - **Advanced**: Advanced customization and interactive demos
struct ContentView: View {
    var body: some View {
        TabView {
            Tab("Platform", systemImage: "cpu") {
                PlatformIntegrationTab()
            }
            Tab("Basic", systemImage: "sparkle") {
                BasicUsageTab()
            }
            Tab("Advanced", systemImage: "wand.and.stars") {
                AdvancedUsageTab()
            }
        }
    }
}

#Preview {
    ContentView()
}
