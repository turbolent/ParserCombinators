// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "ParserCombinators",
    products: [
        .library(
            name: "ParserCombinators",
            targets: ["ParserCombinators"]
        ),
        .library(
            name: "ParserCombinatorOperators",
            targets: ["ParserCombinatorOperators"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/turbolent/Trampoline.git", from: "0.2.1"),
        .package(url: "https://github.com/turbolent/DiffedAssertEqual.git", from: "0.1.0"),
    ],
    targets: [
        .target(
            name: "ParserCombinators",
            dependencies: ["Trampoline"]
        ),
        .target(
            name: "ParserCombinatorOperators",
            dependencies: ["ParserCombinators"]
        ),
        .testTarget(
            name: "ParserCombinatorsTests",
            dependencies: [
                "ParserCombinators",
                "ParserCombinatorOperators",
                "DiffedAssertEqual"
            ]
        )
    ]
)
