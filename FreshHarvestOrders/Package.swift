// swift-tools-version: 5.9
//
// Linux-friendly package for the order flow. The iOS app target stays
// untouched (no iOS SDK is required to run these tests).
//

import PackageDescription

let package = Package(
    name: "FreshHarvestOrders",
    platforms: [
        .macOS(.v13),
        .iOS(.v17),
    ],
    products: [
        .library(name: "FreshHarvestOrders", targets: ["FreshHarvestOrders"]),
        .executable(name: "place-order", targets: ["PlaceOrder"]),
    ],
    targets: [
        .target(name: "FreshHarvestOrders"),
        .executableTarget(
            name: "PlaceOrder",
            dependencies: ["FreshHarvestOrders"]
        ),
        .testTarget(
            name: "FreshHarvestOrdersTests",
            dependencies: ["FreshHarvestOrders"]
        ),
    ]
)
