// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PN2PS",
    products: [
        .executable(name: "pn2ps", targets: ["PN2PS"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "0.0.1"),
        .package(url: "https://github.com/swiftcsv/SwiftCSV", from: "0.0.1")
    ],
    targets: [
        .target(name: "PN2PS", dependencies: [
            .product(name: "ArgumentParser", package: "swift-argument-parser"),
            .product(name: "SwiftCSV", package: "SwiftCSV")
        ])
    ]
)
