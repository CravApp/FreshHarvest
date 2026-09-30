//
//  SearchBar.swift
//  FreshHarvest
//
//  Search field plus the round "advanced filters" button.
//
//  Source markup:
//  `<div class="flex-1 flex items-center bg-surface-container-lowest shadow-sm
//    rounded-full px-space-md py-3 focus-within:ring-2 focus-within:ring-primary/20">`
//  and a 48 × 48 (`w-12 h-12`) circular filter button.
//
//  The `focus-within:ring-2 ring-primary/20` focus state is reproduced with an
//  emerald ring that animates in while the field holds focus.
//

import SwiftUI

struct SearchBar: View {

    @Binding var text: String
    var placeholder: String = "Busca comida, restaurantes o tiendas…"
    var onFilterTap: () -> Void = {}

    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(spacing: Spacing.sm) {

            // Search field.
            HStack(spacing: Spacing.xs) {
                Icon(.search, size: 22, color: Palette.primary)

                TextField(placeholder, text: $text)
                    .typeStyle(TypeScale.bodyMD)
                    .foregroundStyle(Palette.onSurface)
                    .tint(Palette.primary)
                    .focused($isFocused)
                    .submitLabel(.search)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .accessibilityLabel("Buscar comida, restaurantes o tiendas")

                if !text.isEmpty {
                    Button {
                        withAnimation(.easeOut(duration: 0.15)) { text = "" }
                    } label: {
                        Icon(.close, size: 18, color: Palette.secondary)
                            .frame(width: 24, height: 24)
                            .contentShape(Circle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Borrar búsqueda")
                }
            }
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, 12)
            .background(Palette.surfaceContainerLowest, in: Capsule(style: .continuous))
            .elevation1()
            .overlay {
                Capsule(style: .continuous)
                    .stroke(Palette.primary.opacity(isFocused ? 0.20 : 0), lineWidth: 2)
                    .padding(-2)
            }
            .animation(.easeInOut(duration: 0.2), value: isFocused)

            // Advanced filters.
            Button(action: onFilterTap) {
                Icon(.tune, size: 22, color: Palette.onSurface)
                    .frame(width: 48, height: 48)
                    .background(Palette.surfaceContainerLowest, in: Circle())
                    .elevation1()
                    .contentShape(Circle())
            }
            .buttonStyle(PressableButtonStyle())
            .accessibilityLabel("Filtros avanzados")
        }
    }
}

// MARK: - Press feedback

/// Reproduces the design's `active:scale-95` press affordance.
struct PressableButtonStyle: ButtonStyle {
    var pressedScale: CGFloat = 0.95

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? pressedScale : 1)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

#Preview("SearchBar") {
    struct Harness: View {
        @State private var text = ""
        var body: some View {
            VStack(spacing: Spacing.md) {
                SearchBar(text: $text)
                SearchBar(text: .constant("poke"))
            }
            .padding(Spacing.margin)
            .background(Palette.surface)
        }
    }
    return Harness()
}
