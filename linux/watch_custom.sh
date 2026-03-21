#!/bin/bash

# ─────────────────────────────────────────
#  beepify - linux/watch_custom.sh
#  Watches sounds/custom/ for new audio files
#  and auto-converts them to .aiff
#
#  Usage (from repo root):
#    source linux/watch_custom.sh          # start watching
#    source linux/watch_custom.sh stop     # stop watching
# ─────────────────────────────────────────

BEEPIFY_ROOT="$(pwd)"
CUSTOM_DIR="$BEEPIFY_ROOT/sounds/custom"
PID_FILE="/tmp/beepify_watcher.pid"
LOG="/tmp/beepify_watcher.log"
SUPPORTED_EXT=(mp3 wav m4a aac ogg flac wma mp4 mov aif)

# ── Stop ──────────────────────────────────
if [[ "$1" == "stop" ]]; then
    if [[ -f "$PID_FILE" ]]; then
        kill "$(cat "$PID_FILE")" 2>/dev/null
        rm -f "$PID_FILE"
        echo -e "\033[0;31m(beepify) 🔕 custom watcher stopped\033[0m"
    else
        echo "(beepify) watcher is not running"
    fi
    return 0
fi

# ── Check existing watcher ────────────────
if [[ -f "$PID_FILE" ]] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
    echo -e "\033[0;33m(beepify) watcher is already running (PID $(cat "$PID_FILE"))\033[0m"
    return 0
fi

# ── Dependency checks ─────────────────────
if ! command -v inotifywait &>/dev/null; then
    echo "❌ inotifywait not found. Install it with:"
    echo "     Ubuntu/Debian:  sudo apt install inotify-tools"
    echo "     Fedora/RHEL:    sudo dnf install inotify-tools"
    echo "     Arch:           sudo pacman -S inotify-tools"
    return 1
fi

if ! command -v ffmpeg &>/dev/null; then
    echo "❌ ffmpeg not found. Install it with:"
    echo "     Ubuntu/Debian:  sudo apt install ffmpeg"
    echo "     Fedora/RHEL:    sudo dnf install ffmpeg"
    echo "     Arch:           sudo pacman -S ffmpeg"
    return 1
fi

mkdir -p "$CUSTOM_DIR"

# ── Converter function ────────────────────
_beepify_next_index() {
    local idx=1 n
    for f in "$CUSTOM_DIR"/[0-9]*.aiff; do
        [[ -f "$f" ]] || continue
        n=$(basename "$f")
        n="${n%%_*}"
        [[ "$n" =~ ^[0-9]+$ ]] && (( n >= idx )) && idx=$(( n + 1 ))
    done
    echo "$idx"
}

_beepify_convert() {
    local filepath="$1"
    local fname ext base name idx output

    fname=$(basename "$filepath")
    ext="${fname##*.}"
    ext="${ext,,}"  # lowercase
    base="${fname%.*}"

    [[ "$ext" == "aiff" ]] && return
    [[ "$fname" == .* ]] && return

    local ok=0
    for e in "${SUPPORTED_EXT[@]}"; do [[ "$e" == "$ext" ]] && ok=1 && break; done
    (( ok == 0 )) && return

    sleep 1

    name="${base// /_}"
    idx=$(_beepify_next_index)
    output="$CUSTOM_DIR/${idx}_${name}.aiff"

    echo "[$(date)] Converting: $fname → ${idx}_${name}.aiff" >> "$LOG"

    ffmpeg -y -i "$filepath" -c:a pcm_s16be -ar 44100 "$output" -loglevel error 2>>"$LOG"

    if [[ $? -eq 0 ]]; then
        rm -f "$filepath"
        echo "[$(date)] Done: ${idx}_${name}.aiff" >> "$LOG"
    else
        echo "[$(date)] Failed: $fname" >> "$LOG"
    fi
}

# ── Start background watcher ──────────────
(
    inotifywait -m -q \
        --event close_write \
        --event moved_to \
        --format '%w%f' \
        "$CUSTOM_DIR" | while read -r filepath; do
            _beepify_convert "$filepath"
        done
) &

echo "$!" > "$PID_FILE"

echo ""
echo -e "\033[0;31m(beepify) 👁  custom watcher active\033[0m"
echo "  Drop any audio file into sounds/custom/"
echo "  It will auto-convert to .aiff — no command needed."
echo ""
echo "  Supported: mp3  wav  m4a  aac  ogg  flac  wma  mp4  mov  aif"
echo ""
echo "  To stop:  source linux/watch_custom.sh stop"
echo "  Log:      tail -f /tmp/beepify_watcher.log"
echo ""
