#!/bin/zsh

# ─────────────────────────────────────────
#  beepify - mac/watch_custom.sh
#  Registers a macOS launchd watcher on sounds/custom/
#  Any audio file dropped there auto-converts to .aiff
#
#  Usage:
#    source mac/watch_custom.sh          # start watching
#    source mac/watch_custom.sh stop     # stop watching
# ─────────────────────────────────────────

BEEPIFY_ROOT="$(pwd)"
CUSTOM_DIR="$BEEPIFY_ROOT/sounds/custom"
PLIST_LABEL="com.beepify.custom_watcher"
PLIST_PATH="$HOME/Library/LaunchAgents/${PLIST_LABEL}.plist"
CONVERTER="$BEEPIFY_ROOT/mac/_convert_custom.sh"

# ── Stop ──────────────────────────────────
if [[ "$1" == "stop" ]]; then
  launchctl unload "$PLIST_PATH" 2>/dev/null
  rm -f "$PLIST_PATH"
  echo -e "\033[0;31m(beepify) 🔕 custom watcher stopped\033[0m"
  return 0
fi

# ── Dependency check ──────────────────────
if ! command -v ffmpeg &>/dev/null; then
  echo "❌ ffmpeg not found. Install it with:"
  echo "     brew install ffmpeg"
  return 1
fi

# ── Write converter script ────────────────
mkdir -p "$CUSTOM_DIR"

cat > "$CONVERTER" << SCRIPT
#!/bin/zsh
CUSTOM_DIR="$CUSTOM_DIR"
SUPPORTED_EXT=(mp3 wav m4a aac ogg flac wma mp4 mov aif)
LOG="/tmp/beepify_watcher.log"

next_index() {
  local idx=1
  for f in "\$CUSTOM_DIR"/[0-9]*.aiff "\$CUSTOM_DIR"/[0-9][0-9]*.aiff; do
    [[ -f "\$f" ]] || continue
    local n="\${{\$f:t}%%_*}"
    [[ "\$n" =~ ^[0-9]+\$ ]] && (( n >= idx )) && idx=\$(( n + 1 ))
  done
  echo "\$idx"
}

for f in "\$CUSTOM_DIR"/*; do
  [[ -f "\$f" ]] || continue
  ext="\${f:e:l}"
  base="\${{\$f:t}:r}"
  [[ "\$ext" == "aiff" ]] && continue
  [[ "\${f:t}" == .* ]] && continue

  ok=0
  for e in "\${SUPPORTED_EXT[@]}"; do [[ "\$e" == "\$ext" ]] && ok=1 && break; done
  (( ok == 0 )) && continue

  sleep 0.5
  name="\${base// /_}"
  idx=\$(next_index)
  output="\$CUSTOM_DIR/\${idx}_\${name}.aiff"

  echo "[\$(date)] Converting: \${f:t} → \${idx}_\${name}.aiff" >> "\$LOG"
  ffmpeg -y -i "\$f" -c:a pcm_s16be -ar 44100 "\$output" -loglevel error 2>>"\$LOG"

  if [[ \$? -eq 0 ]]; then
    rm -f "\$f"
    echo "[\$(date)] Done: \${idx}_\${name}.aiff" >> "\$LOG"
  else
    echo "[\$(date)] Failed: \${f:t}" >> "\$LOG"
  fi
done
SCRIPT

chmod +x "$CONVERTER"

# ── Write launchd plist ───────────────────
cat > "$PLIST_PATH" << PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>${PLIST_LABEL}</string>

  <key>ProgramArguments</key>
  <array>
    <string>/bin/zsh</string>
    <string>${CONVERTER}</string>
  </array>

  <key>WatchPaths</key>
  <array>
    <string>${CUSTOM_DIR}</string>
  </array>

  <key>RunAtLoad</key>
  <false/>
</dict>
</plist>
PLIST

# ── Load it ───────────────────────────────
launchctl unload "$PLIST_PATH" 2>/dev/null
launchctl load "$PLIST_PATH"

echo ""
echo -e "\033[0;31m(beepify) 👁  custom watcher active\033[0m"
echo "  Drop any audio file into sounds/custom/"
echo "  It will auto-convert to .aiff — no command needed."
echo ""
echo "  Supported: mp3  wav  m4a  aac  ogg  flac  wma  mp4  mov  aif"
echo ""
echo "  To stop:  source mac/watch_custom.sh stop"
echo "  Log:      tail -f /tmp/beepify_watcher.log"
echo ""
