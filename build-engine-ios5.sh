#!/bin/bash
set -euo pipefail

ROOT="$HOME/xash3d-ios5"
ENGINE="$ROOT/xash3d/engine"

TOOLCHAIN="$HOME/cctools-port/usage_examples/ios_toolchain/target"
SDK="$TOOLCHAIN/SDK/iPhoneOS6.1.sdk"

CC="$TOOLCHAIN/bin/arm-apple-darwin11-clang"
AR="$TOOLCHAIN/bin/arm-apple-darwin11-ar"
OTOOL="$TOOLCHAIN/bin/arm-apple-darwin11-otool"

BUILD="$ROOT/build-ios5/engine"
OBJ="$BUILD/obj"
LIB="$ROOT/build-ios5/lib"

rm -rf "$BUILD"
mkdir -p "$OBJ" "$LIB"

CFLAGS=(
    -arch armv7
    -isysroot "$SDK"
    -miphoneos-version-min=5.1
    -O2
    -std=gnu99
    -fno-common

    -DXASH_SDL
    -DXASH_NANOGL
    -DXASH_GLES
    -DXASH_FORCEINLINE
    -DXASH_SDLMAIN
    -DSINGLE_BINARY
    -D__MULTITEXTURE_SUPPORT__

    -I"$ROOT/SDL/include"

    -I"$ENGINE"
    -I"$ENGINE/common"
    -I"$ENGINE/client"
    -I"$ENGINE/server"
    -I"$ENGINE/platform/sdl"
    -I"$ENGINE/common/soundlib"
    -I"$ENGINE/common/soundlib/libmpg"
    -I"$ENGINE/common/imagelib"
    -I"$ENGINE/client/vgui"

    -I"$ROOT/xash3d/common"
    -I"$ROOT/xash3d/pm_shared"

    -I"$ROOT/nanogl"
    -I"$ROOT/nanogl/GL"
)

DIRS=(
    "$ENGINE/common"
    "$ENGINE/client"
    "$ENGINE/platform/sdl"
    "$ENGINE/server"
    "$ENGINE/common/soundlib"
    "$ENGINE/common/soundlib/libmpg"
    "$ENGINE/common/imagelib"
    "$ENGINE/client/vgui"
)

SOURCES=()

for dir in "${DIRS[@]}"; do
    if [ ! -d "$dir" ]; then
        echo "ERRO: diretório não encontrado: $dir"
        exit 1
    fi

    while IFS= read -r -d '' src; do
        SOURCES+=("$src")
    done < <(
        find "$dir" -maxdepth 1 -type f -name '*.c' -print0
    )
done

echo "========================================"
echo "Xash3D source files: ${#SOURCES[@]}"
echo "========================================"

OBJECTS=()

for src in "${SOURCES[@]}"; do
    relative="${src#$ROOT/}"
    objname="$(echo "$relative" | sed 's#[/ ]#_#g')"
    obj="$OBJ/${objname%.c}.o"

    echo
    echo "[CC] $relative"

    "$CC" "${CFLAGS[@]}" \
        -c "$src" \
        -o "$obj"

    OBJECTS+=("$obj")
done

echo
echo "========================================"
echo "Creating libxashengine.a"
echo "========================================"

rm -f "$LIB/libxashengine.a"

"$AR" rcs \
    "$LIB/libxashengine.a" \
    "${OBJECTS[@]}"

echo
echo "========================================"
echo "DONE"
echo "========================================"

file "$LIB/libxashengine.a"

echo
echo "Objects:"
"$AR" t "$LIB/libxashengine.a" | wc -l

FIRST="${OBJECTS[0]}"

echo
echo "Checking first object:"
file "$FIRST"

"$OTOOL" -l "$FIRST" | \
grep -A4 LC_VERSION_MIN_IPHONEOS || true

echo
echo "Library:"
echo "$LIB/libxashengine.a"
