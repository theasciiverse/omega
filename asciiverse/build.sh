#!/bin/sh
# Builds Omega into out/omega with upstream's CMake files. Compiler and
# flags come from the environment, so one script serves every target
# (see .github/workflows/release.yml):
#
#   asciiverse/build.sh                       # Debian, Ubuntu (GCC 13 or newer)
#   STATIC=1 asciiverse/build.sh              # Alpine, static musl binary
#   CMAKE_OSX_ARCHITECTURES=arm64 MACOSX_DEPLOYMENT_TARGET=13.3 asciiverse/build.sh  # macOS
#
# Windows builds from the workflow with MSVC and upstream's PDCursesMod in
# the console (PDC_GL_BUILD=OFF).
set -eu
cd "$(dirname "$0")/.."
build="out/build"
set -- -DCMAKE_BUILD_TYPE="${BUILD_TYPE:-Release}"
if [ -n "${STATIC:-}" ]; then
  # link libncursesw.a as the compiler finds it, instead of the shared
  # library CMake would pick, and the whole program statically
  lib() { "${CXX:-c++}" -print-file-name="$1"; }
  # (CMake's FindCurses also adds the form library, so that one too)
  set -- "$@" -DCURSES_LIBRARY="$(lib libncursesw.a)" -DCURSES_INCLUDE_PATH=/usr/include \
    -DCURSES_CURSES_LIBRARY="$(lib libncursesw.a)" -DCURSES_NCURSES_LIBRARY="$(lib libncursesw.a)" \
    -DCURSES_FORM_LIBRARY="$(lib libformw.a)" \
    -DCMAKE_EXE_LINKER_FLAGS="-static -s"
fi
rm -rf "$build" && mkdir -p out
cmake -S . -B "$build" "$@" >/dev/null
cmake --build "$build" --parallel "$(getconf _NPROCESSORS_ONLN 2>/dev/null || echo 2)"
cp "$build/omega" out/omega
echo "built omega"
