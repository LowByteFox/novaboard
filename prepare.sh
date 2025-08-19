#!/bin/sh

# Env setup
WRKDIR="$(pwd)"
BUILDDIR="$WRKDIR/build"
DEPS="https://github.com/raysan5/raylib.git"
HEADERS="https://raw.githubusercontent.com/Immediate-Mode-UI/Nuklear/refs/heads/master/nuklear.h
https://raw.githubusercontent.com/RobLoach/raylib-nuklear/refs/heads/master/include/raylib-nuklear.h"
TARGET="$(uname -s | tr "[:upper:]" "[:lower:]")"
CURRENT_OS="$TARGET"
CMAKE_OPTS="-DCMAKE_INSTALL_LIBDIR=lib
-DBUILD_EXAMPLES=OFF"
CMAKE_EXTRA_OPTS=""

# Functions
err() {
    echo "$@" >&2
}

usage() {
    err "usage: $0 [-h] [-t target]"
    exit 1
}

# Code
if [ "$1" = "-h" ]; then
    usage
fi

if [ "$1" = "-t" ]; then
    shift
    TARGET="$(echo $1 | tr "[:upper:]" "[:lower:]")"
fi

case "$TARGET" in
    "linux");;
    "win");;
    "windows") TARGET="win";;
    *)
        err "Target \"$TARGET\" not supported"
        exit 1
        ;;
esac

if [ "$TARGET" = "win" ]; then
    CMAKE_EXTRA_OPTS="--toolchain $WRKDIR/mingw-w64-x86_64.cmake"
fi

mkdir -p build/{deps,miniroot-$TARGET}
MINIROOT="$WRKDIR/build/miniroot-$TARGET"
CMAKE_OPTS="-DCMAKE_INSTALL_PREFIX=$MINIROOT $CMAKE_OPTS"

cd "$WRKDIR/build/deps/"
if [ ! -f "$BUILDDIR/.deps_compiled" ]; then
    for dep in $DEPS; do
        git clone --depth 1 "$dep"
    done

    for dep in $(ls); do
        cd $dep
        rm -rf _build
        cmake -B _build $CMAKE_OPTS $CMAKE_EXTRA_OPTS -G Ninja
        cd _build
        ninja
        ninja install
        cd ../..
    done

    touch "$BUILDDIR/.deps_compiled"
fi

# Nuklear + Raylib implementation

for header in $HEADERS; do
    name=$(basename $header)
    if [ ! -f $name ]; then
        curl -L -o $name $header
    fi
done

sed -i "s/NK_INCLUDE_FIXED_TYPES/NK_INCLUDE_SOFTWARE_FONT/" raylib-nuklear.h

cat > impl.c <<EOF
#define RAYLIB_NUKLEAR_IMPLEMENTATION
#include "raylib-nuklear.h"
EOF

cc -c impl.c -o impl.o
ar rcs libraylib-nuklear.a impl.o

cp libraylib-nuklear.a "$MINIROOT/lib"
