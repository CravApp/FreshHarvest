//
//  Typography.swift
//  FreshHarvest
//
//  The design system uses **Plus Jakarta Sans** exclusively. Four static
//  instances (Regular 400, SemiBold 600, Bold 700, ExtraBold 800) are bundled in
//  `Resources/Fonts` and registered at launch, so `Font.custom` resolves them by
//  their real PostScript names (e.g. `PlusJakartaSans-SemiBold`).
//
//  Every scale from DESIGN.md is reproduced with the exact size / weight /
//  line-height / tracking quadruple.
//

import SwiftUI

// MARK: - Font registration state

/// Thread-safe flag recording whether the bundled faces are visible to Core
/// Text. The design system falls back to the system font until then, so a
/// missing font degrades gracefully instead of rendering blank glyphs.
///
/// This is a reference type rather than a `static var` so it stays `Sendable`
/// and free of global mutable state under Swift 6 concurrency checking.
final class FontRegistry: @unchecked Sendable {

    static let shared = FontRegistry()

    private let lock = NSLock()
    private var registered = false

    private init() {}

    /// `true` once every bundled face has resolved through Core Text.
    var isRegistered: Bool {
        lock.lock()
        defer { lock.unlock() }
        return registered
    }

    func markRegistered() {
        lock.lock()
        defer { lock.unlock() }
        registered = true
    }
}

// MARK: - Font family

enum AppFont {

    /// The four bundled static weights, addressed by PostScript name.
    enum Weight: String, CaseIterable {
        case regular = "PlusJakartaSans-Regular"
        case semiBold = "PlusJakartaSans-SemiBold"
        case bold = "PlusJakartaSans-Bold"
        case extraBold = "PlusJakartaSans-ExtraBold"

        /// Nearest system weight, used only while the real face is unavailable.
        var systemEquivalent: Font.Weight {
            switch self {
            case .regular: return .regular
            case .semiBold: return .semibold
            case .bold: return .bold
            case .extraBold: return .heavy
            }
        }
    }

    /// PostScript names bundled with the app.
    static var postScriptNames: [String] { Weight.allCases.map(\.rawValue) }

    /// Resolves a design weight at the requested point size.
    static func font(_ weight: Weight, size: CGFloat) -> Font {
        guard FontRegistry.shared.isRegistered else {
            return .system(size: size, weight: weight.systemEquivalent)
        }
        return .custom(weight.rawValue, size: size)
    }
}

// MARK: - Type scale

/// One entry of the type scale: point size, weight, line height and tracking.
struct TypeToken: Equatable {
    let size: CGFloat
    let weight: AppFont.Weight
    let lineHeight: CGFloat
    /// Letter spacing in points. DESIGN.md expresses tracking in `em`; the values
    /// below are pre-multiplied by `size` so they can be fed straight to
    /// `.tracking(_:)`.
    let tracking: CGFloat

    var font: Font { AppFont.font(weight, size: size) }

    /// Extra leading needed so the text block matches `lineHeight`.
    var lineSpacing: CGFloat { max(0, lineHeight - size * 1.2) }
}

/// DESIGN.md → SwiftUI type ramp.
enum TypeScale {

    /// 36 / 700 / 44 / −0.02em
    static let headlineXL = TypeToken(size: 36, weight: .bold, lineHeight: 44, tracking: -0.72)
    /// 28 / 700 / 34 / −0.015em
    static let headlineXLMobile = TypeToken(size: 28, weight: .bold, lineHeight: 34, tracking: -0.42)
    /// 24 / 700 / 32 / −0.01em
    static let headlineLG = TypeToken(size: 24, weight: .bold, lineHeight: 32, tracking: -0.24)
    /// 20 / 600 / 28 / −0.01em
    static let headlineMD = TypeToken(size: 20, weight: .semiBold, lineHeight: 28, tracking: -0.20)
    /// 16 / 600 / 22
    static let headlineSM = TypeToken(size: 16, weight: .semiBold, lineHeight: 22, tracking: 0)
    /// 16 / 400 / 24
    static let bodyLG = TypeToken(size: 16, weight: .regular, lineHeight: 24, tracking: 0)
    /// 14 / 400 / 20
    static let bodyMD = TypeToken(size: 14, weight: .regular, lineHeight: 20, tracking: 0)
    /// 12 / 400 / 16
    static let bodySM = TypeToken(size: 12, weight: .regular, lineHeight: 16, tracking: 0)
    /// 14 / 600 / 20 / +0.01em
    static let labelLG = TypeToken(size: 14, weight: .semiBold, lineHeight: 20, tracking: 0.14)
    /// 12 / 600 / 16 / +0.01em
    static let labelMD = TypeToken(size: 12, weight: .semiBold, lineHeight: 16, tracking: 0.12)
    /// 10 / 600 / 14 / +0.02em
    static let labelSM = TypeToken(size: 10, weight: .semiBold, lineHeight: 14, tracking: 0.20)

    /// Promo banner headline — `headline-md` at mobile widths.
    static let promoHeadline = headlineMD

    /// Uppercase eyebrow such as `ENTREGA EN` and `MÁS VENDIDOS`.
    /// `label-sm` + `font-bold` + `tracking-wider` (0.05em at 10px = 0.5pt).
    static let eyebrow = TypeToken(size: 10, weight: .bold, lineHeight: 14, tracking: 0.50)

    /// Badge text inside the promo pill — `label-sm` + `font-bold`.
    static let badge = TypeToken(size: 10, weight: .bold, lineHeight: 14, tracking: 0.20)
}

// MARK: - Convenience view modifiers

extension View {

    /// Applies a `TypeToken` (font + tracking + line spacing) in one call.
    func typeStyle(
        _ token: TypeToken,
        lineLimit: Int? = nil,
        alignment: TextAlignment = .leading
    ) -> some View {
        self
            .font(token.font)
            .tracking(token.tracking)
            .lineSpacing(token.lineSpacing)
            .multilineTextAlignment(alignment)
            .lineLimit(lineLimit)
    }

    /// Uppercase eyebrow / section-overline treatment.
    func eyebrowStyle(color: Color = Palette.secondary) -> some View {
        self
            .typeStyle(TypeScale.eyebrow)
            .textCase(.uppercase)
            .foregroundStyle(color)
    }

    /// Uppercase pill-badge treatment (promo codes, "ENVÍO GRATIS", "30% OFF").
    func badgeStyle(color: Color) -> some View {
        self
            .typeStyle(TypeScale.badge)
            .textCase(.uppercase)
            .foregroundStyle(color)
    }
}
