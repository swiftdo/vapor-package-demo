// swift-tools-version:5.8
import PackageDescription

let package = Package(
    name: "hello",
    platforms: [
       .macOS(.v12)
    ],
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "4.76.0"),
        .package(url: "https://github.com/vapor/fluent.git", from: "4.0.0"),
        .package(url: "https://github.com/vapor/fluent-postgres-driver.git", from: "2.0.0"),
        .package(url: "https://github.com/vapor/jwt.git", from: "4.2.2"),
        .package(url: "https://github.com/vapor/leaf.git", from: "4.2.4"),
        .package(url: "https://github.com/Flight-School/AnyCodable",from: "0.6.0")
    ],
    targets: [
        .target(
            name: "SMTP",
            dependencies: [
                .product(name: "Vapor", package: "vapor")
            ]
        ),
        .executableTarget(
            name: "App",
            dependencies: [
                .product(name: "Vapor", package: "vapor"),
                .product(name: "Fluent", package: "fluent"),
                .product(name: "FluentPostgresDriver", package: "fluent-postgres-driver"),
                .product(name: "JWT", package: "jwt"),
                .product(name: "Leaf", package: "leaf"),
                .product(name: "AnyCodable", package: "AnyCodable"),
                .target(name: "SMTP"),
            ],
            swiftSettings: [
                .unsafeFlags(["-cross-module-optimization"], .when(configuration: .release))
            ]
        ),
        .testTarget(name: "AppTests", dependencies: [
            .target(name: "App"),
            .product(name: "XCTVapor", package: "vapor"),
        ])
    ]
)
