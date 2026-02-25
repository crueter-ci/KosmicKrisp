#!/bin/sh -e

_commit=3684a76e07d011714368a29822de326485f32125
_repo=crueter/SPIRV-Tools
_dir=SPIRV-Tools-$_commit
_artifact=$_commit.tar.gz
_url=https://github.com/$_repo/archive/$_artifact

CCACHE="$(which ccache)"

_src="$PWD"/src
_build="$PWD"/build/$_dir
_out="$PWD"/install/$_dir

if [ ! -d "$_out" ]; then
    mkdir -p "$_src" "$_build" "$_out"

    _headers=https://github.com/KhronosGroup/SPIRV-Headers.git
    _headers_dir="$_src/$_dir/external/spirv-headers"

    [ -f $_artifact ] || curl -L "$_url" -o "$_artifact"
    [ -d "$_src"/$_dir ] || tar xf $_artifact -C "$_src"

    [ -d "$_headers_dir" ] || git clone "$_headers" "$_headers_dir"

    cmake -S "$_src/$_dir" -B "$_build" \
        -DSPIRV_TOOLS_BUILD_SHARED=OFF \
        -DSPIRV_TOOLS_BUILD_STATIC=ON \
        -DCMAKE_INSTALL_PREFIX="$_out" \
        -DCMAKE_CXX_COMPILER_LAUNCHER="$CCACHE" \
        -DCMAKE_C_COMPILER_LAUNCHER="$CCACHE" \
        -G Ninja -DCMAKE_BUILD_TYPE=Release

    cmake --build "$_build"
    cmake --install "$_build"
fi

export SPIRV_DIR="$_out"