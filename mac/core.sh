#!/bin/zsh

# ─────────────────────────────────────────
#  beepify - mac/core.sh
#  The engine: hooks into shell, plays sound on error
# ─────────────────────────────────────────

_beepify_error_handler() {
  local sound_file="$BEEPIFY_ROOT/sounds/$BEEPIFY_CATEGORY/$BEEPIFY_SOUND"
  local display=$(echo "$BEEPIFY_SOUND" | sed 's/^[0-9]*_//' | sed 's/\.aiff//')

  echo -e "\033[0;31m🔔 $display\033[0m"

  if [ -f "$sound_file" ]; then
    (afplay "$sound_file" &>/dev/null &) 2>/dev/null
    disown %% 2>/dev/null
  fi
}

trap '_beepify_error_handler' ERR
