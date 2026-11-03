#!/bin/sh
# Records the catalog preview, asciiverse/omega.cast, to hub/RECORDING.md
# (100x30) with hub's scripted recorder: the welcome, the title menu, the
# point pool, then a run in through the gates of Rampart and round its
# streets (Shift and a direction runs until something is worth a stop). Plays the packaged build (dist/omega-<target>.tar.gz, unpacked
# to a scratch folder), as a player named "player" with a throwaway HOME,
# so nothing of this machine gets in.
#
#   asciiverse/package.sh x86_64-unknown-linux-musl && asciiverse/record-preview.sh [castrec.py]
set -eu
cd "$(dirname "$0")/.."
rec=${1:-../../hub/tools/castrec.py}
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
mkdir -p "$tmp/game" "$tmp/home"
tar -xzf dist/omega-x86_64-unknown-linux-musl.tar.gz -C "$tmp/game"
python3 "$rec" asciiverse/omega.cast "$tmp/game" \
  "w3;kspace;w2.5;kenter;w2.5;kenter;w3;kH;w1;kH;w1.5;r4:h:0.3;r2:j:0.3;w0.4;kH;w2;kK;w2;kL;w2;kJ;w3" \
  -- env HOME="$tmp/home" USERNAME=player ./omega
