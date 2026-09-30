//
//  ModeSwitcher.swift
//  FreshHarvest
//
//  The Delivery / "Para recoger / Retirar" segmented control.
//
//  Source markup:
//  `<div class="bg-surface-container p-1 rounded-full flex items-center relative">`
//  with an active pill styled `bg-surface-container-lowest text-on-surface
//  shadow-sm font-bold` and inactive tabs `text-secondary font-semibold`.
//
//  The active pill is a single matched-geometry view that slides between the two
//  segments, so the transition reads as one continuous object rather than a
//  cross-fade — the same impression the CSS transition gives on the web.
//

import SwiftUI

struct ModeSwitcher: View {

    @Binding var mode: DeliveryMode

    @Namespace private var pillNamespace

    var body: some View {
        HStack(spacing: 0) {
            ForEach(DeliveryMode.allCases) { option in
                segment(for: option)
            }
        }
        .padding(4)                                  // `p-1`
        .background(Palette.surfaceContainer, in: Capsule(style: .continuous))
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Tipo de servicio")
    }

    private func segment(for option: DeliveryMode) -> some View {
        let isSelected = mode == option

        return Button {
            withAnimation(.easeInOut(duration: 0.2)) { mode = option }
        } label: {
            HStack(spacing: 6) {                     // `gap-1.5`
                Icon(
                    option.icon,
                    size: 18,
                    color: isSelected ? Palette.primary : Palette.secondary
                )
                Text(option.title)
                    .typeStyle(TypeScale.labelMD)
                    .foregroundStyle(isSelected ? Palette.onSurface : Palette.secondary)
                    .fontWeight(isSelected ? .bold : nil)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)                   // `py-2`
            .background {
                if isSelected {
                    Capsule(style: .continuous)
                        .fill(Palette.surfaceContainerLowest)
                        .matchedGeometryEffect(id: "modePill", in: pillNamespace)
                        .elevation1()
                }
            }
            .contentShape(Capsule(style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
        .accessibilityLabel(option.title)
    }
}

#Preview("ModeSwitcher") {
    struct Harness: View {
        @State private var mode: DeliveryMode = .delivery
        var body: some View {
            VStack(spacing: Spacing.lg) {
                ModeSwitcher(mode: $mode)
                Text("Modo: \(mode.title)")
                    .typeStyle(TypeScale.bodyMD)
                    .foregroundStyle(Palette.secondary)
            }
            .padding(Spacing.margin)
            .background(Palette.surface)
        }
    }
    return Harness()
}
