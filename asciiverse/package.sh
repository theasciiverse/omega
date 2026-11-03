#!/bin/sh
# Packs Omega into its archive for av: dist/omega-<target>.tar.gz (.zip for
# Windows): the binary, its read-only data in lib/ beside it, and the
# licence and notes. Saves, the hall of fame and omega.toml live in the
# player's own folder (src/paths.h), never here.
#
#   asciiverse/package.sh x86_64-unknown-linux-musl
set -eu
cd "$(dirname "$0")/.."
target="$1"
case "$target" in *windows*) exe=.exe ;; *) exe= ;; esac
stage="stage/omega"
rm -rf "$stage" && mkdir -p "$stage" dist
cp "out/omega$exe" "$stage/"
cp -r lib "$stage/lib"
cp COPYING README.md PATCHES.md "$stage/"
if [ -n "$exe" ]; then
  (cd "$stage" && zip -qr "../../dist/omega-$target.zip" .)
else
  # owned by root in the archive where tar allows it (GNU tar); BusyBox
  # (Alpine, run as root) and bsdtar (macOS) take the files as they are
  tar --owner=0 --group=0 --numeric-owner -czf "dist/omega-$target.tar.gz" -C "$stage" . 2>/dev/null \
    || tar -czf "dist/omega-$target.tar.gz" -C "$stage" .
fi
ls -l dist
