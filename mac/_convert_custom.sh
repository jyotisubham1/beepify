#!/bin/zsh

# ─────────────────────────────────────────
#  beepify - mac/_convert_custom.sh
#  Triggered by launchd when sounds/custom/ changes.
#  Converts any non-.aiff audio file to .aiff.
# ─────────────────────────────────────────

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CUSTOM_DIR="$SCRIPT_DIR/../sounds/custom"
SUPPORTED_EXT=(mp3 wav m4a aac ogg flac wma mp4 mov aif)
LOG="/tmp/beepify_watcher.log"
FFMPEG=$(which ffmpeg)

if [[ -z "$FFMPEG" ]]; then
  echo "[$(date)] ERROR: ffmpeg not found" >> "$LOG"
  exit 1
fi

next_index() {
  local idx=1
  local f n
  # (N) glob qualifier: no error if no matches
  for f in "$CUSTOM_DIR"/[0-9]*.aiff(N); do
    [[ -f "$f" ]] || continue
    n=$(basename "$f")
    n="${n%%_*}"
    [[ "$n" =~ ^[0-9]+$ ]] && (( n >= idx )) && idx=$(( n + 1 ))
  done
  echo "$idx"
}

for f in "$CUSTOM_DIR"/*; do
  [[ -f "$f" ]] || continue

  fname=$(basename "$f")
  ext="${fname##*.}"
  ext=$(echo "$ext" | tr '[:upper:]' '[:lower:]')
  base="${fname%.*}"

  # Skip already converted and hidden/temp files
  [[ "$ext" == "aiff" ]] && continue
  [[ "$fname" == .* ]] && continue

  # Check if format is supported
  ok=0
  for e in "${SUPPORTED_EXT[@]}"; do
    [[ "$e" == "$ext" ]] && ok=1 && break
  done
  (( ok == 0 )) && continue

  # Wait for file to finish copying
  sleep 1

  name="${base// /_}"
  idx=$(next_index)
  output="$CUSTOM_DIR/${idx}_${name}.aiff"

  echo "[$(date)] Converting: $fname → ${idx}_${name}.aiff" >> "$LOG"

  "$FFMPEG" -y -i "$f" -c:a pcm_s16be -ar 44100 "$output" -loglevel error 2>>"$LOG"

  if [[ $? -eq 0 ]]; then
    rm -f "$f"
    echo "[$(date)] Done: ${idx}_${name}.aiff" >> "$LOG"
  else
    echo "[$(date)] Failed: $fname" >> "$LOG"
  fi
done
