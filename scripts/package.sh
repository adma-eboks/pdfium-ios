#!/bin/zsh
# Turns the device and simulator builds of PDFium (from adma-eboks/pdfium-binaries, branch ios-15.6) into
# dist/PDFium.xcframework.zip for the binary target, and writes its URL and checksum into Package.swift.
# Usage: scripts/package.sh <device build dir> <simulator build dir> <version, e.g. 8125.1.0>
set -eu
cd "${0:A:h}/.."
DEVICE=${1:A} SIMULATOR=${2:A} VERSION=$3
WORK=build && rm -rf $WORK dist && mkdir -p $WORK dist

slice() {
  local from=$1 to=$WORK/$2/PDFium.framework
  mkdir -p $to/Headers $to/Modules
  cp $from/lib/pdfium.framework/pdfium $to/PDFium
  install_name_tool -id @rpath/PDFium.framework/PDFium $to/PDFium 2>/dev/null
  cp $from/lib/pdfium.framework/Info.plist $to/Info.plist
  plutil -replace CFBundleExecutable -string PDFium $to/Info.plist
  plutil -replace CFBundleName -string PDFium $to/Info.plist
  plutil -replace CFBundleShortVersionString -string $VERSION $to/Info.plist
  plutil -replace CFBundleVersion -string $VERSION $to/Info.plist
  # The C API only: the C++ helpers in include/cpp can't be imported from Swift
  cp $from/include/*.h $to/Headers/
  { echo "// Umbrella header for PDFium's C API"; for h in $to/Headers/fpdf*.h; do echo "#include \"${h:t}\""; done; } > $to/Headers/PDFium.h
  printf 'framework module PDFium {\n  umbrella header "PDFium.h"\n  export *\n  module * { export * }\n}\n' > $to/Modules/module.modulemap
  codesign -f -s - $to >/dev/null 2>&1
}

slice $DEVICE device
slice $SIMULATOR simulator
xcodebuild -create-xcframework -framework $WORK/device/PDFium.framework -framework $WORK/simulator/PDFium.framework \
  -output $WORK/PDFium.xcframework >/dev/null
(cd $WORK && ditto -c -k --sequesterRsrc --keepParent PDFium.xcframework ../dist/PDFium.xcframework.zip)
CHECKSUM=$(swift package compute-checksum dist/PDFium.xcframework.zip)
URL="https://github.com/adma-eboks/pdfium-ios/releases/download/$VERSION/PDFium.xcframework.zip"
sed -i '' -e "s|url: \"[^\"]*\"|url: \"$URL\"|" -e "s|checksum: \"[^\"]*\"|checksum: \"$CHECKSUM\"|" Package.swift
rm -rf LICENSES && mkdir LICENSES && cp $DEVICE/LICENSE LICENSES/pdfium.txt && cp $DEVICE/licenses/* LICENSES/
echo "dist/PDFium.xcframework.zip $(du -h dist/PDFium.xcframework.zip | cut -f1) checksum $CHECKSUM"
