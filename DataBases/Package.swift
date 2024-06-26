// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DataBases",
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "DataBases",
            targets: ["DataBases"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "DataBases",
            dependencies: [],
            resources: [
                .process("Resources/oxford_3000.txt"),
                .process("Resources/first_100_000_of_enwiki-20190320-words-frequency.txt"),
                .process("Resources/lemma.en.txt"),
                .process("Resources/phrases.txt"),
                .process("Resources/noises.txt"),
            ]),
        .testTarget(
            name: "DataBasesTests",
            dependencies: ["DataBases"]),
    ]
)
