import SwiftUI

// MARK: - PlaybackControls

/// A control bar for confetti playback with play/pause/stop buttons and time slider.
struct PlaybackControls: View {
    // MARK: - Properties

    @Bindable var player: ConfettiPlayer
    let canvasSize: CGSize

    // MARK: - Environment

    @Environment(\.confettiDesignTokens) private var tokens

    // MARK: - Private State

    @State private var displayTime: TimeInterval = 0
    @State private var wasPlayingBeforeSeek = false

    // MARK: - Body

    var body: some View {
        VStack(spacing: tokens.spacing.medium) {
            TimeSlider(
                currentTime: $displayTime.animation(),
                duration: player.duration,
                onSeek: { player.seek(to: $0) },
                onDragStart: handleSeekStart,
                onDragEnd: handleSeekEnd
            )

            HStack(spacing: tokens.spacing.large) {
                // Stop button
                controlButton(
                    systemName: "stop.fill",
                    action: { player.stop() },
                    isEnabled: player.isRunning,
                    accessibilityLabel: "Stop"
                )

                // Play/Pause button
                playPauseButton

                // Replay button (visible when stopped after completion)
                controlButton(
                    systemName: "arrow.counterclockwise",
                    action: { player.play(canvasSize: canvasSize) },
                    isEnabled: !player.isRunning,
                    accessibilityLabel: "Replay"
                )
            }
        }
        .padding(.horizontal, tokens.spacing.large)
        .padding(.vertical, tokens.spacing.medium)
        .background(controlsBackground)
        .onAppear {
            displayTime = player.currentTime
        }
        .onChange(of: player.currentTime) { _, newTime in
            displayTime = newTime
        }
    }

    // MARK: - Private Views

    @ViewBuilder
    private var playPauseButton: some View {
        if !player.isRunning {
            // Not started - show play button
            controlButton(
                systemName: "play.fill",
                action: { player.play(canvasSize: canvasSize) },
                isEnabled: true,
                isPrimary: true,
                accessibilityLabel: "Play"
            )
        } else if player.isPaused {
            // Paused - show resume button
            controlButton(
                systemName: "play.fill",
                action: player.resume,
                isEnabled: true,
                isPrimary: true,
                accessibilityLabel: "Resume"
            )
        } else {
            // Playing - show pause button
            controlButton(
                systemName: "pause.fill",
                action: player.pause,
                isEnabled: true,
                isPrimary: true,
                accessibilityLabel: "Pause"
            )
        }
    }

    // MARK: - Private Methods

    private func handleSeekStart() {
        // Pause playback during seek if currently playing
        wasPlayingBeforeSeek = player.isRunning && !player.isPaused
        if wasPlayingBeforeSeek {
            player.pause()
        }
    }

    private func handleSeekEnd() {
        // Resume playback after seek if was playing before
        if wasPlayingBeforeSeek {
            player.resume()
            wasPlayingBeforeSeek = false
        }
    }

    @ViewBuilder
    private var controlsBackground: some View {
        if #available(iOS 26.0, macOS 26.0, visionOS 26.0, tvOS 26.0, watchOS 26.0, *) {
            Color.clear
                .glassEffect(.clear, in: .rect(cornerRadius: tokens.cornerRadius.large))
                .shadow(
                    color: .black.opacity(tokens.opacity.shadowLight),
                    radius: tokens.shadow.controlsRadius, x: 0, y: 4
                )
        } else {
            RoundedRectangle(cornerRadius: tokens.cornerRadius.large)
                .fill(.ultraThinMaterial)
                .shadow(
                    color: .black.opacity(tokens.opacity.shadowLight),
                    radius: tokens.shadow.controlsRadius, x: 0, y: 4
                )
        }
    }

    private func controlButton(
        systemName: String,
        action: @escaping () -> Void,
        isEnabled: Bool,
        isPrimary: Bool = false,
        accessibilityLabel: String
    ) -> some View {
        let size = isPrimary ? tokens.button.primarySize : tokens.button.secondarySize
        let iconSize = isPrimary ? tokens.button.primaryIconSize : tokens.button.secondaryIconSize

        return Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: iconSize, weight: .semibold))
                .foregroundColor(isEnabled ? .white : .white.opacity(tokens.opacity.disabled))
                .frame(width: size, height: size)
                .background(
                    Circle()
                        .fill(isPrimary ? Color.accentColor : Color.white.opacity(tokens.opacity.secondaryBackground))
                        .opacity(isEnabled ? 1 : tokens.opacity.disabledBackground)
                )
        }
        .disabled(!isEnabled)
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityHint(isEnabled ? "" : "Disabled")
    }
}

// MARK: - PlaybackControlsPreview

private struct PlaybackControlsPreview: View {
    @State private var player = ConfettiPlayer()

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                LinearGradient(
                    colors: [.purple, .blue],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack {
                    Spacer()
                    PlaybackControls(player: player, canvasSize: geometry.size)
                }
                .padding()
            }
        }
    }
}

#Preview {
    PlaybackControlsPreview()
}
