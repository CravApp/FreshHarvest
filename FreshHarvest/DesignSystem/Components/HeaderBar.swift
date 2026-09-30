//
//  HeaderBar.swift
//  FreshHarvest
//
//  Sticky top bar: brand mark, delivery-address button, notifications with an
//  unread dot, and the profile avatar.
//
//  Source markup:
//  `<header class="fixed top-0 inset-x-0 z-50 bg-surface/85 backdrop-blur-xl
//    shadow-[0_1px_12px_rgba(0,0,0,0.03)] pt-safe">` with an inner
//  `<div class="h-16 px-margin flex items-center justify-between gap-space-sm">`.
//
//  The `bg-surface/85` + `backdrop-blur-xl` pair becomes `.ultraThinMaterial`
//  over a translucent surface tint so scrolling content blurs behind the bar.
//

import SwiftUI

struct HeaderBar: View {

    let address: DeliveryAddress
    var onAddressTap: () -> Void = {}
    var onNotificationsTap: () -> Void = {}
    var onProfileTap: () -> Void = {}

    var body: some View {
        HStack(spacing: Spacing.sm) {

            // Left: brand mark + address button.
            HStack(spacing: Spacing.sm) {
                LogoMark(size: 32)

                Button(action: onAddressTap) {
                    VStack(alignment: .leading, spacing: 0) {
                        HStack(spacing: Spacing.xs) {
                            Text("Entrega en")
                                .typeStyle(TypeScale.eyebrow)
                                .textCase(.uppercase)
                                .foregroundStyle(Palette.primary)

                            Icon(.keyboardArrowDown, size: 16, color: Palette.primary)
                        }

                        Text(address.display)
                            .typeStyle(TypeScale.headlineSM, lineLimit: 1)
                            .foregroundStyle(Palette.onSurface)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Entrega en \(address.display)")
                .accessibilityHint("Cambiar dirección de entrega")
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // Right: notifications + avatar.
            HStack(spacing: Spacing.xs) {
                Button(action: onNotificationsTap) {
                    Icon(.notifications, size: 24, color: Palette.onSurfaceVariant)
                        .frame(width: Metrics.iconButtonTapArea, height: Metrics.iconButtonTapArea)
                        .overlay(alignment: .topTrailing) {
                            Circle()
                                .fill(Palette.error)
                                .frame(width: 10, height: 10)
                                .overlay(Circle().stroke(Palette.surface, lineWidth: 2))
                                .padding(.top, 8)
                                .padding(.trailing, 8)
                        }
                        .contentShape(Circle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Notificaciones")
                .accessibilityHint("Tienes notificaciones sin leer")

                Button(action: onProfileTap) {
                    Image("avatar")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 32, height: 32)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Palette.primary.opacity(0.20), lineWidth: 2))
                        .frame(width: Metrics.iconButtonTapArea, height: Metrics.iconButtonTapArea)
                        .contentShape(Circle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Perfil")
            }
            .fixedSize(horizontal: true, vertical: false)
        }
        .padding(.horizontal, Spacing.margin)
        .frame(height: Metrics.headerHeight)
        .background {
            // `bg-surface/85` + `backdrop-blur-xl`.
            Palette.surface.opacity(0.85)
                .background(.ultraThinMaterial)
                .ignoresSafeArea(edges: .top)
        }
        .elevationHairline()
    }
}

#Preview("Header") {
    VStack(spacing: 0) {
        HeaderBar(address: SampleData.address)
        Spacer()
    }
    .background(Palette.surface)
}
