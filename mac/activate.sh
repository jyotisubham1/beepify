#!/bin/zsh

# ─────────────────────────────────────────
#  beepify - mac/activate.sh
# ─────────────────────────────────────────

BEEPIFY_ROOT="${BEEPIFY_ROOT:-$(pwd)}"
BEEPIFY_CONFIG="$BEEPIFY_ROOT/shared/config.json"

# Check macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
  echo "❌ This script is for macOS only."
  return 1
fi

# Check afplay
if ! command -v afplay &> /dev/null; then
  echo "❌ afplay not found."
  return 1
fi

# Check config
if [ ! -f "$BEEPIFY_CONFIG" ]; then
  echo "❌ Config not found. Run: bash mac/install.sh first"
  return 1
fi

# Already active?
if [ "$BEEPIFY_ACTIVE" = "1" ]; then
  echo -e "\033[0;31m(beepify) ⚠️  already active [$BEEPIFY_CATEGORY/$BEEPIFY_SOUND]\033[0m"
  return 0
fi

# Read category and sound from config
BEEPIFY_CATEGORY=$(grep '"category"' "$BEEPIFY_CONFIG" | sed 's/.*"category": *"\(.*\)".*/\1/')
BEEPIFY_SOUND=$(grep '"sound"' "$BEEPIFY_CONFIG" | sed 's/.*"sound": *"\(.*\)".*/\1/')
BEEPIFY_SOUND_PATH="$BEEPIFY_ROOT/sounds/$BEEPIFY_CATEGORY/$BEEPIFY_SOUND"

# Check sound exists
if [ ! -f "$BEEPIFY_SOUND_PATH" ]; then
  echo "❌ Sound not found: $BEEPIFY_CATEGORY/$BEEPIFY_SOUND"
  echo "   Run: bash mac/install.sh"
  return 1
fi

# Load core engine
source "$BEEPIFY_ROOT/mac/core.sh"

# Export vars
export BEEPIFY_ACTIVE=1
export BEEPIFY_SOUND
export BEEPIFY_CATEGORY
export BEEPIFY_ROOT

# Deactivate function
beepify_deactivate() {
  if [ "$BEEPIFY_ACTIVE" != "1" ]; then
    echo "❌ beepify is not active"
    return 1
  fi
  trap - ERR
  unset BEEPIFY_ACTIVE BEEPIFY_SOUND BEEPIFY_CATEGORY BEEPIFY_ROOT
  unset -f _beepify_error_handler beepify_deactivate
  echo -e "\033[0;31m(beepify) 🔕 error sounds OFF\033[0m"
}

echo -e "\033[0;31m(beepify) 🔔 error sounds ON [$BEEPIFY_CATEGORY/$BEEPIFY_SOUND]\033[0m"
