//
//  Icons.swift
//  FreshHarvest
//
//  The HTML references Google's **Material Symbols Outlined** icon font
//  (`<span class="material-symbols-outlined">search</span>`). Rather than
//  substituting SF Symbols — which would change every glyph shape and weight —
//  the real font is bundled and subset to only the ~76 glyphs this screen uses.
//
//  Material Symbols is *ligature* based on the web, but ligatures are unreliable
//  through Core Text, so each icon is addressed by its Private-Use-Area
//  codepoint instead. The codepoints below were extracted from the font's own
//  `GSUB` ligature table, so they are exact.
//
//  Two faces are bundled because the design toggles the font's `FILL` axis:
//  outlined for default icons, filled for active states (rating stars, the
//  favourited heart, selected filter chips).
//

import SwiftUI

// MARK: - Font families

enum IconFont {
    /// `FILL 0` — default outline icons.
    static let outlined = "MSOutlined-Subset"
    /// `FILL 1` — solid icons used for active / emphasised states.
    static let filled = "MSFilled-Subset"

    static var allNames: [String] { [outlined, filled] }
}

// MARK: - Icon catalogue

/// Every icon used by the Fresh Harvest screen, keyed by the same name the HTML
/// uses so call sites can be diffed against the source design.
enum MaterialIcon: String, CaseIterable {

    // Header
    case keyboardArrowDown
    case notifications

    // Search
    case search
    case tune

    // Delivery-mode switcher
    case moped
    case shoppingBag

    // Promo banner
    case localOffer
    case timer

    // Category rail
    case eco
    case lunchDining
    case localPizza
    case setMeal
    case bakeryDining
    case coffee
    case storefront

    // Quick filters
    case nearMe
    case star
    case electricMoped

    // Restaurant card
    case schedule
    case favoriteBorder
    case favorite
    case localShipping
    case pinDrop
    case add
    case check

    // Bottom navigation
    case home
    case explore
    case receiptLong
    case person

    // Cart & checkout
    case shoppingCart
    case close
    case remove
    case delete
    case moreVert
    case arrowForward
    case arrowBack
    case chevronRight
    case checkCircle
    case locationOn

    // Generic / future screens
    case verified
    case creditCard
    case payments
    case redeem
    case bolt
    case percent
    case directionsBike
    case call
    case filterList
    case myLocation
    case restaurant
    case store
    case localFireDepartment
    case loyalty
    case share
    case info
    case thumbUp
    case language
    case help
    case settings
    case edit
    case addCircle
    case removeCircle
    case restaurantMenu
    case localCafe
    case icecream
    case cake
    case apartment

    /// Private-Use-Area codepoint resolved from the font's `GSUB` ligature table.
    var codepoint: Unicode.Scalar {
        switch self {
        case .keyboardArrowDown:   return Unicode.Scalar(0xE313)!
        case .notifications:       return Unicode.Scalar(0xE7F4)!
        case .search:              return Unicode.Scalar(0xE8B6)!
        case .tune:                return Unicode.Scalar(0xE429)!
        case .moped:               return Unicode.Scalar(0xEA72)!
        case .shoppingBag:         return Unicode.Scalar(0xF1CC)!
        case .localOffer:          return Unicode.Scalar(0xE54E)!
        case .timer:               return Unicode.Scalar(0xE425)!
        case .eco:                 return Unicode.Scalar(0xEA35)!
        case .lunchDining:         return Unicode.Scalar(0xEA61)!
        case .localPizza:          return Unicode.Scalar(0xE552)!
        case .setMeal:             return Unicode.Scalar(0xF1EA)!
        case .bakeryDining:        return Unicode.Scalar(0xEA53)!
        case .coffee:              return Unicode.Scalar(0xEFEF)!
        case .storefront:          return Unicode.Scalar(0xEA12)!
        case .nearMe:              return Unicode.Scalar(0xE569)!
        case .star:                return Unicode.Scalar(0xE838)!
        case .electricMoped:       return Unicode.Scalar(0xEB1D)!
        case .schedule:            return Unicode.Scalar(0xE192)!
        case .favoriteBorder:      return Unicode.Scalar(0xE87D)!
        case .favorite:            return Unicode.Scalar(0xE87D)!
        case .localShipping:       return Unicode.Scalar(0xE558)!
        case .pinDrop:             return Unicode.Scalar(0xE55E)!
        case .add:                 return Unicode.Scalar(0xE145)!
        case .check:               return Unicode.Scalar(0xE5CA)!
        case .home:                return Unicode.Scalar(0xE88A)!
        case .explore:             return Unicode.Scalar(0xE87A)!
        case .receiptLong:         return Unicode.Scalar(0xEF6E)!
        case .person:              return Unicode.Scalar(0xE7FD)!
        case .shoppingCart:        return Unicode.Scalar(0xE547)!
        case .close:               return Unicode.Scalar(0xE14C)!
        case .remove:              return Unicode.Scalar(0xE15B)!
        case .delete:              return Unicode.Scalar(0xE872)!
        case .moreVert:            return Unicode.Scalar(0xE5D4)!
        case .arrowForward:        return Unicode.Scalar(0xE5C8)!
        case .arrowBack:           return Unicode.Scalar(0xE5C4)!
        case .chevronRight:        return Unicode.Scalar(0xE409)!
        case .checkCircle:         return Unicode.Scalar(0xE86C)!
        case .locationOn:          return Unicode.Scalar(0xE0C8)!
        case .verified:            return Unicode.Scalar(0xE031)!
        case .creditCard:          return Unicode.Scalar(0xE870)!
        case .payments:            return Unicode.Scalar(0xEF63)!
        case .redeem:              return Unicode.Scalar(0xE8B1)!
        case .bolt:                return Unicode.Scalar(0xEA0B)!
        case .percent:             return Unicode.Scalar(0xEB58)!
        case .directionsBike:      return Unicode.Scalar(0xE52F)!
        case .call:                return Unicode.Scalar(0xE0B0)!
        case .filterList:          return Unicode.Scalar(0xE152)!
        case .myLocation:          return Unicode.Scalar(0xE1B3)!
        case .restaurant:          return Unicode.Scalar(0xE56C)!
        case .store:               return Unicode.Scalar(0xE563)!
        case .localFireDepartment: return Unicode.Scalar(0xEA05)!
        case .loyalty:             return Unicode.Scalar(0xE89A)!
        case .share:               return Unicode.Scalar(0xE80D)!
        case .info:                return Unicode.Scalar(0xE88E)!
        case .thumbUp:             return Unicode.Scalar(0xE817)!
        case .language:            return Unicode.Scalar(0xE894)!
        case .help:                return Unicode.Scalar(0xE887)!
        case .settings:            return Unicode.Scalar(0xE8B8)!
        case .edit:                return Unicode.Scalar(0xE150)!
        case .addCircle:           return Unicode.Scalar(0xE147)!
        case .removeCircle:        return Unicode.Scalar(0xE15C)!
        case .restaurantMenu:      return Unicode.Scalar(0xE561)!
        case .localCafe:           return Unicode.Scalar(0xE541)!
        case .icecream:            return Unicode.Scalar(0xEA69)!
        case .cake:                return Unicode.Scalar(0xE7E9)!
        case .apartment:           return Unicode.Scalar(0xEA40)!
        }
    }

    /// The glyph as a `String`, ready to hand to `Text`.
    var glyph: String { String(codepoint) }

    /// SF Symbol used only when the bundled icon font could not be registered,
    /// so a font-loading problem degrades to a legible icon instead of a blank
    /// box. The real font is preferred in every normal build.
    var fallbackSystemName: String {
        switch self {
        case .keyboardArrowDown:   return "chevron.down"
        case .notifications:       return "bell"
        case .search:              return "magnifyingglass"
        case .tune:                return "slider.horizontal.3"
        case .moped, .electricMoped: return "bicycle"
        case .shoppingBag:         return "bag"
        case .localOffer:          return "tag"
        case .timer:               return "timer"
        case .eco:                 return "leaf"
        case .lunchDining:         return "takeoutbag.and.cup.and.straw"
        case .localPizza:          return "triangle"
        case .setMeal:             return "fish"
        case .bakeryDining:        return "birthday.cake"
        case .coffee:              return "cup.and.saucer"
        case .storefront:          return "storefront"
        case .nearMe:              return "location.north.line"
        case .star, .favorite:     return "star.fill"
        case .schedule:            return "clock"
        case .favoriteBorder:      return "heart"
        case .localShipping:       return "shippingbox"
        case .pinDrop:             return "mappin.and.ellipse"
        case .add:                 return "plus"
        case .check, .checkCircle: return "checkmark"
        case .home:                return "house"
        case .explore:             return "safari"
        case .receiptLong:         return "list.bullet.rectangle"
        case .person:              return "person"
        case .shoppingCart:        return "cart"
        case .close:               return "xmark"
        case .remove:              return "minus"
        case .delete:              return "trash"
        case .moreVert:            return "ellipsis"
        case .arrowForward:        return "arrow.right"
        case .arrowBack:           return "arrow.left"
        case .chevronRight:        return "chevron.right"
        case .locationOn:          return "mappin"
        case .verified:            return "checkmark.seal"
        case .creditCard:          return "creditcard"
        case .payments:            return "banknote"
        case .redeem, .loyalty:    return "gift"
        case .bolt:                return "bolt"
        case .percent:             return "percent"
        case .directionsBike:      return "bicycle"
        case .call:                return "phone"
        case .filterList:          return "line.3.horizontal.decrease"
        case .myLocation:          return "location.fill"
        case .restaurant, .restaurantMenu: return "fork.knife"
        case .store:               return "building.2"
        case .localFireDepartment: return "flame"
        case .share:               return "square.and.arrow.up"
        case .info:                return "info.circle"
        case .thumbUp:             return "hand.thumbsup"
        case .language:            return "globe"
        case .help:                return "questionmark.circle"
        case .settings:            return "gearshape"
        case .edit:                return "pencil"
        case .addCircle:           return "plus.circle"
        case .removeCircle:        return "minus.circle"
        case .localCafe:           return "cup.and.saucer.fill"
        case .icecream:            return "snowflake"
        case .cake:                return "birthday.cake.fill"
        case .apartment:           return "building"
        }
    }
}

// MARK: - Icon view

/// Renders a `MaterialIcon` at a given point size.
///
/// Material Symbols draws every glyph inside a 1 em square that is vertically
/// centred on the font's line box, so framing the `Text` at `size × size` and
/// letting SwiftUI centre it produces optically centred icons with no manual
/// baseline nudging.
struct Icon: View {

    private let icon: MaterialIcon
    private let size: CGFloat
    private let color: Color
    private let isFilled: Bool

    /// - Parameters:
    ///   - icon: the glyph to draw.
    ///   - size: point size of the 1 em icon box (the HTML `text-[Npx]` value).
    ///   - color: tint; defaults to the standard on-surface ink.
    ///   - isFilled: uses the `FILL 1` face for active states.
    init(
        _ icon: MaterialIcon,
        size: CGFloat = 24,
        color: Color = Palette.onSurface,
        filled isFilled: Bool = false
    ) {
        self.icon = icon
        self.size = size
        self.color = color
        self.isFilled = isFilled
    }

    var body: some View {
        Group {
            if FontRegistry.shared.isRegistered {
                Text(icon.glyph)
                    .font(.custom(isFilled ? IconFont.filled : IconFont.outlined, size: size))
            } else {
                Image(systemName: icon.fallbackSystemName)
                    .font(.system(size: size * 0.85))
            }
        }
        .foregroundStyle(color)
        .frame(width: size, height: size)
        .accessibilityHidden(true)
    }
}

// MARK: - Previews

#Preview("Icon grid") {
    ScrollView {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 72))], spacing: Spacing.md) {
            ForEach(MaterialIcon.allCases, id: \.self) { icon in
                VStack(spacing: Spacing.xs) {
                    Icon(icon, size: 28, color: Palette.primary)
                    Text(icon.rawValue)
                        .font(.system(size: 8))
                        .foregroundStyle(Palette.secondary)
                        .lineLimit(1)
                }
            }
        }
        .padding(Spacing.margin)
    }
    .background(Palette.surface)
}
