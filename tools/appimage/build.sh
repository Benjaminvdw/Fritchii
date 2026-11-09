#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright 2026 Fritchii contributors
# SPDX-License-Identifier: GPL-3.0-or-later

# Builds Fritchii-v<N>-Linux-x86_64.AppImage in an Ubuntu 24.04 container. Needs only Docker.
#   tools/appimage/build.sh            JOBS=<n> limits the compile jobs (default: all cores)
set -euo pipefail

root=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)
image=fritchii-appimage-builder

if [ "${1:-}" != "--inside-container" ]; then
    docker build -t "$image" "$root/tools/appimage"
    mkdir -p "$root/build/appimage-home"
    exec docker run --rm --user "$(id -u):$(id -g)" \
        -e HOME=/src/build/appimage-home -e JOBS="${JOBS:-$(nproc)}" \
        -v "$root:/src" -w /src "$image" tools/appimage/build.sh --inside-container
fi

version=$(tr -d '[:space:]' < dist/frizti_version.txt)
output="Fritchii-v$version-Linux-x86_64.AppImage"
build=build/appimage
tools=build/appimage-tools
appdir=build/AppDir

# The update checker only knows the Windows zip, which an AppImage cannot install, so it stays off.
profile="-fprofile-use=/src/eglantine.profdata -Wno-backend-plugin \
    -Wno-profile-instr-unprofiled -Wno-profile-instr-out-of-date"
# Configure once: a second configure cannot find the bundled OpenSSL.
[ -f "$build/build.ninja" ] || cmake -S . -B "$build" -G Ninja \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_TESTING=OFF \
    -DYUZU_TESTS=OFF \
    -DYUZU_CMD=ON \
    -DYUZU_ROOM=OFF \
    -DYUZU_ROOM_STANDALONE=OFF \
    -DYUZU_USE_BUNDLED_QT=OFF \
    -DCMAKE_PREFIX_PATH="$QT_ROOT_DIR" \
    -DYUZU_USE_BUNDLED_SDL3=ON \
    -DVulkanHeaders_FORCE_BUNDLED=ON \
    -DVulkanUtilityLibraries_FORCE_BUNDLED=ON \
    -DENABLE_UPDATE_CHECKER=OFF \
    -DLICHII_BUILD_PLATFORM=linux-x86_64 \
    -DUSE_DISCORD_PRESENCE=OFF \
    -DCMAKE_C_COMPILER="clang-$LLVM_VERSION" \
    -DCMAKE_CXX_COMPILER="clang++-$LLVM_VERSION" \
    -DCMAKE_EXE_LINKER_FLAGS="-B/usr/lib/llvm-$LLVM_VERSION/bin -fuse-ld=lld" \
    -DCMAKE_C_FLAGS="$profile" \
    -DCMAKE_CXX_FLAGS="$profile"
cmake --build "$build" -j "$JOBS" --target yuzu yuzu-cmd -- -k 0

mkdir -p "$tools"
for tool in linuxdeploy/linuxdeploy linuxdeploy/linuxdeploy-plugin-qt; do
    name=${tool##*/}-x86_64.AppImage
    [ -s "$tools/$name" ] || curl -fsSL -o "$tools/$name" \
        "https://github.com/linuxdeploy/${tool##*/}/releases/download/continuous/$name"
done
chmod +x "$tools"/*.AppImage

strip "$build/bin/lichii" "$build/bin/eden-cli"
sed -e 's/^Name=.*/Name=Fritchii/' -e 's/^Icon=.*/Icon=fritchii/' \
    dist/io.github.zortos293.lichii.desktop > "$build/fritchii.desktop"

export PATH="$tools:$PATH"
export APPIMAGE_EXTRACT_AND_RUN=1
export QMAKE="$QT_ROOT_DIR/bin/qmake"
export LD_LIBRARY_PATH="$QT_ROOT_DIR/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
export EXTRA_QT_MODULES=waylandcompositor
export EXTRA_PLATFORM_PLUGINS='libqwayland-egl.so;libqwayland-generic.so'
# linuxdeploy's own strip cannot read the RELR sections of Ubuntu 24.04's libraries.
export NO_STRIP=1
export LDAI_VERSION="v$version-$(git rev-parse --short=7 HEAD)"
export LDAI_OUTPUT="$output"
export OUTPUT="$output"
export ARCH=x86_64

# The host's GPU driver loads into this process and may need a newer C++ runtime than Ubuntu's.
# Every system new enough for this glibc has a C++ runtime at least as new, so use the host's.
# The Vulkan loader likewise has to be the one that goes with the host's driver.
# linuxdeploy leaves these to the host, but minimal desktop installs can lack them.
extra_libs=()
for lib in libusb-1.0.so.0 libOpenGL.so.0 libfribidi.so.0 libcom_err.so.2 libgpg-error.so.0; do
    extra_libs+=(--library "/usr/lib/x86_64-linux-gnu/$lib")
done

rm -rf "$appdir"
# The shader preparation recipes ship only in the Windows release. The program reads them from
# recipes/ next to itself.
zip="$tools/windows-release.zip"
[ -s "$zip" ] || curl -fsSL -o "$zip" \
    "https://github.com/Frizti/Fritchii/releases/download/fritchii-v$version/Fritchii-v$version-Windows-x64.zip"
mkdir -p "$appdir/usr/bin/recipes"
unzip -j -o "$zip" '*/recipes/*' -d "$appdir/usr/bin/recipes"
linuxdeploy-x86_64.AppImage --appdir "$appdir" \
    --executable "$build/bin/lichii" \
    --executable "$build/bin/eden-cli" \
    --desktop-file "$build/fritchii.desktop" \
    --icon-file dist/fritchii.png \
    --exclude-library 'libstdc++.so*' \
    --exclude-library 'libgcc_s.so*' \
    --exclude-library 'libvulkan.so*' \
    "${extra_libs[@]}" \
    --plugin qt \
    --output appimage

test -s "$output"
ls -la "$output"
