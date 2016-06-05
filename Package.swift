import PackageDescription

let package = Package(
    name: "SwallowIO",
    dependencies: [
      .Package(url: "https://github.com/open-swift/C7.git", versions: Version(0, 8, 0)..<Version(1, 0, 0)),
    ]
)
