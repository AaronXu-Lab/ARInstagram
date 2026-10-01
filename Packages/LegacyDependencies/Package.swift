// swift-tools-version: 5.9
import PackageDescription
let package = Package(name: "LegacyDependencies", platforms: [.iOS("26.0")], products: [.library(name: "EFColorPicker", targets: ["EFColorPicker"]),
.library(name: "SVProgressHUD", targets: ["SVProgressHUD"]),
.library(name: "Lottie", targets: ["Lottie"])], targets: [.target(name: "EFColorPicker"),
.target(name: "SVProgressHUD", resources: [.copy("SVProgressHUD.bundle")], publicHeadersPath: "include", cSettings: [.headerSearchPath("include"), .unsafeFlags(["-fobjc-arc"])], linkerSettings: []),
.target(name: "Lottie", publicHeadersPath: "include", cSettings: [.headerSearchPath("include"), .unsafeFlags(["-fobjc-arc"])], linkerSettings: [])], swiftLanguageVersions: [.v5])
