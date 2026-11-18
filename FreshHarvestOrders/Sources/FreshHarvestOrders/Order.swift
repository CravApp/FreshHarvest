//
//  Order.swift
//  FreshHarvestOrders
//
//  A delivery order, independent of SwiftUI so it can be tested on Linux.
//  Field mapping onto JSONPlaceholder lives in `OrderPostMapping`.
//

import Foundation

/// One dish in an order. Prices stay in euro cents, matching `Dish.priceCents`.
public struct OrderLine: Codable, Equatable, Sendable {
    public var dishId: String
    public var name: String
    public var quantity: Int
    public var unitPriceCents: Int
    public var restaurantName: String

    public init(
        dishId: String,
        name: String,
        quantity: Int,
        unitPriceCents: Int,
        restaurantName: String
    ) {
        self.dishId = dishId
        self.name = name
        self.quantity = quantity
        self.unitPriceCents = unitPriceCents
        self.restaurantName = restaurantName
    }

    public var subtotalCents: Int { unitPriceCents * quantity }
}

/// What the app sends when the customer taps "Tramitar pedido".
public struct OrderDraft: Equatable, Sendable {
    public var customerId: Int
    public var restaurantName: String
    public var lines: [OrderLine]
    /// `delivery` or `pickup`, matching `DeliveryMode.rawValue`.
    public var mode: String
    public var address: String

    public init(
        customerId: Int,
        restaurantName: String,
        lines: [OrderLine],
        mode: String,
        address: String
    ) {
        self.customerId = customerId
        self.restaurantName = restaurantName
        self.lines = lines
        self.mode = mode
        self.address = address
    }

    public var itemCount: Int { lines.reduce(0) { $0 + $1.quantity } }

    public var totalCents: Int { lines.reduce(0) { $0 + $1.subtotalCents } }

    /// Human summary stored in the post `title`, e.g. "Green Bowl Deli · 3 artículos".
    public var summary: String {
        let noun = itemCount == 1 ? "artículo" : "artículos"
        return "\(restaurantName) · \(itemCount) \(noun)"
    }

    public var formattedTotal: String { EuroFormat.string(cents: totalCents) }
}

/// An order as returned by the API, including the server-assigned id.
public struct Order: Equatable, Sendable {
    public var id: Int
    public var customerId: Int
    public var summary: String
    public var lines: [OrderLine]
    public var totalCents: Int
    public var mode: String
    public var address: String
    /// Set when `body` is free text (JSONPlaceholder's seed posts) rather than
    /// an encoded order payload.
    public var note: String

    public init(
        id: Int,
        customerId: Int,
        summary: String,
        lines: [OrderLine],
        totalCents: Int,
        mode: String,
        address: String,
        note: String = ""
    ) {
        self.id = id
        self.customerId = customerId
        self.summary = summary
        self.lines = lines
        self.totalCents = totalCents
        self.mode = mode
        self.address = address
        self.note = note
    }

    public var formattedTotal: String { EuroFormat.string(cents: totalCents) }
}

public extension OrderDraft {
    /// Cart taken from the sample menu: Green Bowl Deli, two pokes and one kale bowl.
    static let greenBowlSample = OrderDraft(
        customerId: 1,
        restaurantName: "Green Bowl Deli",
        lines: [
            OrderLine(
                dishId: "poke",
                name: "Salmon Avocado Poke",
                quantity: 2,
                unitPriceCents: 1290,
                restaurantName: "Green Bowl Deli"
            ),
            OrderLine(
                dishId: "kale",
                name: "Super Green Kale Bowl",
                quantity: 1,
                unitPriceCents: 1050,
                restaurantName: "Green Bowl Deli"
            ),
        ],
        mode: "delivery",
        address: "Calle Gran Vía, 42"
    )
}

enum EuroFormat {
    /// `3630` → `"36,30 €"`. Same comma-decimal layout as `PriceFormatter`, without grouping.
    static func string(cents: Int) -> String {
        let sign = cents < 0 ? "-" : ""
        let absolute = abs(cents)
        return String(format: "%@%d,%02d €", sign, absolute / 100, absolute % 100)
    }
}
