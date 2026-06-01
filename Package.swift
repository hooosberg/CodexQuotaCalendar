// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "QuotaCalendar",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "QuotaCalendar", targets: ["QuotaCalendar"])
    ],
    targets: [
        .executableTarget(
            name: "QuotaCalendar",
            exclude: ["Resources"]
        ),
        .testTarget(
            name: "QuotaCalendarTests",
            dependencies: ["QuotaCalendar"]
        )
    ]
)
