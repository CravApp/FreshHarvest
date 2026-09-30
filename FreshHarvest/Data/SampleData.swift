//
//  SampleData.swift
//  FreshHarvest
//
//  The exact content of the source design, transcribed. Every string, price,
//  rating and asset name matches `code.html` so the conversion can be diffed.
//

import SwiftUI

enum SampleData {

    static let address = DeliveryAddress(street: "Calle Gran Vía, 42", city: "Madrid")

    /// Promo banner copy.
    static let promo = Promo(
        code: "CÓDIGO: FRESH2X1",
        headline: "2x1 en Bowls y Ensaladas",
        subtitle: "Ingredientes de huerto orgánico recién cosechados.",
        eta: "Llega en ~25 min",
        cta: "Aprovechar"
    )

    struct Promo {
        let code: String
        let headline: String
        let subtitle: String
        let eta: String
        let cta: String
    }

    /// Category rail — first tile is selected in the design.
    static let categories: [FoodCategory] = [
        FoodCategory(id: "bowls",   name: "Bowls & Fit",  icon: .eco,           tint: .primary),
        FoodCategory(id: "burgers", name: "Burgers",      icon: .lunchDining,   tint: .tertiary),
        FoodCategory(id: "pizza",   name: "Pizza",        icon: .localPizza,    tint: .tertiaryContainer),
        FoodCategory(id: "sushi",   name: "Sushi",        icon: .setMeal,       tint: .primary),
        FoodCategory(id: "mexican", name: "Mexicana",     icon: .bakeryDining,  tint: .error),
        FoodCategory(id: "coffee",  name: "Café & Dulce", icon: .coffee,        tint: .tertiary),
        FoodCategory(id: "fresh",   name: "Frescos",      icon: .storefront,    tint: .primary),
    ]

    /// Quick-filter chips.
    static let quickFilters: [QuickFilter] = [
        QuickFilter(id: "near",     title: "Más cercanos",     icon: .nearMe,        tint: Palette.primary,            filled: false),
        QuickFilter(id: "rated",    title: "Calificación 4.5+", icon: .star,         tint: Palette.tertiaryContainer,   filled: true),
        QuickFilter(id: "free",     title: "Envío gratis",     icon: .electricMoped, tint: Palette.primary,            filled: false),
        QuickFilter(id: "promos",   title: "Promociones",      icon: .localOffer,    tint: Palette.error,              filled: false),
    ]

    /// Restaurant feed.
    static let restaurants: [Restaurant] = [
        Restaurant(
            id: "green-bowl-deli",
            name: "Green Bowl Deli",
            cuisineSummary: "Saludable • Poke • Ensaladas • $$",
            rating: 4.9,
            reviewCountLabel: "1.4k",
            etaLabel: "20-30 min",
            promoLabel: "Envío gratis",
            promoStyle: .freeDelivery,
            deliveryFeeCents: nil,
            distanceLabel: "a 0.8 km",
            imageName: "photo_greenbowl",
            bestsellerTitle: "Más vendidos",
            bestsellers: [
                Dish(id: "poke",  name: "Salmon Avocado Poke", priceCents: 1290, imageName: "dish_poke"),
                Dish(id: "kale",  name: "Super Green Kale Bowl", priceCents: 1050, imageName: "dish_kale"),
            ]
        ),
        Restaurant(
            id: "artisan-burger-lab",
            name: "Artisan Burger Lab",
            cuisineSummary: "Hamburguesas • Gourmet • Patatas • $$",
            rating: 4.8,
            reviewCountLabel: "2.1k",
            etaLabel: "25-35 min",
            promoLabel: "30% OFF",
            promoStyle: .discount,
            deliveryFeeCents: 180,
            distanceLabel: "a 1.4 km",
            imageName: "photo_burger",
            bestsellerTitle: "Más vendido",
            bestsellers: [
                Dish(id: "truffle", name: "Truffle Smash Burger", priceCents: 1350, imageName: "dish_truffle"),
            ]
        ),
        Restaurant(
            id: "nipon-sushi-bar",
            name: "Nipon Sushi Bar",
            cuisineSummary: "Japonés • Sushi • Makis • $$$",
            rating: 4.7,
            reviewCountLabel: "980",
            etaLabel: "30-45 min",
            promoLabel: "Envío gratis",
            promoStyle: .freeDelivery,
            deliveryFeeCents: nil,
            distanceLabel: "a 2.1 km",
            imageName: "photo_sushi",
            bestsellerTitle: "Más vendido",
            bestsellers: [
                Dish(id: "combo-tokyo", name: "Combo Tokyo (16 piezas)", priceCents: 1890, imageName: "dish_combo"),
            ]
        ),
    ]

    /// Bottom navigation destinations.
    static let tabs: [AppTab] = AppTab.allCases
}

// MARK: - Bottom navigation

enum AppTab: String, CaseIterable, Identifiable {
    case home, explore, orders, favorites, profile

    var id: String { rawValue }

    var title: String {
        switch self {
        case .home:      return "Inicio"
        case .explore:   return "Explorar"
        case .orders:    return "Pedidos"
        case .favorites: return "Favoritos"
        case .profile:   return "Perfil"
        }
    }

    var icon: MaterialIcon {
        switch self {
        case .home:      return .home
        case .explore:   return .explore
        case .orders:    return .receiptLong
        case .favorites: return .favorite
        case .profile:   return .person
        }
    }
}
