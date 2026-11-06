#!/usr/bin/env bash
# Install (or uninstall) the "Convert video" Dolphin service menu for the current user.
#   ./install.sh             install / update
#   ./install.sh --uninstall remove
set -eu
cd "$(dirname "$0")"

BIN_DIR="${XDG_BIN_HOME:-$HOME/.local/bin}"
MENU_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/kio/servicemenus"
BIN="$BIN_DIR/convert-video"
MENU="$MENU_DIR/convert-video.desktop"

if [ "${1:-}" = "--uninstall" ]; then
    rm -f "$BIN" "$MENU"
    echo "Removed $BIN and $MENU"
    exit 0
fi

missing=()
for dep in ffmpeg ffprobe kdialog notify-send; do
    command -v "$dep" >/dev/null 2>&1 || missing+=("$dep")
done
command -v qdbus6 >/dev/null 2>&1 || command -v qdbus-qt6 >/dev/null 2>&1 \
    || [ -x /usr/lib/qt6/bin/qdbus ] || command -v qdbus >/dev/null 2>&1 \
    || missing+=("qdbus (Qt 6 tools, only needed for the progress bar)")
[ ${#missing[@]} -gt 0 ] && printf 'Warning, missing: %s\n' "${missing[@]}"

install -Dm755 convert-video "$BIN"
mkdir -p "$MENU_DIR"
# absolute path: Dolphin does not always have ~/.local/bin in its PATH
sed "s|@BIN@|$BIN|g" convert-video.desktop > "$MENU"
# Plasma 6 only loads service menus that are executable
chmod 755 "$MENU"

echo "Installed:"
echo "  $BIN"
echo "  $MENU"
echo "Restart Dolphin, then right-click a video > Convert video."
