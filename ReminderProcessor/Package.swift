// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ReminderProcessor",
    platforms: [
    	.macOS(.v12)
    ],
    dependencies: [
    	.package(url: "https://github.com/apple/swift-argument-parser", from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .executableTarget(
            name: "ReminderProcessor",
            dependencies: [
            	.product(name: "ArgumentParser", package: "swift-argument-parser"),
            	"PromptManager"
            ],
            swiftSettings: [
            	.unsafeFlags(["-swift-version", "5"])
            ]),
        .target(
        	name: "PromptManager",
        	dependencies: [],
        	swiftSettings: [
        		.unsafeFlags(["-swift-version", "5"])
        	])
    ]
)
