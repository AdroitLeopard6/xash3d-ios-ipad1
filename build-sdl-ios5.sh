#!/bin/bash
set -euo pipefail

ROOT="$HOME/xash3d-ios5"
SDL="$ROOT/SDL"

TOOLCHAIN="$HOME/cctools-port/usage_examples/ios_toolchain/target"
SDK="$TOOLCHAIN/SDK/iPhoneOS6.1.sdk"

CC="$TOOLCHAIN/bin/arm-apple-darwin11-clang"
AR="$TOOLCHAIN/bin/arm-apple-darwin11-ar"

BUILD="$ROOT/build-ios5/sdl"
OBJ="$BUILD/obj"
LIB="$ROOT/build-ios5/lib"

rm -rf "$BUILD"
mkdir -p "$OBJ" "$LIB"

CFLAGS=(
    -arch armv7
    -isysroot "$SDK"
    -miphoneos-version-min=5.1
    -O2
    -fblocks
    -fno-common
    -D__IPHONEOS__=1
    -I"$SDL/include"
    -I"$SDL/src"
)

DIRS=(
    "$SDL/src"
    "$SDL/src/atomic"

    "$SDL/src/audio"
    "$SDL/src/audio/coreaudio"
    "$SDL/src/audio/dummy"

    "$SDL/src/cpuinfo"
    "$SDL/src/dynapi"
    "$SDL/src/events"

    "$SDL/src/file"
    "$SDL/src/file/cocoa"
    "$SDL/src/filesystem/cocoa"

    "$SDL/src/haptic"
    "$SDL/src/haptic/dummy"

    "$SDL/src/joystick"
    "$SDL/src/joystick/uikit"
    "$SDL/src/joystick/iphoneos"

    "$SDL/src/loadso/dlopen"

    "$SDL/src/main"
    "$SDL/src/main/uikit"

    "$SDL/src/power"
    "$SDL/src/power/uikit"

    "$SDL/src/render"
    "$SDL/src/render/software"
    "$SDL/src/render/opengles"
    "$SDL/src/render/opengles2"

    "$SDL/src/stdlib"

    "$SDL/src/thread"
    "$SDL/src/thread/pthread"

    "$SDL/src/timer"
    "$SDL/src/timer/unix"

    "$SDL/src/video"
    "$SDL/src/video/dummy"
    "$SDL/src/video/uikit"
)

SOURCES=()

for dir in "${DIRS[@]}"; do
    if [ -d "$dir" ]; then
        while IFS= read -r -d '' src; do
            SOURCES+=("$src")
        done < <(
            find "$dir" -maxdepth 1 -type f \
            \( -name '*.c' -o -name '*.m' \) \
            -print0
        )
    fi
done

echo "========================================"
echo "SDL source files: ${#SOURCES[@]}"
echo "========================================"

OBJECTS=()

for src in "${SOURCES[@]}"; do

    relative="${src#$SDL/}"

    objname="$(echo "$relative" | sed 's#[/ ]#_#g')"
    obj="$OBJ/${objname%.*}.o"

    echo
    echo "[CC] $relative"

    "$CC" \
        "${CFLAGS[@]}" \
        -c "$src" \
        -o "$obj"

    OBJECTS+=("$obj")
done

echo
echo "========================================"
echo "Creating libSDL2.a"
echo "========================================"

rm -f "$LIB/libSDL2.a"

"$AR" rcs \
    "$LIB/libSDL2.a" \
    "${OBJECTS[@]}"

echo
echo "========================================"
echo "DONE"
echo "========================================"

file "$LIB/libSDL2.a"

echo
echo "Objects:"
"$AR" t "$LIB/libSDL2.a" | wc -l
