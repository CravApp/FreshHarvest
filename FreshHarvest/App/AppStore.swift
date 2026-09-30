//
//  AppStore.swift
//  FreshHarvest
//
//  Single observable source of truth for the screen's interactive state. The
//  original page held this in loose DOM listeners; here it is a typed store so
//  every micro-interaction is testable and the views stay declarative.
//
//  Behaviour ported one-for-one from the source `<script>` block:
//  - Delivery / pickup switcher.
//  - Favourite heart toggle (outline ⇄ filled, secondary ⇄ error tint).
//  - Quick-add button: briefly shows a check mark, then reverts.
//  - Quick-filter chips toggle between surface and emerald fills.
//

import SwiftUI
import Observation

/// Main-actor isolated so the deferred "just added" revert can safely mutate
/// state from inside a `Task` without tripping strict-concurrency checks.
@MainActor
@Observable
final class AppStore {

    // MARK: - State

    /// Selected service mode.
    var mode: DeliveryMode = .delivery

    /// Search field contents.
    var searchText: String = ""

    /// Currently selected category, or `nil` when the rail shows no selection.
    var selectedCategoryID: String? = SampleData.categories.first?.id

    /// Ids of the active quick filters.
    var activeFilterIDs: Set<String> = []

    /// Ids of favourited restaurants.
    var favouriteRestaurantIDs: Set<String> = []

    /// Dishes currently in the cart, keyed by dish id.
    var cart: [String: CartLine] = [:]

    /// `true` while the cart sheet is presented.
    var isCartPresented = false

    /// Ids of dishes whose quick-add button is showing its "added" confirmation.
    var justAddedDishIDs: Set<String> = []

    // MARK: - Derived

    /// Total number of items in the cart.
    var cartItemCount: Int { cart.values.reduce(0) { $0 + $1.quantity } }

    /// Cart subtotal in cents.
    var cartSubtotalCents: Int { cart.values.reduce(0) { $0 + $1.subtotalCents } }

    /// Cart lines in a stable display order.
    var cartLines: [CartLine] { cart.values.sorted { $0.dish.name < $1.dish.name } }

    var isCartEmpty: Bool { cart.isEmpty }

    /// Formatted subtotal, e.g. `"23,40 €"`.
    var cartSubtotalLabel: String { PriceFormatter.euro(cents: cartSubtotalCents) }

    /// Restaurants matching the current search text and filters. Used by the
    /// feed so search and chips actually do something.
    var visibleRestaurants: [Restaurant] {
        SampleData.restaurants.filter { restaurant in
            guard matchesSearch(restaurant) else { return false }
            guard matchesFilters(restaurant) else { return false }
            guard matchesCategory(restaurant) else { return false }
            return true
        }
    }

    private func matchesSearch(_ restaurant: Restaurant) -> Bool {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !query.isEmpty else { return true }
        let haystack = [
            restaurant.name,
            restaurant.cuisineSummary,
            restaurant.bestsellers.map(\.name).joined(separator: " "),
        ].joined(separator: " ").lowercased()
        return haystack.contains(query)
    }

    private func matchesFilters(_ restaurant: Restaurant) -> Bool {
        for id in activeFilterIDs {
            switch id {
            case "near":   if distanceKilometres(restaurant.distanceLabel) > 1.0 { return false }
            case "rated":  if restaurant.rating < 4.5 { return false }
            case "free":   if !restaurant.hasFreeDelivery { return false }
            case "promos": if restaurant.promoLabel == nil { return false }
            default: break
            }
        }
        return true
    }

    private func matchesCategory(_ restaurant: Restaurant) -> Bool {
        guard let id = selectedCategoryID else { return true }
        switch id {
        case "bowls":   return restaurant.id == "green-bowl-deli"
        case "burgers": return restaurant.id == "artisan-burger-lab"
        case "sushi":   return restaurant.id == "nipon-sushi-bar"
        case "fresh":   return restaurant.id == "green-bowl-deli"
        // Categories with no matching restaurant in the sample data still return
        // everything, so the rail never produces a dead-end empty state.
        default:        return true
        }
    }

    /// Parses `"a 0.8 km"` → `0.8`.
    private func distanceKilometres(_ label: String) -> Double {
        let digits = label.filter { $0.isNumber || $0 == "." || $0 == "," }
        return Double(digits.replacingOccurrences(of: ",", with: ".")) ?? 0
    }

    // MARK: - Intents

    func setMode(_ newMode: DeliveryMode) {
        withAnimation(.easeInOut(duration: 0.2)) { mode = newMode }
    }

    func selectCategory(_ category: FoodCategory) {
        withAnimation(.easeInOut(duration: 0.2)) {
            selectedCategoryID = (selectedCategoryID == category.id) ? nil : category.id
        }
    }

    func toggleFilter(_ filter: QuickFilter) {
        withAnimation(.easeInOut(duration: 0.2)) {
            if activeFilterIDs.contains(filter.id) {
                activeFilterIDs.remove(filter.id)
            } else {
                activeFilterIDs.insert(filter.id)
            }
        }
    }

    func isFilterActive(_ filter: QuickFilter) -> Bool { activeFilterIDs.contains(filter.id) }

    func isFavourite(_ restaurant: Restaurant) -> Bool { favouriteRestaurantIDs.contains(restaurant.id) }

    func toggleFavourite(_ restaurant: Restaurant) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            if favouriteRestaurantIDs.contains(restaurant.id) {
                favouriteRestaurantIDs.remove(restaurant.id)
            } else {
                favouriteRestaurantIDs.insert(restaurant.id)
            }
        }
    }

    func quantity(of dish: Dish) -> Int { cart[dish.id]?.quantity ?? 0 }

    /// Adds one unit and flashes the confirmation state on the button.
    func add(_ dish: Dish, from restaurant: Restaurant) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            if var line = cart[dish.id] {
                line.quantity += 1
                cart[dish.id] = line
            } else {
                cart[dish.id] = CartLine(dish: dish, restaurantName: restaurant.name, quantity: 1)
            }
            justAddedDishIDs.insert(dish.id)
        }
        // Reverts after 1.2s, matching the source `setTimeout(…, 1200)`.
        Task { [weak self] in
            try? await Task.sleep(nanoseconds: 1_200_000_000)
            guard let self else { return }
            withAnimation(.easeOut(duration: 0.2)) { _ = self.justAddedDishIDs.remove(dish.id) }
        }
    }

    func remove(_ dish: Dish) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            guard var line = cart[dish.id] else { return }
            line.quantity -= 1
            if line.quantity <= 0 { cart[dish.id] = nil } else { cart[dish.id] = line }
        }
    }

    func delete(_ dish: Dish) {
        withAnimation(.easeInOut(duration: 0.2)) { cart[dish.id] = nil }
    }

    func clearCart() {
        withAnimation(.easeInOut(duration: 0.2)) { cart.removeAll() }
    }
}
