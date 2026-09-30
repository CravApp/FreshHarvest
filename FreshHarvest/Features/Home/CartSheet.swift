//
//  CartSheet.swift
//  FreshHarvest
//
//  Full cart expansion presented as a bottom sheet.
//
//  DESIGN.md:
//  > Level 3 (Modals & Bottom Sheets): Full cart expansions, dish modifiers, and
//  > filter drawers feature `0 20px 32px -8px rgba(16, 24, 40, 0.14)`.
//  > Modal Sheets & Overlays (`rounded-xl` - 24px): Applied to top edges of
//  > bottom checkout sheets.
//  > Overlay State: Translucent backdrop blur (`backdrop-filter: blur(8px)`) with
//  > a `rgba(15, 23, 42, 0.35)` wash.
//
//  The sheet therefore uses a 24pt top radius, a Level 3 shadow, and a scrim
//  tinted `Palette.scrim` at 35 %. Rows reuse the pill stepper from the design
//  system ("Secondary Stepper Button: pill-shaped `#1F2937` container featuring
//  crisp white `+` and `−` symbols flanking a bold numeric quantity display").
//

import SwiftUI

struct CartSheet: View {

    @Bindable var store: AppStore

    var body: some View {
        VStack(spacing: 0) {
            grabber
            header

            if store.isCartEmpty {
                emptyState
            } else {
                lineList
                checkoutFooter
            }
        }
        .background(Palette.surfaceContainerLowest)
        .clipShape(
            .rect(
                topLeadingRadius: Radius.xl,
                bottomLeadingRadius: 0,
                bottomTrailingRadius: 0,
                topTrailingRadius: Radius.xl,
                style: .continuous
            )
        )
        .elevation3()
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.hidden)
        .presentationCornerRadius(Radius.xl)
        .presentationBackground(Palette.surfaceContainerLowest)
    }

    // MARK: - Chrome

    private var grabber: some View {
        Capsule(style: .continuous)
            .fill(Palette.surfaceContainerHighest)
            .frame(width: 40, height: 4)
            .padding(.top, Spacing.sm)
            .padding(.bottom, Spacing.xs)
            .accessibilityHidden(true)
    }

    private var header: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 0) {
                Text("Tu carrito")
                    .typeStyle(TypeScale.headlineMD)
                    .foregroundStyle(Palette.onSurface)

                Text(itemCountLabel)
                    .typeStyle(TypeScale.bodySM)
                    .foregroundStyle(Palette.secondary)
            }

            Spacer(minLength: Spacing.sm)

            Button {
                store.isCartPresented = false
            } label: {
                Icon(.close, size: 20, color: Palette.onSurfaceVariant)
                    .frame(width: Metrics.iconButtonLarge, height: Metrics.iconButtonLarge)
                    .background(Palette.surfaceContainerLow, in: Circle())
                    .contentShape(Circle())
            }
            .buttonStyle(PressableButtonStyle())
            .accessibilityLabel("Cerrar carrito")
        }
        .padding(.horizontal, Spacing.margin)
        .padding(.vertical, Spacing.sm)
    }

    private var itemCountLabel: String {
        let n = store.cartItemCount
        return n == 1 ? "1 artículo" : "\(n) artículos"
    }

    // MARK: - Lines

    private var lineList: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: Spacing.sm) {
                ForEach(store.cartLines) { line in
                    CartLineRow(
                        line: line,
                        onIncrement: { store.add(line.dish, from: restaurant(for: line)) },
                        onDecrement: { store.remove(line.dish) },
                        onDelete: { store.delete(line.dish) }
                    )
                }
            }
            .padding(.horizontal, Spacing.margin)
            .padding(.vertical, Spacing.sm)
        }
    }

    /// Rebuilds the originating `Restaurant` for a cart line so the store's
    /// `add(_:from:)` intent can be reused from inside the sheet.
    private func restaurant(for line: CartLine) -> Restaurant {
        SampleData.restaurants.first { $0.name == line.restaurantName }
            ?? SampleData.restaurants[0]
    }

    // MARK: - Footer

    private var checkoutFooter: some View {
        VStack(spacing: Spacing.sm) {
            Divider().overlay(Palette.surfaceContainerHigh)

            HStack {
                Text("Subtotal")
                    .typeStyle(TypeScale.bodyMD)
                    .foregroundStyle(Palette.secondary)

                Spacer()

                Text(store.cartSubtotalLabel)
                    .typeStyle(TypeScale.headlineSM)
                    .fontWeight(.bold)
                    .foregroundStyle(Palette.onSurface)
                    .monospacedDigit()
            }

            HStack(spacing: Spacing.xs) {
                Icon(.localShipping, size: 16, color: Palette.primary)
                Text(deliveryNote)
                    .typeStyle(TypeScale.bodySM)
                    .foregroundStyle(Palette.secondary)
                Spacer()
            }

            Button {
                store.isCartPresented = false
            } label: {
                HStack(spacing: Spacing.sm) {
                    Text("Tramitar pedido")
                        .typeStyle(TypeScale.labelLG)
                        .fontWeight(.bold)
                        .foregroundStyle(Palette.onPrimary)

                    Spacer(minLength: Spacing.sm)

                    Text(store.cartSubtotalLabel)
                        .typeStyle(TypeScale.labelLG)
                        .fontWeight(.bold)
                        .foregroundStyle(Palette.onPrimary)
                        .monospacedDigit()
                }
                .padding(.horizontal, Spacing.lg)
                .frame(height: Metrics.primaryButtonHeight)
                .background(Palette.primary, in: Capsule(style: .continuous))
                .contentShape(Capsule(style: .continuous))
            }
            .buttonStyle(PressableButtonStyle(pressedScale: 0.98))
            .accessibilityLabel("Tramitar pedido por \(store.cartSubtotalLabel)")
        }
        .padding(.horizontal, Spacing.margin)
        .padding(.top, Spacing.sm)
        .padding(.bottom, Spacing.md)
        .background(Palette.surfaceContainerLowest)
    }

    private var deliveryNote: String {
        let allFree = store.cartLines.allSatisfy { line in
            SampleData.restaurants
                .first { $0.name == line.restaurantName }?
                .hasFreeDelivery ?? false
        }
        return allFree ? "Envío gratis en este pedido" : "Gastos de envío calculados al pagar"
    }

    // MARK: - Empty

    private var emptyState: some View {
        VStack(spacing: Spacing.sm) {
            Icon(.shoppingCart, size: 40, color: Palette.outline)

            Text("Tu carrito está vacío")
                .typeStyle(TypeScale.headlineSM)
                .foregroundStyle(Palette.onSurface)

            Text("Añade algo rico desde la pantalla de inicio.")
                .typeStyle(TypeScale.bodySM, alignment: .center)
                .foregroundStyle(Palette.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.xl)
        .padding(.horizontal, Spacing.margin)
    }
}

// MARK: - Line row

/// A cart row: thumbnail, name, unit price, quantity stepper and a delete action.
struct CartLineRow: View {

    let line: CartLine
    var onIncrement: () -> Void
    var onDecrement: () -> Void
    var onDelete: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Image(line.dish.imageName)
                .resizable()
                .scaledToFill()
                .frame(width: 56, height: 56)
                .clipShape(RoundedRectangle(cornerRadius: Radius.md, style: .continuous))
                .background(Palette.surfaceContainer)

            VStack(alignment: .leading, spacing: 2) {
                Text(line.dish.name)
                    .typeStyle(TypeScale.labelLG, lineLimit: 1)
                    .foregroundStyle(Palette.onSurface)

                Text(line.restaurantName)
                    .typeStyle(TypeScale.bodySM, lineLimit: 1)
                    .foregroundStyle(Palette.secondary)

                Text(PriceFormatter.euro(cents: line.subtotalCents))
                    .typeStyle(TypeScale.labelMD)
                    .fontWeight(.bold)
                    .foregroundStyle(Palette.primary)
                    .monospacedDigit()
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            VStack(alignment: .trailing, spacing: Spacing.sm) {
                QuantityStepper(
                    quantity: line.quantity,
                    dishName: line.dish.name,
                    onIncrement: onIncrement,
                    onDecrement: onDecrement,
                    onDelete: onDelete
                )
            }
        }
        .padding(Spacing.sm)
        .background(
            Palette.surfaceContainerLow,
            in: RoundedRectangle(cornerRadius: Radius.lg, style: .continuous)
        )
        .accessibilityElement(children: .contain)
    }
}

// MARK: - Stepper

/// DESIGN.md → "Secondary Stepper Button": a pill in the soft graphite charcoal
/// (`#1F2937`) with white `−` / `+` symbols flanking the quantity. At a quantity
/// of one the minus becomes a delete affordance.
struct QuantityStepper: View {

    let quantity: Int
    /// Name of the dish this stepper controls, used for accessibility labels.
    let dishName: String
    var onIncrement: () -> Void
    var onDecrement: () -> Void
    var onDelete: () -> Void

    /// `#1F2937` — the "soft graphite charcoal" the spec names for steppers.
    private let stepperFill = Color(hex: 0x1F2937)

    var body: some View {
        HStack(spacing: Spacing.sm) {
            Button(action: quantity <= 1 ? onDelete : onDecrement) {
                Icon(
                    quantity <= 1 ? .delete : .remove,
                    size: 16,
                    color: Palette.onPrimary
                )
                .frame(width: 28, height: 28)
                .contentShape(Circle())
            }
            .buttonStyle(PressableButtonStyle(pressedScale: 0.88))
            .accessibilityLabel(quantity <= 1
                                ? "Eliminar \(dishName) del carrito"
                                : "Quitar una unidad de \(dishName)")

            Text("\(quantity)")
                .typeStyle(TypeScale.labelLG)
                .fontWeight(.bold)
                .foregroundStyle(Palette.onPrimary)
                .monospacedDigit()
                .frame(minWidth: 18)

            Button(action: onIncrement) {
                Icon(.add, size: 16, color: Palette.onPrimary)
                    .frame(width: 28, height: 28)
                    .contentShape(Circle())
            }
            .buttonStyle(PressableButtonStyle(pressedScale: 0.88))
            .accessibilityLabel("Añadir una unidad de \(dishName)")
        }
        .padding(.horizontal, Spacing.sm)
        .padding(.vertical, 4)
        .background(stepperFill, in: Capsule(style: .continuous))
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Cantidad de \(dishName): \(quantity)")
    }
}

// MARK: - Preview

#Preview("CartSheet") {
    struct Harness: View {
        @State private var store = {
            let s = AppStore()
            let r = SampleData.restaurants[0]
            s.add(r.bestsellers[0], from: r)
            s.add(r.bestsellers[0], from: r)
            s.add(r.bestsellers[1], from: r)
            return s
        }()
        var body: some View {
            Color.clear
                .sheet(isPresented: .constant(true)) {
                    CartSheet(store: store)
                }
        }
    }
    return Harness()
}

#Preview("CartSheet — empty") {
    CartSheet(store: AppStore())
}
