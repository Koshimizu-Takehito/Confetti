import ConfettiCore
import CoreGraphics

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

// MARK: - DefaultColorSource

/// Default color source using asset catalog colors.
///
/// Provides a vibrant 7-color palette by default. You can customize the palette
/// by passing an array of `CGColor` values to the initializer.
///
/// ## Example: Custom Palette
///
/// ```swift
/// let source = DefaultColorSource(palette: [
///     CGColor(red: 1, green: 0, blue: 0, alpha: 1),
///     CGColor(red: 0, green: 0, blue: 1, alpha: 1),
/// ])
/// ```
public struct DefaultColorSource: ConfettiColorSource {
    private let palette: [CGColor]

    /// Initializes with a custom palette.
    /// - Parameter palette: Array of `CGColor` values (default is the bundled 7-color palette)
    public init(palette: [CGColor] = Self.defaultPalette) {
        // For library robustness: never allow an empty palette (would crash in random index selection).
        self.palette = palette.isEmpty ? Self.fallbackPalette : palette
    }

    public mutating func nextColor(using numberGenerator: inout some RandomNumberGenerator) -> CGColor {
        let index = Int.random(in: 0 ..< palette.count, using: &numberGenerator)
        return palette[index]
    }

    // MARK: - Default Palette

    /// The default 7-color confetti palette loaded from the asset catalog.
    public static let defaultPalette: [CGColor] = {
        let names = [
            "CoralRed",
            "MangoOrange",
            "LemonYellow",
            "SpringGreen",
            "SkyBlue",
            "VioletPurple",
            "HotPink",
        ]
        let loaded = names.compactMap { loadColor(named: $0) }
        // If assets are missing (e.g., consumer forgot resources, renamed assets, etc.),
        // fall back to hard-coded sRGB colors to avoid runtime crashes.
        return loaded.isEmpty ? fallbackPalette : loaded
    }()

    /// Fallback palette used when asset colors cannot be loaded.
    ///
    /// Kept in sRGB and intentionally matches the default 7-color vibe.
    private static let fallbackPalette: [CGColor] = [
        CGColor(red: 1.0, green: 0.42, blue: 0.42, alpha: 1.0), // Coral red
        CGColor(red: 1.0, green: 0.64, blue: 0.25, alpha: 1.0), // Mango orange
        CGColor(red: 1.0, green: 0.92, blue: 0.35, alpha: 1.0), // Lemon yellow
        CGColor(red: 0.35, green: 0.90, blue: 0.45, alpha: 1.0), // Spring green
        CGColor(red: 0.35, green: 0.72, blue: 1.0, alpha: 1.0), // Sky blue
        CGColor(red: 0.72, green: 0.40, blue: 1.0, alpha: 1.0), // Violet purple
        CGColor(red: 1.0, green: 0.32, blue: 0.78, alpha: 1.0), // Hot pink
    ]

    private static func loadColor(named name: String) -> CGColor? {
        #if canImport(UIKit)
        return UIColor(named: name, in: .module, compatibleWith: nil)?.cgColor
        #elseif canImport(AppKit)
        return NSColor(named: name, bundle: .module)?.cgColor
        #else
        return nil
        #endif
    }
}
