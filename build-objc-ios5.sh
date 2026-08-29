#!/bin/bash
set -euo pipefail

ROOT="$HOME/xash3d-ios5"
TOOLCHAIN="$HOME/cctools-port/usage_examples/ios_toolchain/target"
SDK="$TOOLCHAIN/SDK/iPhoneOS6.1.sdk"

CC="$TOOLCHAIN/bin/arm-apple-darwin11-clang"
OTOOL="$TOOLCHAIN/bin/arm-apple-darwin11-otool"

BUILD="$ROOT/build-ios5/objc"

rm -rf "$BUILD"
mkdir -p "$BUILD"

CFLAGS=(
    -arch armv7
    -isysroot "$SDK"
    -miphoneos-version-min=5.1
    -O2
    -fblocks

    -I"$ROOT/src"
    -I"$ROOT/SDL/include"
    -I"$ROOT/xash3d/common"
    -I"$ROOT/xash3d/engine/common"
)

SOURCES=(
    "$ROOT/src/launchdialog.m"
    "$ROOT/src/AsyncSocket.m"
    "$ROOT/src/FtpConnection.m"
    "$ROOT/src/FtpDataConnection.m"
    "$ROOT/src/FtpServer.m"
    "$ROOT/src/list.m"
    "$ROOT/src/NetworkController.m"
)

OBJECTS=()

for src in "${SOURCES[@]}"; do
    name="$(basename "$src" .m)"
    obj="$BUILD/$name.o"

    echo "[OBJC] $(basename "$src")"

    "$CC" \
        "${CFLAGS[@]}" \
        -c "$src" \
        -o "$obj"

    OBJECTS+=("$obj")
done

echo
echo "[C] gl_compat_ios5.c"

"$CC" \
    -arch armv7 \
    -isysroot "$SDK" \
    -miphoneos-version-min=5.1 \
    -O2 \
    -c "$ROOT/src/gl_compat_ios5.c" \
    -o "$BUILD/gl_compat_ios5.o"

echo
echo "========================================"
echo "Objective-C DONE"
echo "========================================"

for obj in "${OBJECTS[@]}"; do
    file "$obj"
done

echo
echo "Minimum iOS:"
"$OTOOL" -l "$BUILD/launchdialog.o" |
grep -A4 LC_VERSION_MIN_IPHONEOS
