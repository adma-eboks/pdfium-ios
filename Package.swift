// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "PDFium",
    platforms: [.iOS("15.6")],
    products: [
        .library(name: "PDFium", targets: ["PDFium"]),
    ],
    targets: [
        .binaryTarget(
            name: "PDFium",
            url: "https://github.com/adma-eboks/pdfium-ios/releases/download/8125.1.0/PDFium.xcframework.zip",
            checksum: "ec3668cbad73b5233c7e7ca79c684fed3f15875303a774e0af6a88e6dc33186b"
        ),
    ]
)
