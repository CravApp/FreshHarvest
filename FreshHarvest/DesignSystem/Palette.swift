//
//  Palette.swift
//  FreshHarvest
//
//  Every token from DESIGN.md, transcribed verbatim. The design system is a
//  Material-3 style tonal palette: `primary` is the deep emerald used for
//  text/brand marks, `primaryContainer` is the vibrant emerald used for the
//  logo tile, the promo banner fill and the CTA stepper buttons.
//

import SwiftUI

enum Palette {

    // MARK: - Primary

    static let primary = Color(hex: 0x006C49)
    static let onPrimary = Color(hex: 0xFFFFFF)
    static let primaryContainer = Color(hex: 0x10B981)
    static let onPrimaryContainer = Color(hex: 0x00422B)
    static let inversePrimary = Color(hex: 0x4EDEA3)
    static let surfaceTint = Color(hex: 0x006C49)
    static let primaryFixed = Color(hex: 0x6FFBBE)
    static let primaryFixedDim = Color(hex: 0x4EDEA3)
    static let onPrimaryFixed = Color(hex: 0x002113)
    static let onPrimaryFixedVariant = Color(hex: 0x005236)

    // MARK: - Secondary

    static let secondary = Color(hex: 0x555F6F)
    static let onSecondary = Color(hex: 0xFFFFFF)
    static let secondaryContainer = Color(hex: 0xD6E0F3)
    static let onSecondaryContainer = Color(hex: 0x596373)
    static let secondaryFixed = Color(hex: 0xD9E3F6)
    static let secondaryFixedDim = Color(hex: 0xBDC7D9)
    static let onSecondaryFixed = Color(hex: 0x121C2A)
    static let onSecondaryFixedVariant = Color(hex: 0x3D4756)

    // MARK: - Tertiary (warm amber)

    static let tertiary = Color(hex: 0x855300)
    static let onTertiary = Color(hex: 0xFFFFFF)
    static let tertiaryContainer = Color(hex: 0xE29100)
    static let onTertiaryContainer = Color(hex: 0x523200)
    static let tertiaryFixed = Color(hex: 0xFFDDB8)
    static let tertiaryFixedDim = Color(hex: 0xFFB95F)
    static let onTertiaryFixed = Color(hex: 0x2A1700)
    static let onTertiaryFixedVariant = Color(hex: 0x653E00)

    /// Amber used for rating stars and the logo sparkle. DESIGN.md calls this out
    /// explicitly (`#F59E0B`) even though the tonal ramp uses `#855300` for the
    /// accessible on-surface amber.
    static let ratingAmber = Color(hex: 0xF59E0B)

    // MARK: - Error

    static let error = Color(hex: 0xBA1A1A)
    static let onError = Color(hex: 0xFFFFFF)
    static let errorContainer = Color(hex: 0xFFDAD6)
    static let onErrorContainer = Color(hex: 0x93000A)

    // MARK: - Surfaces

    static let surface = Color(hex: 0xF8F9FA)
    static let surfaceDim = Color(hex: 0xD9DADB)
    static let surfaceBright = Color(hex: 0xF8F9FA)
    static let surfaceContainerLowest = Color(hex: 0xFFFFFF)
    static let surfaceContainerLow = Color(hex: 0xF3F4F5)
    static let surfaceContainer = Color(hex: 0xEDEEEF)
    static let surfaceContainerHigh = Color(hex: 0xE7E8E9)
    static let surfaceContainerHighest = Color(hex: 0xE1E3E4)
    static let surfaceVariant = Color(hex: 0xE1E3E4)
    static let onSurface = Color(hex: 0x191C1D)
    static let onSurfaceVariant = Color(hex: 0x3C4A42)
    static let inverseSurface = Color(hex: 0x2E3132)
    static let inverseOnSurface = Color(hex: 0xF0F1F2)
    static let background = Color(hex: 0xF8F9FA)
    static let onBackground = Color(hex: 0x191C1D)

    // MARK: - Outlines

    static let outline = Color(hex: 0x6C7A71)
    static let outlineVariant = Color(hex: 0xBBCABF)

    // MARK: - Shadow / scrim

    /// Ink used by every elevation shadow: `rgba(16, 24, 40, alpha)`.
    static let shadowInk = Color(hex: 0x101828)
    /// Translucent wash behind bottom sheets: `rgba(15, 23, 42, 0.35)`.
    static let scrim = Color(hex: 0x0F172A)
}

// MARK: - Semantic aliases used by the UI layer

extension Palette {
    /// Muted body copy such as the "Saludable • Poke • Ensaladas" subtitle.
    static let textMuted = secondary
    /// Card / sheet resting surface.
    static let cardSurface = surfaceContainerLowest
    /// Neutral photo well behind product imagery.
    static let photoWell = surfaceContainerLow
}
