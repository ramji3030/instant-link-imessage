// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "instant-link-imessage",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(name: "InstantLinkCore", targets: ["InstantLinkCore"]),
        .library(name: "InstantLinkServices", targets: ["InstantLinkServices"])
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.7.0"),
        .package(url: "https://github.com/realm/realm-swift.git", from: "10.40.0"),
        .package(url: "https://github.com/ReactiveX/RxSwift.git", from: "6.5.0"),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.5.0"),
        .package(url: "https://github.com/Quick/Quick.git", from: "7.0.0"),
        .package(url: "https://github.com/Quick/Nimble.git", from: "13.0.0")
    ],
    targets: [
        .target(
            name: "InstantLinkCore",
            dependencies: [
                "Alamofire",
                .product(name: "Realm", package: "realm-swift"),
                .product(name: "RxSwift", package: "RxSwift"),
                .product(name: "Logging", package: "swift-log")
            ],
            path: "Sources/Core"
        ),
        .target(
            name: "InstantLinkServices",
            dependencies: [
                "InstantLinkCore",
                "Alamofire",
                .product(name: "RxSwift", package: "RxSwift")
            ],
            path: "Sources/Services"
        ),
        .testTarget(
            name: "InstantLinkCoreTests",
            dependencies: ["InstantLinkCore", "Quick", "Nimble"]
        )
    ]
)
