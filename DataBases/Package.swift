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
                .process("Resources/manaually_basic_vocabulary.txt"),
                .process("Resources/high_school_vocabulary.txt"),
                .process("Resources/cet4_vocabulary.txt"),
                .process("Resources/cet6_vocabulary.txt"),
                .process("Resources/oxford_3000.txt"),
                .process("Resources/lemma.en.txt"),
                .process("Resources/phrases_and_idioms_extracted_from_brief_oxford_dict.txt"),
                .process("Resources/phrases_should_add.txt"),
                .process("Resources/phrases_should_remove.txt"),
                .process("Resources/extra_fixed_noise_words.txt"),
                .process("Resources/two_letter_real_words.txt"),
                .process("Resources/one_letter_real_words.txt")
            ]),
        .testTarget(
            name: "DataBasesTests",
            dependencies: ["DataBases"]),
    ]
)
