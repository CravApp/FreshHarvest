//
//  Color+Hex.swift
//  FreshHarvest
//
//  Hex initialisers used to translate the design tokens (DESIGN.md) one-to-one
//  into SwiftUI colours. Keeping the literal hex values in the source makes the
//  conversion auditable against the design spec.
//

import SwiftUI

extension Color {
    /// Creates a colour from a packed 24-bit RGB value, e.g. `Color(hex: 0x006C49)`.
    init(hex: UInt32, opacity: Double = 1) {
        let r = Double((hex >> 16) & 0xFF) / 255
        let g = Double((hex >> 8) & 0xFF) / 255
        let b = Double(hex & 0xFF) / 255
        self.init(.sRGB, red: r, green: g, blue: b, opacity: opacity)
    }

    /// Creates a colour from a `#RRGGBB` / `RRGGBB` string. Returns `nil` when malformed.
    init?(hexString: String, opacity: Double = 1) {
        var s = hexString.trimmingCharacters(in: .whitespacesAndNewlines)
        if s.hasPrefix("#") { s.removeFirst() }
        guard s.count == 6, let value = UInt32(s, radix: 16) else { return nil }
        self.init(hex: value, opacity: opacity)
    }
}

extension Color {
    /// Applies an alpha channel without losing the underlying colour space.
    func alpha(_ value: Double) -> Color {
        opacity(value)
    }
}
