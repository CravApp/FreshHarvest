//
//  Layout.swift
//  FreshHarvest
//
//  Spacing, corner-radius and elevation tokens from DESIGN.md.
//
//  Base unit: 4px rhythm with 8px increments. The 20px screen margin is the key
//  layout constant — it is applied by the header, the scroll content and the
//  bottom navigation so all three align on the same optical grid.
//

import SwiftUI

// MARK: - Spacing

enum Spacing {
    /// `space-xs` — 4
    static let xs: CGFloat = 4
    /// `space-sm` — 8
    static let sm: CGFloat = 8
    /// `space-md` — 16
    static let md: CGFloat = 16
    /// `space-lg` — 24
    static let lg: CGFloat = 24
    /// `space-xl` — 32
    static let xl: CGFloat = 32

    /// Screen edge margin — 20 (`1.25rem`).
    static let margin: CGFloat = 20
    /// Gap between cards in a feed — 16 (`1rem`).
    static let gutter: CGFloat = 16

    /// Extra 4px rhythm value used by a few hairline paddings.
    static let xxs: CGFloat = 2
}

// MARK: - Radius

enum Radius {
    /// `rounded-sm` — 4
    static let sm: CGFloat = 4
    /// `rounded` — 8
    static let standard: CGFloat = 8
    /// `rounded-md` — 12
    static let md: CGFloat = 12
    /// `rounded-lg` — 16 — item cards, promo cards, category containers.
    static let lg: CGFloat = 16
    /// `rounded-2xl` — 24 — modal sheets, bottom checkout sheet top edges.
    static let xl: CGFloat = 24
    /// `rounded-full` — pills, CTAs, steppers, rating badges.
    static let full: CGFloat = 9999
}

// MARK: - Elevation

/// The three documented elevation levels plus the overlay scrim.
///
/// Each level pairs a shadow radius with a vertical offset and an opacity of
/// `Palette.shadowInk` (`#101828`), reproducing the CSS values exactly:
///
/// | Level | CSS |
/// |-------|-----|
/// | 1 | `0 4px 16px -2px rgba(16,24,40,0.05)` |
/// | 2 | `0 8px 24px -4px rgba(16,24,40,0.08)` |
/// | 3 | `0 20px 32px -8px rgba(16,24,40,0.14)` |
enum Elevation {
    /// Level 1 — cards and product tiles.
    static let level1Radius: CGFloat = 16
    static let level1Y: CGFloat = 4
    static let level1Opacity: Double = 0.05

    /// Level 2 — floating controls, sticky bottom bars, segmented pills.
    static let level2Radius: CGFloat = 24
    static let level2Y: CGFloat = 8
    static let level2Opacity: Double = 0.08

    /// Level 3 — modals and bottom sheets.
    static let level3Radius: CGFloat = 32
    static let level3Y: CGFloat = 20
    static let level3Opacity: Double = 0.14

    /// The header hairline: `0 1px 12px rgba(0,0,0,0.03)`.
    static let hairlineRadius: CGFloat = 12
    static let hairlineY: CGFloat = 1
    static let hairlineOpacity: Double = 0.03

    /// The bottom navigation divider: `0 -4px 20px rgba(0,0,0,0.05)`.
    static let navRadius: CGFloat = 20
    static let navY: CGFloat = -4
    static let navOpacity: Double = 0.05
}

// MARK: - Elevation view modifiers

extension View {

    /// Level 1 — diffuse ambient shadow for cards and tiles.
    func elevation1() -> some View {
        shadow(color: Palette.shadowInk.opacity(Elevation.level1Opacity),
               radius: Elevation.level1Radius / 2, x: 0, y: Elevation.level1Y)
    }

    /// Level 2 — floating controls, sticky bars, segmented pills.
    func elevation2() -> some View {
        shadow(color: Palette.shadowInk.opacity(Elevation.level2Opacity),
               radius: Elevation.level2Radius / 2, x: 0, y: Elevation.level2Y)
    }

    /// Level 3 — modals and bottom sheets.
    func elevation3() -> some View {
        shadow(color: Palette.shadowInk.opacity(Elevation.level3Opacity),
               radius: Elevation.level3Radius / 2, x: 0, y: Elevation.level3Y)
    }

    /// Translucent top-bar hairline used by the sticky header.
    func elevationHairline() -> some View {
        shadow(color: .black.opacity(Elevation.hairlineOpacity),
               radius: Elevation.hairlineRadius / 2, x: 0, y: Elevation.hairlineY)
    }

    /// Upward shadow used by the bottom navigation dock.
    func elevationNav() -> some View {
        shadow(color: .black.opacity(Elevation.navOpacity),
               radius: Elevation.navRadius / 2, x: 0, y: Elevation.navY)
    }
}

// MARK: - Fixed component metrics

/// Component heights lifted from the design spec so every screen agrees on them.
enum Metrics {
    /// Header bar height — `h-16` = 64.
    static let headerHeight: CGFloat = 64
    /// Bottom navigation height — `h-16` = 64.
    static let navHeight: CGFloat = 64
    /// Primary CTA height — 56, for comfortable thumb reach.
    static let primaryButtonHeight: CGFloat = 56
    /// Category tile — `w-16 h-16` = 64 × 64.
    static let categoryTile: CGFloat = 64
    /// Restaurant hero photo — `h-44` = 176.
    static let restaurantPhotoHeight: CGFloat = 176
    /// Quick-add thumbnail — `w-11 h-11` = 44 × 44.
    static let quickAddThumbnail: CGFloat = 44
    /// Smallest circular tap target used by favourite / add buttons — 36 / 32.
    static let iconButtonLarge: CGFloat = 36
    static let iconButtonSmall: CGFloat = 32
    /// Icon-button tap area — `w-11 h-11` = 44.
    static let iconButtonTapArea: CGFloat = 44
    /// Promo banner minimum height — `min-h-[170px]`.
    static let promoBannerMinHeight: CGFloat = 170
    /// Bottom content inset so the last card clears the floating nav bar.
    static let scrollBottomInset: CGFloat = 112
}
