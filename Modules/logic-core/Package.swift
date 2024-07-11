// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "logic-core",
  platforms: [.iOS(.v15)],
  products: [
    .library(
      name: "logic-core",
      targets: ["logic-core"])
  ],
  dependencies: [
    .package(
      url: "https://github.com/dentsusoken/tw-lib-ios-wallet-kit.git",
      branch: "main"
    ),
    .package(
      name: "logic-resources",
      path: "./logic-resources"
    ),
    .package(
      name: "logic-business",
      path: "./logic-business"
    )
  ],
  targets: [
    .target(
      name: "logic-core",
      dependencies: [
        "logic-resources",
        "logic-business",
        .product(
          name: "EudiWalletKit",
          package: "tw-lib-ios-wallet-kit"
        )
      ],
      path: "./Sources"
    )
  ]
)
