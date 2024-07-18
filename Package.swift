// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift4337",
    platforms: [
        .iOS(.v15),.macOS(.v12)
    ],
    products: [
        .library(
            name: "swift4337",
            targets: ["swift4337"]),
    ],
    dependencies: [
        .package(url: "https://github.com/argentlabs/web3.swift", from: "1.6.1"),
        .package(url: "https://github.com/valpackett/SwiftCBOR", from: "0.4.7")
    ],
    targets: [
        .target(
            name: "swift4337",
            dependencies:[ .product(name: "web3.swift", package: "web3.swift"),
                           .product(name: "SwiftCBOR", package: "SwiftCBOR") ]
        ),
        .testTarget(
            name: "swift4337Tests",
            dependencies: ["swift4337"]),
    ]
)
