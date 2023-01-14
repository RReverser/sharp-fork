#!/bin/sh

# cd to wasm-scripts directory if not already there
cd "${0%/*}"

[ -f wasm-vips/build/target/lib/pkgconfig/vips-cpp.pc ] || (
  mkdir -p wasm-vips
  curl -Ls https://github.com/kleisauke/wasm-vips/archive/b0bd5217606ddf466899015855d64d2fc9d00a20.tar.gz | tar xzC wasm-vips --strip-components=1
  cd wasm-vips
  npm run build -- --enable-lto --disable-modules --disable-jxl --disable-bindings --enable-svg --enable-libvips-cpp
)

docker run \
  --rm \
  -v "$PWD/wasm-vips:/src" \
  -v "$PWD/..:/sharp-src" \
  -w '/sharp-src' \
  wasm-vips \
    emmake \
      /bin/sh -c ' \
        PKG_CONFIG_LIBDIR=/src/build/target/lib/pkgconfig:$PKG_CONFIG_LIBDIR \
        npm install \
          --build-from-source \
          --arch=wasm32 \
          --nodedir=wasm-scripts \
      '
