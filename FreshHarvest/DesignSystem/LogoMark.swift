//
//  LogoMark.swift
//  FreshHarvest
//
//  The HTML references a raster brand logo (`FreshGo Logo`). That asset is
//  served from a hot-link-protected CDN that refuses third-party requests, so
//  the mark is rebuilt here as resolution-independent vector shapes traced from
//  the reference render.
//
//  Anatomy (measured from the reference, expressed as fractions of the tile):
//  - Rounded-square tile, `#10B981`, corner radius ≈ 0.29 × side.
//  - White vertical oval ("leaf / egg") centred, ≈ 0.52 × side wide by
//    0.66 × side tall.
//  - A slim emerald stem running down the oval's centre line.
//  - A warm amber four-point sparkle (`#F59E0B`) sitting on the stem.
//

import SwiftUI

/// The FreshGo brand mark: emerald tile, white leaf, amber sparkle.
struct LogoMark: View {

    /// Rendered side length of the square tile.
    var size: CGFloat = 32

    /// Tile fill. The brand emerald (`primary-container`) by default.
    var tileColor: Color = Palette.primaryContainer

    /// Leaf / oval fill.
    var leafColor: Color = .white

    /// Sparkle fill — the amber accent.
    var sparkColor: Color = Palette.ratingAmber

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.29, style: .continuous)
                .fill(tileColor)

            leaf
            stem
            sparkle
        }
        .frame(width: size, height: size)
        .accessibilityHidden(true)
    }

    // MARK: - Parts

    /// The white vertical oval that reads as a leaf / seed.
    private var leaf: some View {
        Ellipse()
            .fill(leafColor)
            .frame(width: size * 0.52, height: size * 0.66)
    }

    /// Slim emerald line down the middle of the leaf.
    private var stem: some View {
        Capsule(style: .continuous)
            .fill(tileColor)
            .frame(width: size * 0.045, height: size * 0.30)
    }

    /// Four-point amber sparkle, built from a rotated square pinched into a star.
    private var sparkle: some View {
        SparkleShape()
            .fill(sparkColor)
            .frame(width: size * 0.20, height: size * 0.20)
    }
}

/// A concave four-point sparkle: four petals meeting at a sharp waist.
struct SparkleShape: Shape {

    /// How far the control points are pulled toward the centre. Lower values
    /// give sharper, thinner points.
    var waist: CGFloat = 0.30

    func path(in rect: CGRect) -> Path {
        let c = CGPoint(x: rect.midX, y: rect.midY)
        let rx = rect.width / 2
        let ry = rect.height / 2
        let inner = min(rx, ry) * waist

        var path = Path()
        path.move(to: CGPoint(x: c.x, y: c.y - ry))                       // top
        path.addQuadCurve(to: CGPoint(x: c.x + rx, y: c.y),               // right
                          control: CGPoint(x: c.x + inner, y: c.y - inner))
        path.addQuadCurve(to: CGPoint(x: c.x, y: c.y + ry),               // bottom
                          control: CGPoint(x: c.x + inner, y: c.y + inner))
        path.addQuadCurve(to: CGPoint(x: c.x - rx, y: c.y),               // left
                          control: CGPoint(x: c.x - inner, y: c.y + inner))
        path.addQuadCurve(to: CGPoint(x: c.x, y: c.y - ry),               // back to top
                          control: CGPoint(x: c.x - inner, y: c.y - inner))
        path.closeSubpath()
        return path
    }
}

// MARK: - Previews

#Preview("Logo") {
    VStack(spacing: Spacing.lg) {
        HStack(spacing: Spacing.md) {
            LogoMark(size: 32)
            LogoMark(size: 44)
            LogoMark(size: 64)
            LogoMark(size: 96)
        }
        LogoMark(size: 64, tileColor: Palette.primary)
    }
    .padding(Spacing.xl)
    .background(Palette.surface)
}
