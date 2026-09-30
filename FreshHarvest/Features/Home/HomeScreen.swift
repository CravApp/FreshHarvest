//
//  HomeScreen.swift
//  FreshHarvest
//
//  The delivered screen: sticky header, search + filters, service-mode switcher,
//  promo banner, category rail, quick filters and the restaurant feed, with the
//  floating cart bar and bottom navigation docked over the content.
//
//  Source markup structure:
//  `<main class="flex-1 flex flex-col relative w-full pt-16 pb-28 bg-surface
//    px-margin"><div class="flex flex-col w-full gap-space-md">…`
//
//  Two layout details are worth calling out because they are easy to get wrong:
//  - `px-margin` sits on `<main>` (20px), while the category rail and filter
//    strip use `-mx-margin` to bleed back out to the screen edges. Here the
//    20px inset is applied per-section, and the two rails own their own
//    horizontal padding so they scroll edge-to-edge.
//  - `pt-16 pb-28` reserve room for the fixed header (64) and the fixed nav
//    (112). The scroll content uses matching top/bottom insets.
//

import SwiftUI

struct HomeScreen: View {

    @Bindable var store: AppStore

    /// Bound to the bottom navigation so the dock reflects the active tab.
    @Binding var selectedTab: AppTab

    var body: some View {
        ZStack(alignment: .top) {

            Palette.surface.ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: Spacing.md) {    // `gap-space-md`
                    SearchBar(text: $store.searchText)

                    ModeSwitcher(mode: $store.mode)

                    PromoBanner(promo: SampleData.promo)

                    CategoryRail(
                        categories: SampleData.categories,
                        selectedID: store.selectedCategoryID,
                        onSelect: store.selectCategory
                    )

                    QuickFilterStrip(
                        filters: SampleData.quickFilters,
                        isActive: store.isFilterActive,
                        onToggle: store.toggleFilter
                    )

                    restaurantFeed
                }
                .padding(.top, Spacing.xs)                            // `pt-space-xs` on the search row
                .padding(.bottom, Metrics.scrollBottomInset)
            }
            // Reserve the fixed header's height at the top of the scroll view.
            .safeAreaPadding(.top, Metrics.headerHeight)

            // Fixed chrome.
            VStack(spacing: 0) {
                HeaderBar(address: SampleData.address)
                Spacer()
            }

            VStack(spacing: 0) {
                Spacer()
                bottomChrome
            }
        }
        .background(Palette.surface)
    }

    // MARK: - Feed

    @ViewBuilder
    private var restaurantFeed: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            SectionHeader(
                title: "Restaurantes populares",
                subtitle: "Los favoritos cerca de tu ubicación",
                actionTitle: "Ver todos"
            )
            .padding(.horizontal, Spacing.margin)

            if store.visibleRestaurants.isEmpty {
                emptyState
                    .padding(.horizontal, Spacing.margin)
            } else {
                VStack(spacing: Spacing.gutter) {                 // `gap-1rem`
                    ForEach(store.visibleRestaurants) { restaurant in
                        RestaurantCard(
                            restaurant: restaurant,
                            isFavourite: store.isFavourite(restaurant),
                            quantityFor: store.quantity,
                            justAdded: { store.justAddedDishIDs.contains($0.id) },
                            onFavouriteTap: { store.toggleFavourite(restaurant) },
                            onAdd: { dish in store.add(dish, from: restaurant) }
                        )
                    }
                }
                .padding(.horizontal, Spacing.margin)
            }
        }
        .padding(.top, Spacing.xs)                                // `mt-space-xs`
    }

    private var emptyState: some View {
        VStack(spacing: Spacing.sm) {
            Icon(.search, size: 32, color: Palette.outline)

            Text("Sin resultados")
                .typeStyle(TypeScale.headlineSM)
                .foregroundStyle(Palette.onSurface)

            Text("Prueba con otra búsqueda o quita algún filtro.")
                .typeStyle(TypeScale.bodySM, alignment: .center)
                .foregroundStyle(Palette.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.xl)
    }

    // MARK: - Bottom chrome

    private var bottomChrome: some View {
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
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }

            BottomNavBar(selection: $selectedTab)
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: store.isCartEmpty)
    }
}

#Preview("HomeScreen") {
    struct Harness: View {
        @State private var store = AppStore()
        @State private var tab: AppTab = .home
        var body: some View {
            HomeScreen(store: store, selectedTab: $tab)
        }
    }
    return Harness()
}

#Preview("HomeScreen — empty search") {
    struct Harness: View {
        @State private var store = {
            let s = AppStore()
            s.searchText = "zzz"
            return s
        }()
        @State private var tab: AppTab = .home
        var body: some View {
            HomeScreen(store: store, selectedTab: $tab)
        }
    }
    return Harness()
}
