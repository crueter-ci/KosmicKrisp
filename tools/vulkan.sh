#!/bin/sh -e

_tag="1.4.341"
_repo="KhronosGroup/Vulkan-Loader"
_dir="Vulkan-Loader-$_tag"
_artifact="$_tag.tar.gz"
_url="https://github.com/$_repo/archive/v$_artifact"

_src="$PWD/src"
_build="$PWD/build/$_dir"
_out="$PWD/install/$_dir"

which ccache || exit 1

if [ ! -d "$_out" ]; then
    mkdir -p "$_src" "$_build" "$_out"

    [ -f "$_artifact" ] || curl -L "$_url" -o "$_artifact"
    [ -d "$_src/$_dir" ] || tar xf "$_artifact" -C "$_src"

    cmake -S "$_src/$_dir" -B "$_build" \
        -DCMAKE_INSTALL_PREFIX="$_out" \
        -DCMAKE_BUILD_TYPE=Release \
        -DBUILD_TESTS=OFF \
        -DCMAKE_CXX_COMPILER_LAUNCHER="$(which ccache)" \
        -DCMAKE_C_COMPILER_LAUNCHER="$(which ccache)" \
        -G Ninja

    cmake --build "$_build" --verbose
    cmake --install "$_build"
fi

"$(which ccache)" -s

export VULKAN_LOADER_DIR="$_out"
