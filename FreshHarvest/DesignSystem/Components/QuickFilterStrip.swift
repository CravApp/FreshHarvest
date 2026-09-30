//
//  QuickFilterStrip.swift
//  FreshHarvest
//
//  Horizontal row of toggleable filter chips.
//
//  Source markup: `<button class="filter-chip shrink-0 inline-flex items-center
//  gap-1.5 px-3.5 py-1.5 rounded-full bg-surface-container-lowest shadow-sm
//  font-label-md font-semibold">` with a click handler that swaps the chip to
//  `bg-primary text-on-primary` while active.
//
//  Like the category rail, the strip bleeds past the page margin and applies the
//  inset to its own content.
//

import SwiftUI

struct QuickFilterStrip: View {

    let filters: [QuickFilter]
    let isActive: (QuickFilter) -> Bool
    var onToggle: (QuickFilter) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Spacing.sm) {                       // `gap-2`
                ForEach(filters) { filter in
                    FilterChip(
                        filter: filter,
                        isActive: isActive(filter)
                    ) {
                        onToggle(filter)
                    }
                }
            }
            .padding(.horizontal, Spacing.margin)
            .padding(.vertical, Spacing.xs)                     // `py-1`
        }
        .scrollClipDisabled()
    }
}

// MARK: - Chip

struct FilterChip: View {

    let filter: QuickFilter
    let isActive: Bool
    var onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 6) {                                // `gap-1.5`
                Icon(
                    filter.icon,
                    size: 16,
                    color: isActive ? Palette.onPrimary : filter.tint,
                    filled: filter.filled
                )

                Text(filter.title)
                    .typeStyle(TypeScale.labelMD)
                    .foregroundStyle(isActive ? Palette.onPrimary : Palette.onSurface)
            }
            .padding(.horizontal, 14)                           // `px-3.5`
            .padding(.vertical, 6)                              // `py-1.5`
            .background(
                isActive ? Palette.primary : Palette.surfaceContainerLowest,
                in: Capsule(style: .continuous)
            )
            .elevation1()
            .contentShape(Capsule(style: .continuous))
        }
        .buttonStyle(PressableButtonStyle(pressedScale: 0.97))
        .accessibilityLabel(filter.title)
        .accessibilityAddTraits(isActive ? [.isButton, .isSelected] : .isButton)
    }
}

#Preview("QuickFilterStrip") {
    struct Harness: View {
        @State private var active: Set<String> = ["rated"]
        var body: some View {
            QuickFilterStrip(
                filters: SampleData.quickFilters,
                isActive: { active.contains($0.id) },
                onToggle: { f in
                    if active.contains(f.id) { active.remove(f.id) } else { active.insert(f.id) }
                }
            )
            .background(Palette.surface)
        }
    }
    return Harness()
}
