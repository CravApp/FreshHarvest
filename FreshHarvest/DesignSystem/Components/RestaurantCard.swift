//
//  RestaurantCard.swift
//  FreshHarvest
//
//  The "Restaurantes populares" feed card: hero photo with floating badges, a
//  favourite toggle, the title / rating row, a delivery meta line, and a
//  "Más vendidos" quick-add block.
//
//  Source markup:
//  `<article class="bg-surface-container-lowest rounded-2xl shadow-sm
//    overflow-hidden flex flex-col">` with a `h-44` photo well, a `p-space-md`
//  body and `bg-surface-container-low p-2.5 rounded-xl` quick-add rows.
//

import SwiftUI

struct RestaurantCard: View {

    let restaurant: Restaurant
    let isFavourite: Bool
    /// Quantity of each dish currently in the cart, keyed by dish id.
    let quantityFor: (Dish) -> Int
    /// `true` while a dish's add button shows its confirmation tick.
    let justAdded: (Dish) -> Bool
    var onFavouriteTap: () -> Void
    var onAdd: (Dish) -> Void
    var onCardTap: () -> Void = {}

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            heroPhoto

            VStack(alignment: .leading, spacing: Spacing.sm) {   // `p-space-md` + `gap-space-sm`
                titleRow
                DeliveryMetaLine(
                    deliveryFeeLabel: restaurant.deliveryFeeLabel,
                    isFree: restaurant.hasFreeDelivery,
                    distanceLabel: restaurant.distanceLabel
                )
                bestsellerBlock
            }
            .padding(Spacing.md)
        }
        .background(Palette.cardSurface)
        .clipShape(RoundedRectangle(cornerRadius: Radius.lg, style: .continuous))
        .elevation1()
        .contentShape(RoundedRectangle(cornerRadius: Radius.lg, style: .continuous))
        .onTapGesture(perform: onCardTap)
        .accessibilityElement(children: .contain)
    }

    // MARK: - Hero photo

    private var heroPhoto: some View {
        Image(restaurant.imageName)
            .resizable()
            .scaledToFill()
            .frame(maxWidth: .infinity)
            .frame(height: Metrics.restaurantPhotoHeight)
            .clipped()
            .background(Palette.surfaceContainer)
            .overlay(alignment: .topLeading) {
                // `absolute top-3 left-3 flex items-center gap-2`
                HStack(spacing: Spacing.sm) {
                    ETABadge(text: restaurant.etaLabel)

                    if let promoLabel = restaurant.promoLabel {
                        PromoBadge(text: promoLabel, style: restaurant.promoStyle)
                    }
                }
                .padding(12)                                 // `top-3 left-3`
            }
            .overlay(alignment: .topTrailing) {
                favouriteButton
                    .padding(12)
            }
            .accessibilityHidden(true)
    }

    private var favouriteButton: some View {
        Button(action: onFavouriteTap) {
            Icon(
                isFavourite ? .favorite : .favoriteBorder,
                size: 20,
                color: isFavourite ? Palette.error : Palette.secondary,
                filled: isFavourite
            )
            .frame(width: Metrics.iconButtonLarge, height: Metrics.iconButtonLarge)
            .background {
                Circle()
                    .fill(Palette.surfaceContainerLowest.opacity(0.90))
                    .background(.ultraThinMaterial, in: Circle())
            }
            .elevation1()
            .contentShape(Circle())
        }
        .buttonStyle(PressableButtonStyle(pressedScale: 0.90))
        .accessibilityLabel(isFavourite
                            ? "Quitar \(restaurant.name) de favoritos"
                            : "Guardar \(restaurant.name) en favoritos")
    }

    // MARK: - Title row

    private var titleRow: some View {
        HStack(alignment: .top, spacing: Spacing.sm) {           // `gap-2`
            VStack(alignment: .leading, spacing: 0) {
                Text(restaurant.name)
                    .typeStyle(TypeScale.headlineSM, lineLimit: 1)
                    .foregroundStyle(Palette.onSurface)

                Text(restaurant.cuisineSummary)
                    .typeStyle(TypeScale.bodySM, lineLimit: 1)
                    .foregroundStyle(Palette.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            RatingBadge(
                ratingLabel: restaurant.ratingLabel,
                reviewCountLabel: restaurant.reviewCountLabel
            )
        }
    }

    // MARK: - Bestsellers

    private var bestsellerBlock: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {        // `gap-2`
            Text(restaurant.bestsellerTitle)
                .eyebrowStyle()
                .padding(.top, Spacing.xs)                       // `pt-space-xs`

            ForEach(restaurant.bestsellers) { dish in
                QuickAddRow(
                    dish: dish,
                    quantity: quantityFor(dish),
                    showAddedState: justAdded(dish),
                    onAdd: { onAdd(dish) }
                )
            }
        }
        .padding(.top, Spacing.xs)                               // `mt-1`
    }
}

// MARK: - Quick add row

/// A single "bestseller" row: 44 × 44 thumbnail, name, price, and the round
/// emerald add button that briefly turns into a tick.
struct QuickAddRow: View {

    let dish: Dish
    let quantity: Int
    let showAddedState: Bool
    var onAdd: () -> Void

    var body: some View {
        HStack(spacing: 0) {
            HStack(spacing: 10) {                                // `gap-2.5`
                Image(dish.imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: Metrics.quickAddThumbnail, height: Metrics.quickAddThumbnail)
                    .clipShape(RoundedRectangle(cornerRadius: Radius.standard, style: .continuous))
                    .background(Palette.surfaceContainer)

                VStack(alignment: .leading, spacing: 0) {
                    Text(dish.name)
                        .typeStyle(TypeScale.labelMD, lineLimit: 1)
                        .foregroundStyle(Palette.onSurface)

                    Text(dish.formattedPrice)
                        .typeStyle(TypeScale.bodySM)
                        .fontWeight(.bold)
                        .foregroundStyle(Palette.primary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            addButton
        }
        .padding(10)                                             // `p-2.5`
        .background(
            Palette.surfaceContainerLow,
            in: RoundedRectangle(cornerRadius: Radius.md, style: .continuous)
        )
    }

    private var addButton: some View {
        Button(action: onAdd) {
            ZStack {
                Circle()
                    .fill(showAddedState ? Palette.onSurface : Palette.primary)
                    .frame(width: Metrics.iconButtonSmall, height: Metrics.iconButtonSmall)

                Icon(
                    showAddedState ? .check : .add,
                    size: 18,
                    color: Palette.onPrimary
                )
            }
            .frame(width: Metrics.iconButtonSmall, height: Metrics.iconButtonSmall)
            .elevation1()
            .contentShape(Circle())
        }
        .buttonStyle(PressableButtonStyle(pressedScale: 0.90))
        .accessibilityLabel("Añadir \(dish.name), \(dish.formattedPrice)")
        .accessibilityValue(quantity > 0 ? "\(quantity) en el carrito" : "No está en el carrito")
        .accessibilityAddTraits(.isButton)
    }
}

#Preview("RestaurantCard") {
    ScrollView {
        VStack(spacing: Spacing.md) {
            ForEach(SampleData.restaurants) { restaurant in
                RestaurantCard(
                    restaurant: restaurant,
                    isFavourite: restaurant.id == "green-bowl-deli",
                    quantityFor: { $0.id == "poke" ? 2 : 0 },
                    justAdded: { _ in false },
                    onFavouriteTap: {},
                    onAdd: { _ in }
                )
            }
        }
        .padding(Spacing.margin)
    }
    .background(Palette.surface)
}
