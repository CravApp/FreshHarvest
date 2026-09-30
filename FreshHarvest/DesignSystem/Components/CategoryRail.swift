//
//  CategoryRail.swift
//  FreshHarvest
//
//  Horizontal, edge-to-edge category carousel with a section header.
//
//  Source markup:
//  `<div class="flex flex-col gap-space-xs -mx-margin">` — the negative margin
//  makes the rail bleed past the 20px page margin so tiles scroll off-screen
//  with a partial-reveal cue, while the header stays inset. In SwiftUI the same
//  effect comes from putting the horizontal padding on the content instead of
//  the ScrollView.
//
//  Each tile is `w-16 h-16 rounded-2xl`; the selected tile is filled with the
//  brand emerald and white glyph, unselected tiles are white with a tinted glyph.
//

import SwiftUI

struct CategoryRail: View {

    let categories: [FoodCategory]
    let selectedID: String?
    var onSelect: (FoodCategory) -> Void
    var onSeeAll: () -> Void = {}

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {

            // Section header — stays inside the page margin.
            HStack {
                Text("Categorías")
                    .typeStyle(TypeScale.headlineSM)
                    .foregroundStyle(Palette.onSurface)

                Spacer()

                Button(action: onSeeAll) {
                    Text("Ver todas")
                        .typeStyle(TypeScale.labelMD)
                        .foregroundStyle(Palette.primary)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Ver todas las categorías")
            }
            .padding(.horizontal, Spacing.margin)

            // Edge-to-edge rail.
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: 12) {          // `gap-3`
                    ForEach(categories) { category in
                        CategoryTile(
                            category: category,
                            isSelected: category.id == selectedID
                        ) {
                            onSelect(category)
                        }
                    }
                }
                .padding(.horizontal, Spacing.margin)
                .padding(.vertical, Spacing.sm)                 // `py-2`
            }
            .scrollClipDisabled()
        }
    }
}

// MARK: - Tile

struct CategoryTile: View {

    let category: FoodCategory
    let isSelected: Bool
    var onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 6) {                                // `gap-1.5`
                ZStack {
                    RoundedRectangle(cornerRadius: Radius.lg, style: .continuous)
                        .fill(isSelected
                              ? Palette.primary
                              : Palette.surfaceContainerLowest)

                    Icon(
                        category.icon,
                        size: 28,
                        color: isSelected ? Palette.onPrimary : category.tint.color
                    )
                }
                .frame(width: Metrics.categoryTile, height: Metrics.categoryTile)
                .elevation1()
                .overlay {
                    // The unselected tile picks up a subtle container tint on
                    // press, mirroring `hover:bg-surface-container-low`.
                    if !isSelected {
                        RoundedRectangle(cornerRadius: Radius.lg, style: .continuous)
                            .fill(Palette.surfaceContainerLow)
                            .opacity(0)
                    }
                }

                Text(category.name)
                    .typeStyle(TypeScale.labelMD, lineLimit: 2, alignment: .center)
                    .fontWeight(isSelected ? .bold : .semibold)
                    .foregroundStyle(isSelected ? Palette.primary : Palette.secondary)
                    .frame(width: 72, alignment: .top)          // `max-w-[72px]`
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(PressableButtonStyle())
        .accessibilityLabel(category.name)
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
    }
}

#Preview("CategoryRail") {
    struct Harness: View {
        @State private var selected: String? = SampleData.categories.first?.id
        var body: some View {
            CategoryRail(
                categories: SampleData.categories,
                selectedID: selected,
                onSelect: { selected = $0.id }
            )
            .background(Palette.surface)
        }
    }
    return Harness()
}
