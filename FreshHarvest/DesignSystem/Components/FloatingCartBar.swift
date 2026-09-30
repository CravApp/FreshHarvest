//
//  FloatingCartBar.swift
//  FreshHarvest
//
//  The floating cart / checkout dock described in DESIGN.md:
//
//  > Elevated floating pill docked above the system navigation bar. Contains
//  > dual-zone layouts: left-hand order subtotal and right-hand action
//  > ("Checkout", "View Cart") with a directional chevron.
//
//  It is not present in the static `code.html` render (the cart is empty on
//  first load), so this is the design system's own component applied in the
//  documented style: a Level 2 floating pill that only appears once the cart has
//  items, positioned just above the bottom navigation.
//

import SwiftUI

struct FloatingCartBar: View {

    let itemCount: Int
    let subtotalLabel: String
    var actionTitle: String = "Ver carrito"
    var onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: Spacing.md) {

                // Left zone — quantity + subtotal.
                HStack(spacing: Spacing.sm) {
                    ZStack {
                        Circle()
                            .fill(Palette.surfaceContainerLowest.opacity(0.22))
                            .frame(width: 36, height: 36)

                        Text("\(itemCount)")
                            .typeStyle(TypeScale.labelLG)
                            .fontWeight(.bold)
                            .foregroundStyle(Palette.onPrimary)
                            .monospacedDigit()
                    }

                    VStack(alignment: .leading, spacing: 0) {
                        Text("Subtotal")
                            .typeStyle(TypeScale.labelSM)
                            .foregroundStyle(Palette.onPrimary.opacity(0.85))

                        Text(subtotalLabel)
                            .typeStyle(TypeScale.headlineSM)
                            .fontWeight(.bold)
                            .foregroundStyle(Palette.onPrimary)
                            .monospacedDigit()
                    }
                }

                Spacer(minLength: Spacing.sm)

                // Right zone — action + chevron.
                HStack(spacing: Spacing.xs) {
                    Text(actionTitle)
                        .typeStyle(TypeScale.labelLG)
                        .fontWeight(.bold)
                        .foregroundStyle(Palette.onPrimary)

                    Icon(.arrowForward, size: 20, color: Palette.onPrimary)
                }
            }
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, 12)
            .background(Palette.primary, in: Capsule(style: .continuous))
            .elevation2()
            .contentShape(Capsule(style: .continuous))
        }
        .buttonStyle(PressableButtonStyle(pressedScale: 0.97))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Ver carrito, \(itemCount) artículos, subtotal \(subtotalLabel)")
        .accessibilityAddTraits(.isButton)
    }
}

#Preview("FloatingCartBar") {
    VStack(spacing: Spacing.lg) {
        FloatingCartBar(itemCount: 3, subtotalLabel: "36,30 €", onTap: {})
        FloatingCartBar(itemCount: 1, subtotalLabel: "12,90 €", actionTitle: "Tramitar pedido", onTap: {})
    }
    .padding(Spacing.margin)
    .background(Palette.surface)
}
