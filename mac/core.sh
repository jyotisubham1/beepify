#!/bin/zsh

# ─────────────────────────────────────────
#  beepify - mac/core.sh
#  The engine: hooks into shell, plays sound on error
# ─────────────────────────────────────────

BEEPIFY_SOUNDS="$BEEPIFY_ROOT/sounds"

# The error handler - fires on every non-zero exit code
_beepify_error_handler() {
  local sound_file="$BEEPIFY_SOUNDS/$BEEPIFY_SOUND"
  if [ -f "$sound_file" ]; then
    afplay "$sound_file" &
  fi
}

# Activate the error trap
trap '_beepify_error_handler' ERR
