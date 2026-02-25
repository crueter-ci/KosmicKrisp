#!/bin/sh -e

# shellcheck disable=SC1091

brew install meson python-setuptools llvm libxshmfence libxrandr ninja lld libclc vulkan-headers
python3 -m venv venv

. venv/bin/activate

. tools/spirv.sh

pip install mako setuptools pyyaml

COMMIT=710c87bced2ba88cc1cc5f5e3504fd73591cb886
DOWNLOAD="https://gitlab.freedesktop.org/mesa/mesa/-/archive/$COMMIT/mesa-$COMMIT.tar.gz"

LLVM_PREFIX="$(brew --prefix llvm)"
ZSTD_PREFIX="$(brew --prefix zstd)"

export CC="$LLVM_PREFIX/bin/clang"
export CXX="$LLVM_PREFIX/bin/clang++"
export AR="$LLVM_PREFIX/bin/llvm-ar"
export NM="$LLVM_PREFIX/bin/llvm-nm"
export RANLIB="$LLVM_PREFIX/bin/llvm-ranlib"
export STRIP="$LLVM_PREFIX/bin/llvm-strip"
export LD="$LLVM_PREFIX/bin/ld.lld"

cat << EOF > brew-llvm.ini
[binaries]
llvm-config = '$LLVM_PREFIX/bin/llvm-config'
c = '$CC'
cpp = '$CXX'
ar = '$AR'
nm = '$NM'
strip = '$STRIP'
ranlib = '$RANLIB'
ld = '$LD'
EOF

cat brew-llvm.ini

mkdir -p build src
export SRC_DIR="src/mesa-$COMMIT"
export BUILD_DIR="build/mesa-$COMMIT"

[ ! -f "mesa-$COMMIT".tar.gz ] && curl "$DOWNLOAD" -o "mesa-$COMMIT".tar.gz
[ ! -d "$BUILD_DIR" ] && tar xf "mesa-$COMMIT".tar.gz -C src

export PATH="$LLVM_PREFIX/bin:$PATH"

export CFLAGS="-g1"
export CXXFLAGS="-g1"
export LDFLAGS="-fuse-ld=lld"

export LIBRARY_PATH="${ZSTD_PREFIX}/lib${LIBRARY_PATH:+:${LIBRARY_PATH}}"
export PKG_CONFIG_PATH="$SPIRV_DIR/lib/pkgconfig"

meson setup "$BUILD_DIR" "$SRC_DIR" \
    -D b_ndebug=true \
    -D gallium-drivers= \
    -D vulkan-drivers=kosmickrisp \
    -D platforms=macos \
    -D valgrind=disabled \
    -D gallium-rusticl=false \
    -D static-libclc=all \
    --native-file brew-llvm.ini \
    --prefer-static

meson compile -C "$BUILD_DIR"
meson install -C "$BUILD_DIR" --destdir "$PWD"/install/mesa
