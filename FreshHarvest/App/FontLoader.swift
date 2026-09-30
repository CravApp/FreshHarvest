//
//  FontLoader.swift
//  FreshHarvest
//
//  Registers the bundled Plus Jakarta Sans faces and the subset Material Symbols
//  icon fonts with Core Text at launch.
//
//  The design depends on exact glyph shapes, so the fonts ship inside the app
//  rather than relying on system-installed faces. Registration is scoped to the
//  process (`.process`) so nothing leaks outside the app sandbox.
//

import CoreText
import UIKit

enum FontLoader {

    /// PostScript names the app expects to find in `Resources/Fonts`.
    private static var allBundledNames: [String] {
        AppFont.postScriptNames + IconFont.allNames
    }

    /// Registers every bundled face and records whether the design system can
    /// use the real fonts. Safe to call more than once.
    @discardableResult
    static func registerBundledFonts() -> Bool {
        for name in allBundledNames {
            guard let url = Bundle.main.url(forResource: name, withExtension: "ttf") else {
                continue
            }
            // A face that is already registered returns `false` with
            // `kCTFontManagerErrorAlreadyRegistered`; that is not an error here.
            CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
        }

        // Trust Core Text's own lookup rather than the registration return value:
        // it is the same query `Font.custom` performs at render time.
        let resolved = allBundledNames.allSatisfy { UIFont(name: $0, size: 12) != nil }
        if resolved {
            FontRegistry.shared.markRegistered()
        }
        return resolved
    }

    /// Names that failed to resolve, for diagnostics and the debug overlay.
    static var missingFontNames: [String] {
        allBundledNames.filter { UIFont(name: $0, size: 12) == nil }
    }
}
