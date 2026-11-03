// Asciiverse: where Omega finds its read-only data and keeps the player's
// own files, so it runs from any folder and an update never touches saves.
#ifndef OMEGA_PATHS_H
#define OMEGA_PATHS_H

#include <string>

// The read-only data folder (maps, texts, the starting hall of fame), with a
// trailing separator: $OMEGALIB if set, else lib/ beside the executable,
// else /usr/share/omega/ (system packages), else ./lib/.
std::string find_lib_dir();

// The player's folder for saves, the hall of fame, the log and omega.toml,
// with a trailing separator, created if missing: %APPDATA%\omega on Windows,
// else $XDG_DATA_HOME/omega or ~/.local/share/omega. The hall of fame and
// the log start as copies of the ones in lib_dir.
std::string find_data_dir(const std::string &lib_dir);

#endif
