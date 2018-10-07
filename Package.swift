// swift-tools-version:4.2

import PackageDescription

let package = Package(
    name: "ParserCombinators",
    products: [
        .library(
            name: "ParserCombinators",
            targets: ["ParserCombinators"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/turbolent/Trampoline.git", .exact("0.2.0"))
    ],
    targets: [
        .target(
            name: "ParserCombinators",
            dependencies: ["Trampoline"]
        ),
        .testTarget(
            name: "ParserCombinatorsTests",
            dependencies: ["ParserCombinators"]
        )
    ]
)
