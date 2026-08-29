#!/bin/bash
set -euo pipefail

ROOT="$HOME/xash3d-ios5"

TOOLCHAIN="$HOME/cctools-port/usage_examples/ios_toolchain/target"

export PATH="$TOOLCHAIN/bin:$PATH"
export LD_LIBRARY_PATH="$TOOLCHAIN/lib:${LD_LIBRARY_PATH:-}"
SDK="$TOOLCHAIN/SDK/iPhoneOS6.1.sdk"

CC="$TOOLCHAIN/bin/arm-apple-darwin11-clang"
OTOOL="$TOOLCHAIN/bin/arm-apple-darwin11-otool"

LIB="$ROOT/build-ios5/lib"
OBJC="$ROOT/build-ios5/objc"
OUTDIR="$ROOT/build-ios5/final"

mkdir -p "$OUTDIR"

OUT="$OUTDIR/xash3d-ios"
rm -f "$OUT"

echo "========================================"
echo "LINKING Xash3D iOS 5.1 ARMv7"
echo "========================================"

"$CC" \
    -arch armv7 \
    -isysroot "$SDK" \
    -miphoneos-version-min=5.1 \
    -fblocks \
    -o "$OUT" \
    "$OBJC/launchdialog.o" \
    "$OBJC/AsyncSocket.o" \
    "$OBJC/FtpConnection.o" \
    "$OBJC/FtpDataConnection.o" \
    "$OBJC/FtpServer.o" \
    "$OBJC/list.o" \
    "$OBJC/NetworkController.o" \
    "$OBJC/gl_compat_ios5.o" \
    -Wl,-force_load,"$LIB/libxashengine.a" \
    -Wl,-force_load,"$LIB/libnanogl.a" \
    -Wl,-force_load,"$LIB/libSDL2.a" \
    -F"$SDK/System/Library/Frameworks" \
    -L"$SDK/usr/lib" \
    -framework Foundation \
    -framework UIKit \
    -framework CoreGraphics \
    -framework OpenGLES \
    -framework QuartzCore \
    -framework CoreAudio \
    -framework AudioToolbox \
    -framework CoreMotion \
    -framework AVFoundation \
    -framework SystemConfiguration \
    -framework CFNetwork \
    -lobjc \
    -lz

echo
echo "========================================"
echo "LINK OK"
echo "========================================"

file "$OUT"

echo
echo "Minimum iOS:"
"$OTOOL" -l "$OUT" |
grep -A4 LC_VERSION_MIN_IPHONEOS

echo
echo "Dependencies:"
"$OTOOL" -L "$OUT"
