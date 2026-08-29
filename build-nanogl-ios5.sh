#!/bin/bash
set -euo pipefail

ROOT="$HOME/xash3d-ios5"
NANO="$ROOT/nanogl"

TOOLCHAIN="$HOME/cctools-port/usage_examples/ios_toolchain/target"
SDK="$TOOLCHAIN/SDK/iPhoneOS6.1.sdk"

export PATH="$TOOLCHAIN/bin:$PATH"
export LD_LIBRARY_PATH="$TOOLCHAIN/lib:${LD_LIBRARY_PATH:-}"

CC="$TOOLCHAIN/bin/arm-apple-darwin11-clang"
CXX="$TOOLCHAIN/bin/arm-apple-darwin11-clang++"
AR="$TOOLCHAIN/bin/arm-apple-darwin11-ar"
OTOOL="$TOOLCHAIN/bin/arm-apple-darwin11-otool"

BUILD="$ROOT/build-ios5/nanogl"
LIB="$ROOT/build-ios5/lib"

rm -rf "$BUILD"
mkdir -p "$BUILD" "$LIB"

FLAGS=(
    -arch armv7
    -isysroot "$SDK"
    -miphoneos-version-min=5.1
    -O2
    -fno-common
    -I"$NANO"
    -I"$NANO/GL"
)

OBJECTS=()

while IFS= read -r -d '' src; do
    name="$(basename "$src")"
    obj="$BUILD/${name%.*}.o"

    case "$src" in
        *.cpp)
            echo "[CXX] $name"
            "$CXX" "${FLAGS[@]}" -c "$src" -o "$obj"
            ;;
        *.c)
            echo "[CC] $name"
            "$CC" "${FLAGS[@]}" -c "$src" -o "$obj"
            ;;
    esac

    OBJECTS+=("$obj")
done < <(
    find "$NANO" -maxdepth 1 -type f \
        \( -name '*.c' -o -name '*.cpp' \) \
        -print0
)

echo
echo "Objects: ${#OBJECTS[@]}"

rm -f "$LIB/libnanogl.a"

"$AR" rcs "$LIB/libnanogl.a" "${OBJECTS[@]}"

echo
echo "==== libnanogl.a ===="
file "$LIB/libnanogl.a"

echo
echo "==== GetProcAddress ===="
arm-apple-darwin11-nm "$LIB/libnanogl.a" |
grep -i 'nanoGL_GetProcAddress' || true

echo
echo "==== Minimum iOS ===="

for obj in "${OBJECTS[@]}"; do
    "$OTOOL" -l "$obj" |
    grep -A4 LC_VERSION_MIN_IPHONEOS |
    head -5
    break
done
