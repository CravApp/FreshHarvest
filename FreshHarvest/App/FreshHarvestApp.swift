//
//  FreshHarvestApp.swift
//  FreshHarvest
//
//  App entry point. Registers the bundled fonts before the first frame so the
//  type scale resolves correctly on launch, then shows the root tab container.
//

import SwiftUI

@main
struct FreshHarvestApp: App {

    @State private var store = AppStore()

    init() {
        // Fonts must be registered before any view reads the type scale.
        FontLoader.registerBundledFonts()
    }

    var body: some Scene {
        WindowGroup {
            RootView(store: store)
                .preferredColorScheme(.light)   // The design is a light-only canvas.
                .tint(Palette.primary)
        }
    }
}

// MARK: - Root

/// Hosts the bottom-navigation container. The delivered screen is `Inicio`; the
/// other four tabs are reachable placeholders built from the same design system.
struct RootView: View {

    @Bindable var store: AppStore
    @State private var selectedTab: AppTab = .home

    var body: some View {
        Group {
            switch selectedTab {
            case .home:
                HomeScreen(store: store, selectedTab: $selectedTab)
            default:
                PlaceholderScreen(tab: selectedTab, store: store, selectedTab: $selectedTab)
            }
        }
        .sheet(isPresented: $store.isCartPresented) {
            CartSheet(store: store)
        }
    }
}

#Preview("Root") {
    RootView(store: AppStore())
}
