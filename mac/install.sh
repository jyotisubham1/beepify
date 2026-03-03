#!/bin/bash

# ─────────────────────────────────────────
#  beepify - mac/install.sh
#  Interactive installer for macOS
# ─────────────────────────────────────────

BEEPIFY_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BEEPIFY_CONFIG="$BEEPIFY_ROOT/shared/config.json"
BEEPIFY_SOUNDS="$BEEPIFY_ROOT/sounds"

echo ""
echo -e "\033[0;31m🔔 beepify installer - macOS\033[0m"
echo "─────────────────────────────"

# List available sounds
echo ""
echo "Available sounds:"
echo ""
i=1
sounds=()
for f in "$BEEPIFY_SOUNDS"/*.aiff; do
  name=$(basename "$f")
  echo "  [$i] $name"
  sounds+=("$name")
  ((i++))
done

# Prompt user to pick
echo ""
read -p "Choose a sound [1-${#sounds[@]}]: " choice

# Validate input
if ! [[ "$choice" =~ ^[0-9]+$ ]] || [ "$choice" -lt 1 ] || [ "$choice" -gt "${#sounds[@]}" ]; then
  echo "❌ Invalid choice. Run the installer again."
  exit 1
fi

CHOSEN="${sounds[$((choice-1))]}"

# Save to config.json
cat > "$BEEPIFY_CONFIG" << CONF
{
  "sound": "$CHOSEN",
  "activated": false
}
CONF

echo ""
echo -e "\033[0;31m✅ beepify configured!\033[0m"
echo "   Sound set to: $CHOSEN"
echo ""
echo "To activate beepify in your terminal:"
echo -e "   \033[0;31msource mac/activate.sh\033[0m"
echo ""
