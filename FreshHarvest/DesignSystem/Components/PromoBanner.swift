//
//  PromoBanner.swift
//  FreshHarvest
//
//  "2x1 en Bowls y Ensaladas" hero promo card.
//
//  Source markup:
//  `<div class="relative overflow-hidden rounded-2xl bg-gradient-to-br
//    from-primary via-primary to-on-primary-fixed-variant text-on-primary
//    shadow-sm p-margin flex flex-col justify-between min-h-[170px]">`
//  with two decorative layers: a large blurred white circle
//  (`bg-white/10 blur-2xl`) and a soft emerald blob SVG at 30% opacity.
//
//  The gradient runs `#006C49 → #006C49 → #005236` on the diagonal, the blurred
//  orb becomes a heavily-blurred white circle, and the SVG blob is rebuilt as a
//  smooth closed organic path.
//

import SwiftUI

struct PromoBanner: View {

    let promo: SampleData.Promo
    var onRedeem: () -> Void = {}

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            content
            Spacer(minLength: Spacing.md)
            footer
        }
        .padding(Spacing.margin)
        .frame(maxWidth: .infinity, minHeight: Metrics.promoBannerMinHeight, alignment: .topLeading)
        .background { background }
        .clipShape(RoundedRectangle(cornerRadius: Radius.lg, style: .continuous))
        .elevation1()
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(promo.headline). \(promo.subtitle) \(promo.eta). Código \(promo.code)")
    }

    // MARK: - Text block

    private var content: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            // Code pill: `bg-primary-fixed text-on-primary-fixed`.
            HStack(spacing: 6) {
                Icon(.localOffer, size: 14, color: Palette.onPrimaryFixed)
                Text(promo.code)
                    .badgeStyle(color: Palette.onPrimaryFixed)
            }
            .padding(.horizontal, 10)                // `px-2.5`
            .padding(.vertical, 2)                   // `py-0.5`
            .background(Palette.primaryFixed, in: Capsule(style: .continuous))

            Text(promo.headline)
                .typeStyle(TypeScale.headlineMD)
                .foregroundStyle(Palette.onPrimary)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 2)                    // `mt-0.5`

            Text(promo.subtitle)
                .typeStyle(TypeScale.bodySM)
                .foregroundStyle(Palette.primaryFixed.opacity(0.95))
                .fixedSize(horizontal: false, vertical: true)
        }
        // `max-w-[70%]` — keeps the copy clear of the decorative orb.
        .frame(maxWidth: 260, alignment: .leading)
    }

    // MARK: - Footer row

    private var footer: some View {
        HStack(alignment: .center) {
            HStack(spacing: 6) {                     // `gap-1.5`
                Icon(.timer, size: 18, color: Palette.onPrimary.opacity(0.9))
                Text(promo.eta)
                    .typeStyle(TypeScale.labelMD)
                    .foregroundStyle(Palette.onPrimary.opacity(0.9))
            }

            Spacer(minLength: Spacing.sm)

            Button(action: onRedeem) {
                Text(promo.cta)
                    .typeStyle(TypeScale.labelMD)
                    .fontWeight(.bold)
                    .foregroundStyle(Palette.primary)
                    .padding(.horizontal, Spacing.md)
                    .padding(.vertical, Spacing.sm)
                    .background(Palette.surfaceContainerLowest, in: Capsule(style: .continuous))
                    .elevation1()
                    .contentShape(Capsule(style: .continuous))
            }
            .buttonStyle(PressableButtonStyle(pressedScale: 0.95))
            .accessibilityLabel("\(promo.cta) la promoción \(promo.code)")
        }
        .padding(.top, Spacing.sm)
    }

    // MARK: - Decoration

    private var background: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Palette.primary,                              // `from-primary`
                    Palette.primary,                              // `via-primary`
                    Palette.onPrimaryFixedVariant,                // `to-on-primary-fixed-variant`
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            // `absolute -right-8 -bottom-10 w-48 h-48 rounded-full bg-white/10 blur-2xl`
            Circle()
                .fill(.white.opacity(0.10))
                .frame(width: 192, height: 192)
                .blur(radius: 32)
                .offset(x: 96, y: 96)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)

            // `absolute -right-2 top-0 w-36 h-36 opacity-30` emerald blob.
            OrganicBlob()
                .fill(Palette.primaryFixed)
                .frame(width: 144, height: 144)
                .opacity(0.30)
                .offset(x: 24, y: -24)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
        }
        .allowsHitTesting(false)
    }
}

// MARK: - Decorative blob

/// Smooth organic blob used as the banner's background flourish. Built from four
/// mirrored cubic curves so the outline stays continuous and rounded at any size.
struct OrganicBlob: Shape {

    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height
        let cx = rect.midX
        let cy = rect.midY

        // Control-point offsets, expressed as fractions of the bounding box and
        // tuned to echo the reference blob's asymmetry.
        let k: CGFloat = 0.36

        var p = Path()
        p.move(to: CGPoint(x: cx, y: rect.minY + h * 0.06))
        p.addCurve(
            to: CGPoint(x: rect.maxX - w * 0.06, y: cy),
            control1: CGPoint(x: cx + w * k, y: rect.minY + h * 0.02),
            control2: CGPoint(x: rect.maxX - w * 0.02, y: cy - h * k)
        )
        p.addCurve(
            to: CGPoint(x: cx, y: rect.maxY - h * 0.04),
            control1: CGPoint(x: rect.maxX - w * 0.08, y: cy + h * k),
            control2: CGPoint(x: cx + w * k, y: rect.maxY - h * 0.01)
        )
        p.addCurve(
            to: CGPoint(x: rect.minX + w * 0.08, y: cy),
            control1: CGPoint(x: cx - w * k, y: rect.maxY - h * 0.02),
            control2: CGPoint(x: rect.minX + w * 0.02, y: cy + h * k)
        )
        p.addCurve(
            to: CGPoint(x: cx, y: rect.minY + h * 0.06),
            control1: CGPoint(x: rect.minX + w * 0.04, y: cy - h * k),
            control2: CGPoint(x: cx - w * k, y: rect.minY + h * 0.03)
        )
        p.closeSubpath()
        return p
    }
}

#Preview("PromoBanner") {
    PromoBanner(promo: SampleData.promo)
        .padding(Spacing.margin)
        .background(Palette.surface)
}
