import PackageDescription

let package = Package(
    name: "SwallowIO",
    dependencies: [
      .Package(url: "https://github.com/open-swift/C7.git", versions: Version(0, 11, 0)...Version(0, 11, 999)),
    ]
)
