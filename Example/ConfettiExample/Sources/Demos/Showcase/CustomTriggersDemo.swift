import ConfettiUI
import SwiftUI

// MARK: - CustomTriggersDemo

/// Demonstrates how to create custom trigger UI for confetti.
///
/// Shows various patterns for implementing custom triggers
/// using the `ConfettiScreen` initializer with closure.
struct CustomTriggersDemo: View {
    @State private var selectedTrigger: TriggerOption = .iconButton

    var body: some View {
        VStack(spacing: 0) {
            // Trigger selector
            Picker("Trigger Type", selection: $selectedTrigger) {
                ForEach(TriggerOption.allCases) { trigger in
                    Text(trigger.rawValue).tag(trigger)
                }
            }
            .pickerStyle(.segmented)
            .padding()

            Divider()

            // Code preview
            CodePreviewCard(trigger: selectedTrigger)
                .padding(.horizontal)
                .padding(.top)

            // Confetti view with custom trigger
            selectedTrigger.confettiView
                .id(selectedTrigger)
        }
    }
}

// MARK: - TriggerOption

private enum TriggerOption: String, CaseIterable, Identifiable {
    case iconButton = "Icon"
    case floatingAction = "FAB"
    case tapAnywhere = "Tap"
    case longPress = "Hold"

    var id: String { rawValue }

    @ViewBuilder
    var confettiView: some View {
        switch self {
        case .iconButton:
            IconButtonTriggerDemo()

        case .floatingAction:
            FloatingActionTriggerDemo()

        case .tapAnywhere:
            TapAnywhereTriggerDemo()

        case .longPress:
            LongPressTriggerDemo()
        }
    }

    var codeSnippet: String {
        switch self {
        case .iconButton:
            """
            ConfettiScreen { _, play in
                Button(action: play) {
                    Image(systemName: "sparkles")
                        .font(.title)
                }
            }
            """

        case .floatingAction:
            """
            ConfettiScreen(
                triggerAlignment: .bottomTrailing,
                triggerPadding: .init(...)
            ) { _, play in
                FloatingActionButton(action: play)
            }
            """

        case .tapAnywhere:
            """
            ConfettiScreen { size, play in
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture { play() }
            }
            """

        case .longPress:
            """
            ConfettiScreen { _, play in
                LongPressButton(onTrigger: play)
            }
            """
        }
    }
}

// MARK: - IconButtonTriggerDemo

private struct IconButtonTriggerDemo: View {
    var body: some View {
        ConfettiScreen { _, play in
            Button(action: play) {
                Image(systemName: "sparkles")
                    .font(.largeTitle)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.pink, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .padding(20)
                    .background(
                        Circle()
                            .fill(.ultraThinMaterial)
                    )
                    .accessibilityLabel("Sparkles")
            }
        }
    }
}

// MARK: - FloatingActionTriggerDemo

private struct FloatingActionTriggerDemo: View {
    var body: some View {
        ConfettiScreen(
            triggerAlignment: .bottomTrailing,
            triggerPadding: EdgeInsets(top: 0, leading: 0, bottom: 30, trailing: 30)
        ) { _, play in
            Button(action: play) {
                Image(systemName: "plus")
                    .font(.title2.bold())
                    .foregroundStyle(.white)
                    .frame(width: 56, height: 56)
                    .background(
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                    .shadow(color: .purple.opacity(0.4), radius: 8, y: 4)
                    .accessibilityLabel("Add")
            }
        }
    }
}

// MARK: - TapAnywhereTriggerDemo

private struct TapAnywhereTriggerDemo: View {
    var body: some View {
        ConfettiScreen(
            triggerAlignment: .center,
            triggerPadding: .init()
        ) { _, play in
            ZStack {
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture {
                        play()
                    }
                    .accessibilityAddTraits(.isButton)

                VStack(spacing: 8) {
                    Image(systemName: "hand.tap.fill")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)
                        .accessibilityHidden(true)
                    Text("Tap anywhere")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}

// MARK: - LongPressTriggerDemo

private struct LongPressTriggerDemo: View {
    var body: some View {
        ConfettiScreen { _, play in
            LongPressButton(onTrigger: play)
        }
    }
}

// MARK: - LongPressButton

private struct LongPressButton: View {
    let onTrigger: () -> Void
    @State private var isPressed = false
    @State private var progress: CGFloat = 0

    private let duration: Double = 0.8

    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .stroke(Color.secondary.opacity(0.3), lineWidth: 4)
                    .frame(width: 80, height: 80)

                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        LinearGradient(
                            colors: [.orange, .red],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 4, lineCap: .round)
                    )
                    .frame(width: 80, height: 80)
                    .rotationEffect(.degrees(-90))

                Image(systemName: "hand.point.up.fill")
                    .font(.title)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.orange, .red],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .scaleEffect(isPressed ? 0.9 : 1.0)
                    .accessibilityHidden(true)
            }

            Text("Hold to fire")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Hold to fire confetti")
        .accessibilityAddTraits(.isButton)
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if !isPressed {
                        isPressed = true
                        startProgress()
                    }
                }
                .onEnded { _ in
                    isPressed = false
                    progress = 0
                }
        )
    }

    private func startProgress() {
        withAnimation(.linear(duration: duration)) {
            progress = 1
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            if isPressed {
                onTrigger()
                isPressed = false
                progress = 0
            }
        }
    }
}

// MARK: - CodePreviewCard

private struct CodePreviewCard: View {
    let trigger: TriggerOption

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "chevron.left.forwardslash.chevron.right")
                    .foregroundStyle(.secondary)
                    .accessibilityHidden(true)
                Text("Code")
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
                Spacer()
            }

            Text(trigger.codeSnippet)
                .font(.system(.caption, design: .monospaced))
                .foregroundStyle(.primary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.secondary.opacity(0.1))
        )
    }
}

#Preview {
    CustomTriggersDemo()
}
