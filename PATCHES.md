# Asciiverse changes

Upstream: Lyle Tafoya's Omega Rebirth, github.com/Lyle-Tafoya/Omega (remote
`upstream`), the C++ continuation of Laurence Brothers' Omega (1987), with
the original releases from 0.60.2 on at the start of its history. We build
from its `development` branch at `28856f7` (2026-09-23), a year of fixes
past the v0.7.0 tag on `main`. Our work is on the `asciiverse` branch.

## Changes

- **Files in their proper places** (`src/paths.cpp`, `src/paths.h`, used
  from `game_session.cpp`): upstream reads its data from `./lib/` in the
  current folder and writes saves, the hall of fame and the log there too,
  with its options in `~/.omega.toml`. Now:
  - the data is found in `lib/` beside the executable, or
    `/usr/share/omega/` for system packages; `OMEGALIB` still overrides it;
  - the player's files (`saves/`, `omega.hi`, `omega.log`, `omega.toml`)
    live in `$XDG_DATA_HOME/omega` (`~/.local/share/omega`), or
    `%APPDATA%\omega` on Windows, created on first run with the hall of
    fame and log copied from `lib/`. An update of the game never touches
    them. If that folder cannot be made, upstream's behaviour is kept.
  - New global `Omegadata` beside `Omegalib`; the save, hall of fame, log
    and options paths in `char.cpp`, `command2.cpp`, `file.cpp` and
    `mon.cpp` use it.

## Building

`asciiverse/build.sh` (`STATIC=1` in Alpine for the static musl binary),
`asciiverse/package.sh <target>`; `.github/workflows/release.yml` builds
Linux x86_64 and aarch64 (static), macOS and Windows (console build) on a
`v<version>-av.<n>` tag.
