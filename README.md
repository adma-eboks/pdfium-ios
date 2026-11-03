# PDFium for iOS

[PDFium](https://pdfium.googlesource.com/pdfium/) as a Swift package: an XCFramework with iOS device (arm64) and
simulator (arm64) slices, for iOS 15.6 and later. `import PDFium` gives PDFium's C API.

```swift
.package(url: "https://github.com/adma-eboks/pdfium-ios", exact: "8125.1.0")
```

## Versions

`<chromium branch>.<patch set>.0`. `8125.1.0` is PDFium `chromium/8125` with patch set 1.

## How it is built

The binaries come from [adma-eboks/pdfium-binaries](https://github.com/adma-eboks/pdfium-binaries), a fork of
[bblanchon/pdfium-binaries](https://github.com/bblanchon/pdfium-binaries), branch `ios-15.6`. Its `Build one` workflow
runs once per slice (target_os `ios`, target_cpu `arm64`, environment `device` and `simulator`). The branch differs
from the upstream tag in three ways:

- `ios_deployment_target = "15.6"` instead of `"17.0"`, which upstream only sets to avoid Chromium's own default.
- [`patches/tj_trailing_kerning.patch`](patches/tj_trailing_kerning.patch): keeps the kerning after a `TJ` array's last
  non-empty string, so `[(word)-250 ()]TJ` no longer drops the space before the next run.
- iOS jobs on the `macos-15-intel` runner, which cross-compiles the same arm64 output.

To make a release, download both artifacts and run:

```sh
scripts/package.sh <device build dir> <simulator build dir> <version>
```

It writes `dist/PDFium.xcframework.zip` and puts its URL and checksum into `Package.swift`. Then commit, tag the
version and attach the zip to a GitHub release with the same name.

## Licences

PDFium is under a BSD-3-Clause licence with Apache-2.0 parts (`LICENSES/pdfium.txt`), and bundles third-party
code under its own licences. All of them are in [`LICENSES`](LICENSES).
