// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift4337",
    platforms: [
        .iOS(.v14),.macOS(.v11)
    ],
    products: [
        .library(
            name: "swift4337",
            targets: ["swift4337"]),
    ],
    dependencies: [
        .package(url: "https://github.com/argentlabs/web3.swift", from: "1.6.1")
    ],
    targets: [
        .target(
            name: "swift4337",
            dependencies:[ .product(name: "web3.swift", package: "web3.swift")]
        ),
        .testTarget(
            name: "swift4337Tests",
            dependencies: ["swift4337"]),
    ]
)
