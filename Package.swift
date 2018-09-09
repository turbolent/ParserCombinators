// swift-tools-version:4.2

import PackageDescription

let package = Package(
    name: "SwiftParserCombinators",
    products: [
        .library(
            name: "SwiftParserCombinators",
            targets: ["SwiftParserCombinators"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/turbolent/Trampoline.git", .exact("0.1.0"))
    ],
    targets: [
        .target(
            name: "SwiftParserCombinators",
            dependencies: ["Trampoline"]
        ),
        .testTarget(
            name: "SwiftParserCombinatorsTests",
            dependencies: ["SwiftParserCombinators"]
        )
    ]
)
