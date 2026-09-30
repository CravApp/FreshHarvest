//
//  Badges.swift
//  FreshHarvest
//
//  Small reusable pills shared by the restaurant cards and the cart:
//  ETA badge, promo badge, rating badge and the delivery/meta line.
//
//  All four appear in `code.html` as inline spans; extracting them keeps the
//  card view readable and guarantees the badge treatment stays identical
//  everywhere it is used.
//

import SwiftUI

// MARK: - ETA badge

/// Translucent "20-30 min" pill that floats over the restaurant photo.
///
/// `bg-surface-container-lowest/90 backdrop-blur-md` → a 90 % white capsule with
/// a material blur behind it.
struct ETABadge: View {

    let text: String

    var body: some View {
        HStack(spacing: Spacing.xs) {
            Icon(.schedule, size: 14, color: Palette.primary)
            Text(text)
                .typeStyle(TypeScale.labelMD)
                .fontWeight(.bold)
                .foregroundStyle(Palette.onSurface)
        }
        .padding(.horizontal, 10)                    // `px-2.5`
        .padding(.vertical, 4)                       // `py-1`
        .background {
            Capsule(style: .continuous)
                .fill(Palette.surfaceContainerLowest.opacity(0.90))
                .background(.ultraThinMaterial, in: Capsule(style: .continuous))
        }
        .elevation1()
        .accessibilityLabel("Tiempo de entrega \(text)")
    }
}

// MARK: - Promo badge

/// Solid promo pill. Emerald for "Envío gratis", amber for "30% OFF".
struct PromoBadge: View {

    let text: String
    let style: Restaurant.PromoStyle

    private var fill: Color {
        switch style {
        case .freeDelivery: return Palette.primary
        case .discount: return Palette.tertiaryContainer
        }
    }

    var body: some View {
        Text(text)
            .typeStyle(TypeScale.labelSM)
            .fontWeight(.bold)
            .textCase(.uppercase)
            .tracking(0.5)                           // `tracking-wider`
            .foregroundStyle(Palette.onPrimary)
            .padding(.horizontal, 10)                // `px-2.5`
            .padding(.vertical, 4)                   // `py-1`
            .background(fill, in: Capsule(style: .continuous))
            .elevation1()
    }
}

// MARK: - Rating badge

/// Amber rating pill: filled star + score + review count.
///
/// `bg-tertiary-fixed/40 px-2 py-1 rounded-lg` with the score in `text-tertiary`.
struct RatingBadge: View {

    let ratingLabel: String
    let reviewCountLabel: String

    var body: some View {
        HStack(spacing: Spacing.xs) {
            Icon(.star, size: 16, color: Palette.tertiary, filled: true)

            Text(ratingLabel)
                .typeStyle(TypeScale.labelMD)
                .fontWeight(.bold)
                .foregroundStyle(Palette.tertiary)

            Text("(\(reviewCountLabel))")
                .typeStyle(TypeScale.bodySM)
                .foregroundStyle(Palette.secondary)
        }
        .padding(.horizontal, Spacing.sm)            // `px-2`
        .padding(.vertical, Spacing.xs)              // `py-1`
        .background(
            Palette.tertiaryFixed.opacity(0.40),
            in: RoundedRectangle(cornerRadius: Radius.standard, style: .continuous)
        )
        .fixedSize(horizontal: true, vertical: false)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Valoración \(ratingLabel) de 5, \(reviewCountLabel) reseñas")
    }
}

// MARK: - Meta line

/// The "Envío 0,00 € • a 0.8 km" row beneath the restaurant title.
struct DeliveryMetaLine: View {

    let deliveryFeeLabel: String
    let isFree: Bool
    let distanceLabel: String

    var body: some View {
        HStack(spacing: 12) {                        // `gap-3`
            HStack(spacing: Spacing.xs) {
                Icon(
                    .localShipping,
                    size: 16,
                    // Free delivery is highlighted in emerald, paid in slate.
                    color: isFree ? Palette.primary : Palette.secondary
                )
                Text("Envío \(deliveryFeeLabel)")
                    .typeStyle(TypeScale.bodySM)
                    .foregroundStyle(Palette.secondary)
            }

            Text("•")
                .typeStyle(TypeScale.bodySM)
                .foregroundStyle(Palette.secondary)

            HStack(spacing: Spacing.xs) {
                Icon(.pinDrop, size: 16, color: Palette.secondary)
                Text(distanceLabel)
                    .typeStyle(TypeScale.bodySM)
                    .foregroundStyle(Palette.secondary)
            }
        }
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Section header

/// "Restaurantes populares / Los favoritos cerca de tu ubicación" + "Ver todos".
struct SectionHeader: View {

    let title: String
    var subtitle: String? = nil
    var actionTitle: String? = nil
    var onAction: () -> Void = {}

    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 0) {
                Text(title)
                    .typeStyle(TypeScale.headlineMD)
                    .foregroundStyle(Palette.onSurface)

                if let subtitle {
                    Text(subtitle)
                        .typeStyle(TypeScale.bodySM)
                        .foregroundStyle(Palette.secondary)
                }
            }

            Spacer(minLength: Spacing.sm)

            if let actionTitle {
                Button(action: onAction) {
                    Text(actionTitle)
                        .typeStyle(TypeScale.labelMD)
                        .foregroundStyle(Palette.primary)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(actionTitle)
            }
        }
    }
}

#Preview("Badges") {
    VStack(alignment: .leading, spacing: Spacing.md) {
        HStack(spacing: Spacing.sm) {
            ETABadge(text: "20-30 min")
            PromoBadge(text: "Envío gratis", style: .freeDelivery)
            PromoBadge(text: "30% OFF", style: .discount)
        }
        RatingBadge(ratingLabel: "4.9", reviewCountLabel: "1.4k")
        DeliveryMetaLine(deliveryFeeLabel: "0,00 €", isFree: true, distanceLabel: "a 0.8 km")
        DeliveryMetaLine(deliveryFeeLabel: "1,80 €", isFree: false, distanceLabel: "a 1.4 km")
        SectionHeader(title: "Restaurantes populares",
                      subtitle: "Los favoritos cerca de tu ubicación",
                      actionTitle: "Ver todos")
    }
    .padding(Spacing.margin)
    .background(Palette.surface)
}
