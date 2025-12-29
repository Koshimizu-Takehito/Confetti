import SwiftUI

// MARK: - TimeSlider

/// A slider component for seeking through confetti playback with time display.
///
/// Displays current time and duration alongside a slider for seeking.
/// Supports both drag gestures and tap-to-seek for intuitive control.
struct TimeSlider: View {
    // MARK: - Properties

    @Binding var currentTime: TimeInterval
    let duration: TimeInterval
    let onSeek: (TimeInterval) -> Void
    var onDragStart: (() -> Void)?
    var onDragEnd: (() -> Void)?

    // MARK: - Environment

    @Environment(\.confettiDesignTokens) private var tokens

    // MARK: - Private State

    @State private var isDragging = false
    @State private var dragValue: TimeInterval = 0

    // MARK: - Body

    var body: some View {
        HStack(spacing: tokens.spacing.small) {
            timeLabel(for: displayTime)

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Track background
                    Capsule()
                        .fill(Color.white.opacity(tokens.opacity.trackBackground))
                        .frame(height: tokens.slider.trackHeight)

                    // Progress fill
                    Capsule()
                        .fill(Color.white)
                        .frame(width: progressWidth(in: geometry.size.width), height: tokens.slider.trackHeight)

                    // Thumb
                    Circle()
                        .fill(Color.white)
                        .frame(width: tokens.slider.thumbDiameter, height: tokens.slider.thumbDiameter)
                        .shadow(
                            color: .black.opacity(tokens.opacity.shadowMedium),
                            radius: tokens.shadow.thumbRadius,
                            x: 0,
                            y: 1
                        )
                        .offset(x: thumbOffset(in: geometry.size.width))
                }
                .frame(height: tokens.slider.thumbDiameter)
                .contentShape(Rectangle())
                .gesture(
                    // DragGesture with minimumDistance: 0 handles both tap and drag
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            handleDragChange(at: value.location.x, in: geometry.size.width)
                        }
                        .onEnded { value in
                            handleDragEnd(at: value.location.x, in: geometry.size.width)
                        }
                )
            }
            .frame(height: tokens.slider.thumbDiameter)

            timeLabel(for: duration)
        }
        .font(.system(size: tokens.font.timeLabel, weight: .medium, design: .monospaced))
        .foregroundColor(.white)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Seek slider")
        .accessibilityValue(accessibilityTimeValue)
        .accessibilityAdjustableAction { direction in
            handleAccessibilityAdjustment(direction)
        }
    }

    // MARK: - Private Computed Properties

    private var displayTime: TimeInterval {
        isDragging ? dragValue : currentTime
    }

    private var progress: Double {
        guard duration > 0 else { return 0 }
        return min(1, max(0, displayTime / duration))
    }

    private var accessibilityTimeValue: String {
        "\(formattedTime(displayTime)) of \(formattedTime(duration))"
    }

    // MARK: - Private Methods

    private func progressWidth(in totalWidth: CGFloat) -> CGFloat {
        max(0, totalWidth * progress)
    }

    private func thumbOffset(in totalWidth: CGFloat) -> CGFloat {
        let availableWidth = totalWidth - tokens.slider.thumbDiameter
        return max(0, availableWidth * progress)
    }

    private func timeFromPosition(_ x: CGFloat, in width: CGFloat) -> TimeInterval {
        guard duration > 0, width > tokens.slider.thumbDiameter else { return 0 }
        let availableWidth = width - tokens.slider.thumbDiameter
        let clampedX = max(0, min(x - tokens.slider.thumbRadius, availableWidth))
        let ratio = availableWidth > 0 ? clampedX / availableWidth : 0
        return duration * ratio
    }

    private func handleDragChange(at x: CGFloat, in width: CGFloat) {
        let wasNotDragging = !isDragging
        isDragging = true

        // Notify drag start
        if wasNotDragging {
            onDragStart?()
        }

        let newValue = timeFromPosition(x, in: width)

        // Seek in real-time (only when value changes)
        if abs(newValue - dragValue) > 0.001 {
            dragValue = newValue
            onSeek(dragValue)
        }
    }

    private func handleDragEnd(at x: CGFloat, in width: CGFloat) {
        isDragging = false
        // Confirm final value
        let finalValue = timeFromPosition(x, in: width)
        dragValue = finalValue // Reset for next drag session
        onSeek(finalValue)
        // Notify drag end
        onDragEnd?()
    }

    private func handleAccessibilityAdjustment(_ direction: AccessibilityAdjustmentDirection) {
        guard duration > 0 else { return }

        // Notify start for consistency with tap/drag behavior
        onDragStart?()

        let step = duration / 10 // 10% increments
        let newTime: TimeInterval
        switch direction {
        case .increment:
            newTime = min(duration, currentTime + step)

        case .decrement:
            newTime = max(0, currentTime - step)

        @unknown default:
            onDragEnd?()
            return
        }
        onSeek(newTime)

        // Notify end for consistency with tap/drag behavior
        onDragEnd?()
    }

    private func timeLabel(for time: TimeInterval) -> some View {
        Text(formattedTime(time))
            .frame(width: tokens.slider.timeLabelWidth, alignment: .center)
    }

    private func formattedTime(_ time: TimeInterval) -> String {
        let totalSeconds = Int(max(0, time))
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// MARK: - Preview

#Preview("Normal") {
    ZStack {
        Color.black.opacity(0.8)
        TimeSlider(
            currentTime: .constant(2.5),
            duration: 5.0,
            onSeek: { _ in }
        )
        .padding()
    }
}

#Preview("Duration Zero") {
    ZStack {
        Color.black.opacity(0.8)
        TimeSlider(
            currentTime: .constant(0),
            duration: 0,
            onSeek: { _ in }
        )
        .padding()
    }
}

#Preview("At End") {
    ZStack {
        Color.black.opacity(0.8)
        TimeSlider(
            currentTime: .constant(5.0),
            duration: 5.0,
            onSeek: { _ in }
        )
        .padding()
    }
}
