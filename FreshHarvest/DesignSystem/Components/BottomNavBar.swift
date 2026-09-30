//
//  BottomNavBar.swift
//  FreshHarvest
//
//  Edge-to-edge bottom navigation dock.
//
//  Source markup:
//  `<nav class="fixed bottom-0 inset-x-0 z-50 pb-safe bg-surface/90
//    backdrop-blur-xl shadow-[0_-4px_20px_rgba(0,0,0,0.05)]">` with five
//  `w-16 h-full` items and the active one tinted `text-primary font-semibold`.
//
//  The upward shadow (`0 -4px 20px`) is applied by `elevationNav()`, and the
//  `pb-safe` inset is handled by letting the bar sit inside the safe area while
//  its background bleeds to the screen edge.
//

import SwiftUI

struct BottomNavBar: View {

    @Binding var selection: AppTab

    var body: some View {
        HStack(spacing: 0) {
            ForEach(AppTab.allCases) { tab in
                item(for: tab)
            }
        }
        .frame(height: Metrics.navHeight)
        .padding(.horizontal, Spacing.xs)                // `px-space-xs`
        .background {
            Palette.surface.opacity(0.90)
                .background(.ultraThinMaterial)
                .ignoresSafeArea(edges: .bottom)
        }
        .elevationNav()
    }

    private func item(for tab: AppTab) -> some View {
        let isSelected = selection == tab

        return Button {
            withAnimation(.easeInOut(duration: 0.18)) { selection = tab }
        } label: {
            VStack(spacing: Spacing.xs) {                // `gap-1`
                Icon(
                    tab.icon,
                    size: 24,
                    color: isSelected ? Palette.primary : Palette.onSurfaceVariant,
                    // The design's active item is tinted, not filled, so the
                    // outline face stays in use for every tab.
                    filled: false
                )

                Text(tab.title)
                    .typeStyle(TypeScale.labelSM)
                    .foregroundStyle(isSelected ? Palette.primary : Palette.onSurfaceVariant)
            }
            .frame(width: 64.0)                          // Explicit CGFloat avoids type inference ambiguity
            .frame(maxHeight: .infinity)                 // Flexible range height initializer
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(tab.title)
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
    }
}

#Preview("BottomNavBar") {
    struct Harness: View {
        @State private var tab: AppTab = .home
        var body: some View {
            VStack {
                Spacer()
                BottomNavBar(selection: $tab)
            }
            .background(Palette.surface)
        }
    }
    return Harness()
}
