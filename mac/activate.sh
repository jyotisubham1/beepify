#!/bin/zsh

# ─────────────────────────────────────────
#  beepify - mac/activate.sh
#  Activates beepify in current shell session
#  Usage: source mac/activate.sh
# ─────────────────────────────────────────

# Get beepify root using PWD (more reliable in zsh)
BEEPIFY_ROOT="$(pwd)"
BEEPIFY_CONFIG="$BEEPIFY_ROOT/shared/config.json"

# Check macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
  echo "❌ This script is for macOS only."
  return 1
fi

# Check afplay is available
if ! command -v afplay &> /dev/null; then
  echo "❌ afplay not found. Are you on macOS?"
  return 1
fi

# Check config exists
if [ ! -f "$BEEPIFY_CONFIG" ]; then
  echo "❌ Config not found at: $BEEPIFY_CONFIG"
  echo "   Run: bash mac/install.sh first"
  return 1
fi

# Read chosen sound
BEEPIFY_SOUND=$(grep '"sound"' "$BEEPIFY_CONFIG" | sed 's/.*"sound": *"\(.*\)".*/\1/')
BEEPIFY_SOUND_PATH="$BEEPIFY_ROOT/sounds/$BEEPIFY_SOUND"

# Check sound file exists
if [ ! -f "$BEEPIFY_SOUND_PATH" ]; then
  echo "❌ Sound file not found: $BEEPIFY_SOUND"
  echo "   Run: bash mac/install.sh to choose a valid sound"
  return 1
fi

# Load the core engine
source "$BEEPIFY_ROOT/mac/core.sh"

# Mark as activated
export BEEPIFY_ACTIVE=1
export BEEPIFY_SOUND
export BEEPIFY_ROOT

# Print activation message in red (just like venv)
echo -e "\033[0;31m(beepify) 🔔 error sounds ON [$BEEPIFY_SOUND]\033[0m"
