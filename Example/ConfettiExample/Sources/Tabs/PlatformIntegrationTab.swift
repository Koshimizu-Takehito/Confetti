import SwiftUI

// MARK: - PlatformIntegrationTab

/// A tab displaying platform integration demonstrations.
///
/// This view serves as the navigation hub for exploring different integration patterns
/// with various rendering technologies:
///
/// - **SwiftUI Integration**: State management patterns (@Observable and ObservableObject)
/// - **Platform Native**: Core Graphics drawing (UIKit/AppKit)
/// - **SpriteKit**: Scene graph based sprite rendering
/// - **Metal**: Custom Metal shaders with instanced drawing
struct PlatformIntegrationTab: View {
    var body: some View {
        // swiftlint:disable closure_body_length
        NavigationStack {
            List {
                Section("SwiftUI Integration") {
                    NavigationLink {
                        ObservationDemoView()
                            .navigationTitle("Observation")
                    } label: {
                        DemoListRow(
                            title: "@Observable",
                            subtitle: "Modern macro-based observation",
                            systemImage: "eye",
                            colors: [.pink, .purple]
                        )
                    }
                    NavigationLink {
                        ObservableObjectDemoView()
                            .navigationTitle("ObservableObject")
                    } label: {
                        DemoListRow(
                            title: "ObservableObject",
                            subtitle: "Combine-based observation",
                            systemImage: "arrow.triangle.2.circlepath",
                            colors: [.orange, .red]
                        )
                    }
                }
                Section(NativeDemoView.sectionTitle) {
                    NavigationLink {
                        NativeDemoView()
                            .navigationTitle(NativeDemoView.navigationTitle)
                    } label: {
                        DemoListRow(
                            title: NativeDemoView.rowTitle,
                            subtitle: NativeDemoView.rowSubtitle,
                            systemImage: "paintbrush.pointed.fill",
                            colors: [.blue, .cyan]
                        )
                    }
                }
                Section("SpriteKit Integration") {
                    NavigationLink {
                        SpriteKitDemoView()
                            .navigationTitle("SpriteKit Demo")
                    } label: {
                        DemoListRow(
                            title: "SpriteKit Demo",
                            subtitle: "ConfettiPlayer with SKScene",
                            systemImage: "gamecontroller.fill",
                            colors: [.purple, .indigo]
                        )
                    }
                }
                Section("Metal Integration") {
                    NavigationLink {
                        MetalDemoView()
                            .navigationTitle("Metal Demo")
                    } label: {
                        DemoListRow(
                            title: "Metal Demo",
                            subtitle: "MTKView with instanced rendering",
                            systemImage: "cpu.fill",
                            colors: [.yellow, .orange]
                        )
                    }
                    NavigationLink {
                        ShaderEffectDemoView()
                            .navigationTitle("ShaderEffect Demo")
                    } label: {
                        DemoListRow(
                            title: "ShaderEffect Demo",
                            subtitle: "SwiftUI layerEffect with Metal",
                            systemImage: "wand.and.stars",
                            colors: [.cyan, .blue]
                        )
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Platform")
                        .font(.title2.bold())
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                }
            }
            #if os(iOS) || os(visionOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
        }
        // swiftlint:enable closure_body_length
    }
}

#Preview {
    PlatformIntegrationTab()
}
