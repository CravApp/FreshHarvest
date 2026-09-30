//
//  Models.swift
//  FreshHarvest
//
//  Plain value types describing the screen's content. They mirror the markup in
//  the source design one-for-one: three restaurant cards, seven categories, four
//  quick filters, and a promo banner.
//
//  `SwiftUI` is imported for `Color` (the category/filter tints) and for
//  `Palette`, which the tint enums resolve against.
//

import SwiftUI
import Foundation

// MARK: - Delivery mode

/// The two service modes offered by the pill switcher under the search bar.
enum DeliveryMode: String, CaseIterable, Identifiable {
    case delivery
    case pickup

    var id: String { rawValue }

    /// Visible label. The HTML renders "Delivery" and "Para recoger / Retirar".
    var title: String {
        switch self {
        case .delivery: return "Delivery"
        case .pickup: return "Para recoger / Retirar"
        }
    }

    /// Shorter variant used when horizontal space is tight.
    var shortTitle: String {
        switch self {
        case .delivery: return "Delivery"
        case .pickup: return "Para recoger"
        }
    }

    var icon: MaterialIcon {
        switch self {
        case .delivery: return .moped
        case .pickup: return .shoppingBag
        }
    }
}

// MARK: - Category

/// One tile in the horizontal category rail.
struct FoodCategory: Identifiable, Hashable {
    let id: String
    /// Display name, e.g. "Bowls & Fit".
    let name: String
    /// Icon drawn inside the tile.
    let icon: MaterialIcon
    /// Tint of the glyph when the tile is *not* selected.
    let tint: CategoryTint

    /// Glyph tints available to category tiles. The design mixes emerald, amber
    /// and red glyphs to keep the rail visually varied.
    enum CategoryTint: Hashable {
        case primary
        case tertiary
        case tertiaryContainer
        case error

        var color: Color {
            switch self {
            case .primary: return Palette.primary
            case .tertiary: return Palette.tertiary
            case .tertiaryContainer: return Palette.tertiaryContainer
            case .error: return Palette.error
            }
        }
    }
}

// MARK: - Quick filter

/// A chip in the "quick filters" strip below the category rail.
struct QuickFilter: Identifiable, Hashable {
    let id: String
    let title: String
    let icon: MaterialIcon
    /// Colour of the leading glyph.
    let tint: Color
    /// Whether the glyph uses the filled face (the rating star does).
    let filled: Bool
}

// MARK: - Dish

/// A menu item. Also used for the "Más vendidos" quick-add rows.
struct Dish: Identifiable, Hashable {
    let id: String
    let name: String
    /// Price in euro cents, so arithmetic stays exact.
    let priceCents: Int
    /// Asset-catalog name of the thumbnail.
    let imageName: String

    /// Localised price, e.g. `12,90 €`.
    var formattedPrice: String { PriceFormatter.euro(cents: priceCents) }
}

// MARK: - Restaurant

/// A restaurant card in the "Restaurantes populares" feed.
struct Restaurant: Identifiable, Hashable {
    let id: String
    let name: String
    /// Cuisine summary line, e.g. "Saludable • Poke • Ensaladas • $$".
    let cuisineSummary: String
    let rating: Double
    /// Review count already formatted for display, e.g. "1.4k" or "980".
    let reviewCountLabel: String
    /// Delivery ETA badge, e.g. "20-30 min".
    let etaLabel: String
    /// Promotional badge text; `nil` hides the badge.
    let promoLabel: String?
    /// Whether the promo badge uses the emerald or amber treatment.
    let promoStyle: PromoStyle
    /// `nil` when delivery is free — drives the "Envío gratis" badge.
    let deliveryFeeCents: Int?
    /// Distance already formatted, e.g. "a 0.8 km".
    let distanceLabel: String
    /// Hero photo asset name.
    let imageName: String
    /// Headline for the bestseller block ("Más vendidos" / "Más vendido").
    let bestsellerTitle: String
    /// The quick-add items shown inside the card.
    let bestsellers: [Dish]

    /// Visual treatment of the top-left promo badge.
    enum PromoStyle: Hashable {
        /// Emerald pill reading "Envío gratis".
        case freeDelivery
        /// Amber pill with a percentage, e.g. "30% OFF".
        case discount
    }

    /// `true` when the restaurant delivers for free.
    var hasFreeDelivery: Bool { deliveryFeeCents == nil || deliveryFeeCents == 0 }

    /// Delivery-fee line, e.g. "Envío 0,00 €" or "Envío 1,80 €".
    var deliveryFeeLabel: String {
        PriceFormatter.euro(cents: deliveryFeeCents ?? 0)
    }

    /// Rating rendered with one decimal, e.g. "4.9".
    var ratingLabel: String { String(format: "%.1f", rating) }
}

// MARK: - Cart

/// One line in the cart: a dish plus its quantity.
struct CartLine: Identifiable, Hashable {
    let dish: Dish
    /// Restaurant the dish belongs to — used for grouping and the header line.
    let restaurantName: String
    var quantity: Int

    var id: String { dish.id }

    /// Line total in cents.
    var subtotalCents: Int { dish.priceCents * quantity }
}

// MARK: - Address

/// The delivery address shown in the header.
struct DeliveryAddress: Hashable {
    let street: String
    let city: String

    /// Single-line form used by the header, e.g. "Calle Gran Vía, 42".
    var display: String { street }
}

// MARK: - Money formatting

/// Formats euro amounts the way the design does: comma decimal separator,
/// always two decimals, currency symbol last.
enum PriceFormatter {

    private static let formatter: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.minimumFractionDigits = 2
        f.maximumFractionDigits = 2
        f.groupingSeparator = "."
        f.decimalSeparator = ","
        f.usesGroupingSeparator = true
        return f
    }()

    /// `1290` → `"12,90 €"`.
    static func euro(cents: Int) -> String {
        let value = Double(cents) / 100
        let number = formatter.string(from: NSNumber(value: value)) ?? String(format: "%.2f", value)
        return "\(number) €"
    }

    /// `1290` → `"12,90 €"` without the grouping separator, for tight layouts.
    static func euroCompact(cents: Int) -> String {
        let value = Double(cents) / 100
        return String(format: "%.2f €", value).replacingOccurrences(of: ".", with: ",")
    }
}
