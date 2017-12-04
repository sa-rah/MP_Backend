// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "Backend",
    products: [
        .library(name: "App", targets: ["App"]),
        .executable(name: "Run", targets: ["Run"])
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", .upToNextMajor(from: "2.2.0")),
        .package(url: "https://github.com/vapor/mongo-provider.git", .upToNextMajor(from: "2.0.0"))
        //.package(url: "https://github.com/OpenKitten/MongoKitten.git", .upToNextMajor(from: "4.1.0")),
        //.package(url: "https://github.com/OpenKitten/Meow.git", .upToNextMajor(from: "1.0.0"))
        //.package(url: "https://github.com/vapor-community/MongoKitten-Provider.git", .upToNextMajor(from: "0.0.0"))
    ],
    targets: [
        .target(name: "App", dependencies: ["Vapor", "MongoProvider"],
                exclude: [
                    "Config",
                    "Public",
                    "Resources",
                ]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App", "Testing"])
    ]
)
