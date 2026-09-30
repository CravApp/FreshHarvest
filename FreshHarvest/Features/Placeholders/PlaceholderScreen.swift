//
//  PlaceholderScreen.swift
//  FreshHarvest
//
//  The source design only delivers the `Inicio` tab. The remaining four
//  destinations are wired up so the bottom navigation is fully functional, and
//  each one is built from the same tokens/components rather than left blank —
//  this keeps the design system exercised and gives a clear starting point for
//  the next screens.
//

import SwiftUI

struct PlaceholderScreen: View {

    let tab: AppTab
    @Bindable var store: AppStore
    @Binding var selectedTab: AppTab

    var body: some View {
        ZStack(alignment: .top) {
            Palette.surface.ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: Spacing.md) {
                    content
                }
                .padding(.horizontal, Spacing.margin)
                .padding(.bottom, Metrics.scrollBottomInset)
            }
            .safeAreaPadding(.top, Metrics.headerHeight)

            VStack(spacing: 0) {
                HeaderBar(address: SampleData.address)
                Spacer()
            }

            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 0) {
                    if !store.isCartEmpty {
                        FloatingCartBar(
                            itemCount: store.cartItemCount,
                            subtotalLabel: store.cartSubtotalLabel
                        ) {
                            store.isCartPresented = true
                        }
                        .padding(.horizontal, Spacing.margin)
                        .padding(.bottom, Spacing.sm)
                    }

                    BottomNavBar(selection: $selectedTab)
                }
            }
        }
        .background(Palette.surface)
    }

    // MARK: - Per-tab content

    @ViewBuilder
    private var content: some View {
        switch tab {
        case .home:
            EmptyView()

        case .explore:
            SectionHeader(title: "Explorar",
                          subtitle: "Descubre restaurantes y tiendas cerca de ti")
            card {
                chipCloud
            }

        case .orders:
            SectionHeader(title: "Pedidos", subtitle: "Tu historial de pedidos")
            card {
                infoRow(icon: .receiptLong, title: "Sin pedidos todavía",
                        detail: "Cuando hagas tu primer pedido aparecerá aquí.")
            }

        case .favorites:
            SectionHeader(title: "Favoritos",
                          subtitle: "Los restaurantes que has guardado")
            if store.favouriteRestaurantIDs.isEmpty {
                card {
                    infoRow(icon: .favorite, title: "Aún no tienes favoritos",
                            detail: "Toca el corazón en cualquier restaurante para guardarlo.")
                }
            } else {
                VStack(spacing: Spacing.gutter) {
                    ForEach(SampleData.restaurants.filter { store.favouriteRestaurantIDs.contains($0.id) }) { restaurant in
                        RestaurantCard(
                            restaurant: restaurant,
                            isFavourite: true,
                            quantityFor: store.quantity,
                            justAdded: { store.justAddedDishIDs.contains($0.id) },
                            onFavouriteTap: { store.toggleFavourite(restaurant) },
                            onAdd: { dish in store.add(dish, from: restaurant) }
                        )
                    }
                }
            }

        case .profile:
            SectionHeader(title: "Perfil", subtitle: "Tu cuenta y preferencias")
            card {
                VStack(spacing: 0) {
                    profileHeader
                    Divider().overlay(Palette.surfaceContainerHigh).padding(.vertical, Spacing.sm)
                    settingRow(icon: .locationOn, title: "Direcciones de entrega", detail: SampleData.address.display)
                    settingRow(icon: .creditCard, title: "Métodos de pago", detail: "Visa •••• 4242")
                    settingRow(icon: .redeem, title: "Puntos Fresh", detail: "340 puntos")
                    settingRow(icon: .language, title: "Idioma", detail: "Español")
                    settingRow(icon: .help, title: "Ayuda", detail: nil)
                }
            }
        }
    }

    // MARK: - Building blocks

    private func card<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        content()
            .padding(Spacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Palette.cardSurface)
            .clipShape(RoundedRectangle(cornerRadius: Radius.lg, style: .continuous))
            .elevation1()
    }

    private var chipCloud: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("Categorías")
                .eyebrowStyle()

            FlowLayout(spacing: Spacing.sm) {
                ForEach(SampleData.categories) { category in
                    HStack(spacing: 6) {
                        Icon(category.icon, size: 16, color: category.tint.color)
                        Text(category.name)
                            .typeStyle(TypeScale.labelMD)
                            .foregroundStyle(Palette.onSurface)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background(Palette.surfaceContainerLow, in: Capsule(style: .continuous))
                }
            }
        }
    }

    private func infoRow(icon: MaterialIcon, title: String, detail: String) -> some View {
        HStack(alignment: .top, spacing: Spacing.md) {
            Icon(icon, size: 24, color: Palette.primary)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .typeStyle(TypeScale.labelLG)
                    .foregroundStyle(Palette.onSurface)

                Text(detail)
                    .typeStyle(TypeScale.bodySM)
                    .foregroundStyle(Palette.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var profileHeader: some View {
        HStack(spacing: Spacing.md) {
            Image("avatar")
                .resizable()
                .scaledToFill()
                .frame(width: 56, height: 56)
                .clipShape(Circle())
                .overlay(Circle().stroke(Palette.primary.opacity(0.20), lineWidth: 2))

            VStack(alignment: .leading, spacing: 2) {
                Text("Alex Rivera")
                    .typeStyle(TypeScale.headlineSM)
                    .foregroundStyle(Palette.onSurface)

                Text(SampleData.address.display)
                    .typeStyle(TypeScale.bodySM)
                    .foregroundStyle(Palette.secondary)
            }

            Spacer(minLength: 0)

            HStack(spacing: Spacing.xs) {
                Icon(.star, size: 14, color: Palette.tertiary, filled: true)
                Text("4.9")
                    .typeStyle(TypeScale.labelMD)
                    .fontWeight(.bold)
                    .foregroundStyle(Palette.tertiary)
            }
            .padding(.horizontal, Spacing.sm)
            .padding(.vertical, Spacing.xs)
            .background(
                Palette.tertiaryFixed.opacity(0.40),
                in: RoundedRectangle(cornerRadius: Radius.standard, style: .continuous)
            )
        }
    }

    private func settingRow(icon: MaterialIcon, title: String, detail: String?) -> some View {
        HStack(spacing: Spacing.md) {
            Icon(icon, size: 22, color: Palette.onSurfaceVariant)

            Text(title)
                .typeStyle(TypeScale.bodyMD)
                .foregroundStyle(Palette.onSurface)

            Spacer(minLength: Spacing.sm)

            if let detail {
                Text(detail)
                    .typeStyle(TypeScale.bodySM, lineLimit: 1)
                    .foregroundStyle(Palette.secondary)
            }

            Icon(.chevronRight, size: 18, color: Palette.outline)
        }
        .padding(.vertical, 10)
        .contentShape(Rectangle())
    }
}

// MARK: - Flow layout

/// Minimal wrapping `HStack` used by the Explore chip cloud. Lays children out
/// left-to-right and wraps to a new row when the available width is exhausted.
struct FlowLayout: Layout {

    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var rowWidth: CGFloat = 0
        var rowHeight: CGFloat = 0
        var totalHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if rowWidth > 0, rowWidth + spacing + size.width > maxWidth {
                totalHeight += rowHeight + spacing
                rowWidth = size.width
                rowHeight = size.height
            } else {
                rowWidth += (rowWidth > 0 ? spacing : 0) + size.width
                rowHeight = max(rowHeight, size.height)
            }
        }
        totalHeight += rowHeight
        return CGSize(width: maxWidth == .infinity ? rowWidth : maxWidth, height: totalHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX
        var y = bounds.minY
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x > bounds.minX, x + size.width > bounds.maxX {
                x = bounds.minX
                y += rowHeight + spacing
                rowHeight = 0
            }
            subview.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}

#Preview("Favoritos") {
    struct Harness: View {
        @State private var store = {
            let s = AppStore()
            s.favouriteRestaurantIDs = ["green-bowl-deli"]
            return s
        }()
        @State private var tab: AppTab = .favorites
        var body: some View {
            PlaceholderScreen(tab: .favorites, store: store, selectedTab: $tab)
        }
    }
    return Harness()
}

#Preview("Perfil") {
    struct Harness: View {
        @State private var store = AppStore()
        @State private var tab: AppTab = .profile
        var body: some View {
            PlaceholderScreen(tab: .profile, store: store, selectedTab: $tab)
        }
    }
    return Harness()
}
